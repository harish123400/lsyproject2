//
//  YCLocationManager.m
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCLocationManager.h"
#import "LocationUtility.h"
#import "RegionCenter.h"
#import "YCLocationManagerDelegate.h"
#import "StandardLocationManager.h"
#import "YCParam.h"
#import "UIUtility.h"


@implementation YCLocationManager
@synthesize delegate;
//@synthesize desiredAccurac;
@synthesize bestEffortAtLocation;
@synthesize lastLocation;
@synthesize running;



+(YCLocationManager*) locationManagerSigleInstance
{
	static YCLocationManager* locationManager = nil;
	if (locationManager == nil) {
		locationManager = [[YCLocationManager alloc] init];
	}
	return locationManager;
}


-(CLLocationManager*)significantLocationManager
{
	if (significantLocationManager == nil) {
		significantLocationManager = [[CLLocationManager alloc] init];
		significantLocationManager.delegate = self;
	}
	return significantLocationManager;
}

-(YCLocationManagerDelegate*)delegate
{
	if(delegate ==nil)
	{
		delegate = [[YCLocationManagerDelegate alloc] init];
	}
	return delegate;
}



- (void)startMonitoringForRegion:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy
{

	//加入到列表中
	NSMutableArray *regions = [RegionCenter regionCenterSingleInstance].regions;
	[regions addObject:region];						   
	
	//判断当前位置是否在region中
	CLLocation *curLocation = significantLocationManager.location;
	BOOL isContain = [region containsCoordinate:curLocation.coordinate];
	if (isContain) {
		NSMutableDictionary *regionsContainsLastLocation = [RegionCenter regionCenterSingleInstance].regionsForContainsLastLocation;
		[regionsContainsLastLocation setObject:region forKey:region.identifier];
	}
	
	
}

- (void)stopMonitoringForRegion:(CLRegion *)region
{
	//从当前位置列表中删除region
	NSMutableDictionary *regionsContainsLastLocation = [RegionCenter regionCenterSingleInstance].regionsForContainsLastLocation;
	[regionsContainsLastLocation removeObjectForKey:region.identifier];
	
	//从列表中删除region
	NSMutableArray *regions = [RegionCenter regionCenterSingleInstance].regions;
	[regions removeObject:region];
	
}

- (void)removeAllRegionMonitored
{
	NSMutableArray *regions = [RegionCenter regionCenterSingleInstance].regions;
	[regions removeAllObjects];
	NSMutableDictionary *regionsContainsLastLocation = [RegionCenter regionCenterSingleInstance].regionsForContainsLastLocation;
	[regionsContainsLastLocation removeAllObjects];
}

- (void)monitorRegionCenter
{

	if (self.bestEffortAtLocation == nil) {
		return;
	}else {
		self.lastLocation = self.bestEffortAtLocation;
		self.bestEffortAtLocation = nil;
	}

	
	CLLocation *curLocation = self.lastLocation;
	//CLLocationSpeed curSpeed = curLocation.speed;
	NSMutableDictionary *regionsContainsLastLocation = [RegionCenter regionCenterSingleInstance].regionsForContainsLastLocation;
	NSMutableArray *regions = [RegionCenter regionCenterSingleInstance].regions;
	
	
	
	///////////////////////////////“最后所在区域”列表///////////////////////////////
	////
	//当前位置与“最后所在区域”列表中的各个位置比较,如果有 大于 区域列表的半径的，就启动标准定位
	BOOL isContainLast =[LocationUtility includeNoContainsLocation:curLocation 
														 atRegions:[regionsContainsLastLocation allValues]];
	//if(curSpeed > 1.0)
	if (regionsContainsLastLocation.count > 0 && !isContainLast) {
		[[StandardLocationManager standardLocationManagerSigleInstance] start];
		return;
	}
	////
	///////////////////////////////“最后所在区域”列表///////////////////////////////
	
	
	
	///////////////////////////////“区域”列表///////////////////////////////
    ////
	//当前位置 与 "所有区域"列表中的各个位置比较,如果有 小于 预警示设定距离的;而且该区域不在“包含最后区域”列表中.就启动标准定位
	BOOL lessProAlarmDistance = [LocationUtility includeLessDistance:[YCParam paramSingleInstance].distanceForProAlarm
															location:curLocation 
														   atRegions:regions
														   noRegions:regionsContainsLastLocation];
	//if(curSpeed > 1.0)
	if (regions.count >0 && !lessProAlarmDistance) {
		[[StandardLocationManager standardLocationManagerSigleInstance] start];
		return;
	}
	////
	///////////////////////////////“区域”列表///////////////////////////////
	
	//所有条件都不满足，停止标准定位
	[[StandardLocationManager standardLocationManagerSigleInstance] stop];
	
	//为下次定位做
	self.bestEffortAtLocation == nil;
}

#pragma mark - significantManager
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation
{
	//NSDate* eventDate = newLocation.timestamp;
    //NSTimeInterval howRecent = -[eventDate timeIntervalSinceNow];

    //if (howRecent > 5.0) return;
	
	if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) 
	{
        self.bestEffortAtLocation = newLocation;
    }
	
	[self performSelector:@selector(monitorRegionCenter) withObject:nil afterDelay:3.0];

}



- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSString *notificationMsg = @"significantManager didFailWithError \n error:";
	if ([error localizedDescription])
		[notificationMsg stringByAppendingString:[error localizedDescription]];
	[notificationMsg stringByAppendingString:@"\n reason:"];
	if ([error localizedFailureReason])
		[notificationMsg stringByAppendingString:[error localizedFailureReason]];
	
	[UIUtility sendSimpleNotifyForAlart:notificationMsg];  //debug
}


-(void) start
{
	if (!running) 
	{
		[self.significantLocationManager startMonitoringSignificantLocationChanges];
		running = YES;
		//[UIUtility sendSimpleNotifyForAlart:@"startMonitoringSignificantLocationChanges"];  //debug
	}
}

-(void) stop
{
	if (running)
	{
		[self.significantLocationManager stopMonitoringSignificantLocationChanges];
		running = NO;
		//[UIUtility sendSimpleNotifyForAlart:@"stopMonitoringSignificantLocationChanges"];  //debug
	}
}

-(void) restart
{
	[self stop];
	[self performSelector:@selector(start) withObject:nil afterDelay:0.1];
}

-(void) dealloc
{
	[delegate release];
	[significantLocationManager release];
	[bestEffortAtLocation release];
	[lastLocation release];
	[super dealloc];
}

@end
