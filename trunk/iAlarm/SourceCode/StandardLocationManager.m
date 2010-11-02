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


@implementation StandardLocationManager
@synthesize bestEffortAtLocation;

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

-(void) start
{
	
	if (!running) 
	{
		[self.locationManager startUpdatingLocation];
		running = YES;
		[YCParam paramSingleInstance].standardService = YES;
		//[UIUtility sendSimpleNotifyForAlart:@"startUpdatingLocation"];  //debug
	}
	
}

-(void) stop
{
	if (running)
	{
		[self.locationManager stopUpdatingHeading];
		running = NO;
		[YCParam paramSingleInstance].standardService = NO;
		//[UIUtility sendSimpleNotifyForAlart:@"stopUpdatingLocation"];  //debug
	}

}
-(void)monitorRegionCenter
{
	if (self.bestEffortAtLocation == nil) {
		return;
	}
	
	CLLocation *curLocation = self.bestEffortAtLocation;
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
	}
	////
	///////////////////////////////“最后所在区域”列表///////////////////////////////
	
	//低速（静止）运行时候，关闭standard
	CLLocationSpeed curSpeed = curLocation.speed;
	if(curSpeed <= 1.0) [self stop];
	
	
}


#pragma mark - locationManager
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation
{
	
	NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
	
    if (abs(howRecent) > 5.0) return;
	
	if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) 
	{
        self.bestEffortAtLocation = newLocation;
    }
	
	[self performSelector:@selector(monitorRegionCenter) withObject:nil afterDelay:5.0];
		
}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSString *notificationMsg = @"startUpdatingLocation didFailWithError \n error:";
	if ([error localizedDescription])
		[notificationMsg stringByAppendingString:[error localizedDescription]];
	[notificationMsg stringByAppendingString:@"\n reason:"];
	if ([error localizedFailureReason])
		[notificationMsg stringByAppendingString:[error localizedFailureReason]];
	
	[UIUtility sendSimpleNotifyForAlart:notificationMsg];  //debug
}

@end
