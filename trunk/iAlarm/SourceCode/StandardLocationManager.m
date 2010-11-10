//
//  StandardLocationManager.m
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StandardLocationManager.h"
#import "YCParam.h"
#import "RegionCenter.h"
#import "YCLocationManager.h"
#import "UIUtility.h"
#import "LocationUtility.h"
#import "YCLog.h"


@implementation StandardLocationManager
@synthesize bestEffortAtLocation;
@synthesize lastLocation;
@synthesize running;

-(CLLocationManager *) locationManager
{
	if(!locationManager)
	{
		locationManager = [[CLLocationManager alloc] init];
		locationManager.delegate = self;
		locationManager.desiredAccuracy = [YCParam paramSingleInstance].desiredAccuracyForStartStandardLocation;
	}
	return locationManager;
}

+(StandardLocationManager*) standardLocationManagerSigleInstance
{
	static StandardLocationManager* locationManager = nil;
	if (locationManager == nil) {
		locationManager = [[StandardLocationManager alloc] init];
	}
	return locationManager;
}

-(void)monitorRegionCenter
{
	[[YCLog logSingleInstance] addlog:@"here is stand-monitorRegionCenter"];
	
	if (self.bestEffortAtLocation == nil) 
	{		
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"stand-monitorRegionCenter bestEffortAtLocation is nil"]];
		[[YCLog logSingleInstance] addlog:@"返回"];
		return;
	}else {
		self.lastLocation = self.bestEffortAtLocation;
		self.bestEffortAtLocation = nil; //为下次定位数据
	}
	
	
	CLLocation *curLocation = self.lastLocation;
	
	NSMutableArray *regions = [RegionCenter regionCenterSingleInstance].regions;
	NSMutableDictionary *regionsContainsLastLocation = [RegionCenter regionCenterSingleInstance].regionsForContainsLastLocation;
	YCLocationManager* yclm = [YCLocationManager locationManagerSigleInstance];
	
	///////////////////////////////“区域”列表///////////////////////////////
    ////
	//取得 当前位置 与 “所有区域”列表中（排除“最后所在区域”列表中） 的中心距离  < 区域半径 的 regions;
	NSArray * array = [LocationUtility containsLocation:curLocation atRegions:regions noRegions:regionsContainsLastLocation];
	for (NSUInteger i = 0; i< array.count; i++) 
	{
		CLRegion *region  = [array objectAtIndex:i];
		//加入（“包含最后区域”列表）
		[regionsContainsLastLocation setObject:region forKey:region.identifier];
		//调用didEnterRegion
		[yclm.delegate locationManager:yclm didEnterRegion:region];
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"增加“最后区域” %@",region.identifier]];
	}
	////
	///////////////////////////////“区域”列表///////////////////////////////
	
	
	///////////////////////////////“最后所在区域”列表///////////////////////////////
	////
	//取得 当前位置 与 “最后所在区域”列表中 > 区域半径 的 regions
	NSArray * arrayLast =[LocationUtility noContainsLocation:curLocation atRegions:[regionsContainsLastLocation allValues]];
	for (NSUInteger i = 0; i< arrayLast.count; i++) 
	{
		CLRegion *region  = [arrayLast objectAtIndex:i];
		//移除 从 “包含最后位置”区域
		[regionsContainsLastLocation removeObjectForKey:region.identifier];
		//调用didExitRegion
		[yclm.delegate locationManager:yclm didExitRegion:region];
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"删除“最后区域” %@",region.identifier]];
	}
	////
	///////////////////////////////“最后所在区域”列表///////////////////////////////
	
}

-(void) beginLocation
{
	if (!running) 
	{
		[[YCLog logSingleInstance] addlog:@"here is stand-beginLocation"];
		[self.locationManager startUpdatingLocation];
		running = YES;
		[self performSelector:@selector(endLocation) withObject:nil afterDelay:[YCParam paramSingleInstance].timeSpanForStandardLocation];
	}
}

-(void) endLocation
{
	if (running)
	{
		[[YCLog logSingleInstance] addlog:@"here is stand-endLocation"];
		[self.locationManager stopUpdatingLocation];
		running = NO;
		[self monitorRegionCenter];
	}
}

#pragma mark - locationManager
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation
{
	[[YCLog logSingleInstance] addlog:@"here is stand-didUpdateToLocation"];
	
	NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if (abs(howRecent) > 5.0) return;
	
	if (newLocation.horizontalAccuracy > [[YCParam paramSingleInstance] invalidLocationAccuracy])
	{
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"stand-didUpdateToLocation 无效精度:%.1f",newLocation.horizontalAccuracy ]];
		[[YCLog logSingleInstance] addlog:@"返回"];
		return;
	}
	
	if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) 
	{
        self.bestEffortAtLocation = newLocation;
    }
		
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	
	NSString *notificationMsg = @"startUpdatingLocation didFailWithError \n error:";
	if ([error localizedDescription])
		[notificationMsg stringByAppendingString:[error localizedDescription]];
	[notificationMsg stringByAppendingString:@"\n reason:"];
	if ([error localizedFailureReason])
		[notificationMsg stringByAppendingString:[error localizedFailureReason]];
	
	 
	[[YCLog logSingleInstance] addlog:notificationMsg];
}

-(void) dealloc
{
	[locationManager release];
	[bestEffortAtLocation release];
	[lastLocation release];
	[super dealloc];
}

@end
