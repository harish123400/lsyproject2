//
//  YCLocationManager.m
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCLocationManager.h"
#import "LocationUtility.h"
#import "RegionsCenter.h"
#import "YCLocationManagerDelegate.h"
#import "StandardLocationManager.h"
#import "YCParam.h"
#import "UIUtility.h"
#import "YCLog.h"


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
	NSMutableArray *regions = [RegionsCenter regionCenterSingleInstance].regions;
	[regions addObject:region];						   
	
	//判断当前位置是否在region中
	CLLocation *curLocation = significantLocationManager.location;
	BOOL isContain = [region containsCoordinate:curLocation.coordinate];
	if (isContain) {
		NSMutableDictionary *regionsContainsLastLocation = [RegionsCenter regionCenterSingleInstance].regionsForContainsLastLocation;
		[regionsContainsLastLocation setObject:region forKey:region.identifier];
	}
	
	
}

- (void)stopMonitoringForRegion:(CLRegion *)region
{
	//从当前位置列表中删除region
	NSMutableDictionary *regionsContainsLastLocation = [RegionsCenter regionCenterSingleInstance].regionsForContainsLastLocation;
	[regionsContainsLastLocation removeObjectForKey:region.identifier];
	
	//从列表中删除region
	NSMutableArray *regions = [RegionsCenter regionCenterSingleInstance].regions;
	[regions removeObject:region];
	
}

- (void)removeAllRegionMonitored
{
	NSMutableArray *regions = [RegionsCenter regionCenterSingleInstance].regions;
	[regions removeAllObjects];
	NSMutableDictionary *regionsContainsLastLocation = [RegionsCenter regionCenterSingleInstance].regionsForContainsLastLocation;
	[regionsContainsLastLocation removeAllObjects];
}

- (void)monitorRegionCenter
{
	
	[[YCLog logSingleInstance] addlog:@"here is signi-monitorRegionCenter"];

	CLLocation *curLocation = nil;
	if (self.bestEffortAtLocation == nil) {
		curLocation = self.significantLocationManager.location;
		self.lastLocation = curLocation;
		if(curLocation == nil) return; //定位失败
	}else {
		curLocation = self.bestEffortAtLocation;
		self.lastLocation = self.bestEffortAtLocation;
		//为下次定位做
		self.bestEffortAtLocation == nil;
	}
	
	if (curLocation.horizontalAccuracy > [[YCParam paramSingleInstance] invalidLocationAccuracy])
	{
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"signi-monitorRegionCenter 无效精度:%.1f",curLocation.horizontalAccuracy ]];
		[[YCLog logSingleInstance] addlog:@"返回"];
		return;
	}


	//CLLocationSpeed curSpeed = curLocation.speed;
	NSMutableDictionary *regionsContainsLastLocation = [RegionsCenter regionCenterSingleInstance].regionsForContainsLastLocation;
	NSMutableArray *regions = [RegionsCenter regionCenterSingleInstance].regions;
	
	
	///////////////////////////////“最后所在区域”列表///////////////////////////////
	////
	//当前位置与“最后所在区域”列表中的各个位置比较,如果有 大于 区域列表的半径的，就启动标准定位
	BOOL isContainLast =[LocationUtility includeNoContainsLocation:curLocation 
														 atRegions:[regionsContainsLastLocation allValues]];
	//if(curSpeed > 1.0)
	if (regionsContainsLastLocation.count > 0 && !isContainLast) {
		[[StandardLocationManager standardLocationManagerSigleInstance] beginLocation];
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
		[[StandardLocationManager standardLocationManagerSigleInstance] beginLocation];
		return;
	}
	////
	///////////////////////////////“区域”列表///////////////////////////////
	
	//所有条件都不满足，停止标准定位
	//[[StandardLocationManager standardLocationManagerSigleInstance] endLocation];
	
	
}

#pragma mark - significantManager
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager 
	didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation
{
	[[YCLog logSingleInstance] addlog:@"here is signi-didUpdateToLocation"];
	
	//NSDate* eventDate = newLocation.timestamp;
    //NSTimeInterval howRecent = -[eventDate timeIntervalSinceNow];

    //if (howRecent > 5.0) return;
	if (newLocation.horizontalAccuracy > [[YCParam paramSingleInstance] invalidLocationAccuracy])
	{
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"signi-didUpdateToLocation 无效精度:%.1f",newLocation.horizontalAccuracy ]];
		[[YCLog logSingleInstance] addlog:@"返回"];
		return;
	}
	
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
	
	[[YCLog logSingleInstance] addlog:notificationMsg];
	
}


-(void) start
{
	//是否启用所有闹钟
	if([YCParam paramSingleInstance].enableOfAllLocAlarms == NO)
		return;
	
	if (!running) 
	{
		NSTimeInterval ti = [YCParam paramSingleInstance].intervalForStartStandardLocation;
		myTimer = [[NSTimer timerWithTimeInterval:ti target:self selector:@selector(monitorRegionCenter) userInfo:nil repeats:YES] retain];
		[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
		
		[self.significantLocationManager startMonitoringSignificantLocationChanges];
		//[self.significantLocationManager startUpdatingLocation];
		running = YES;
	}
}

-(void) stop
{
	if (running)
	{
		//reset the timer
		[myTimer invalidate];
		[myTimer release];
		myTimer = nil;

		[self.significantLocationManager stopMonitoringSignificantLocationChanges];
		//[self.significantLocationManager stopUpdatingLocation];
		running = NO;
	}
}

-(void) restart
{
	[self stop];
	[self performSelector:@selector(start) withObject:nil afterDelay:0.1];
}

-(void) startTimer
{
	
	timerExeFlag = YES;
	while (timerExeFlag) 
	{
		/////把后台任务时间归零，通过:启动标准定位
		double d = [UIApplication sharedApplication].backgroundTimeRemaining;
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"backgroundTimeRemaining=%6.1f",d]];
		if(d<50.0)
		{
			[[YCLog logSingleInstance] addlog:@"打开标准 startUpdatingLocation"];
			[self.significantLocationManager startUpdatingLocation];
			[NSThread sleepForTimeInterval:3.0];
			[[YCLog logSingleInstance] addlog:@"关闭标准 startUpdatingLocation"];
			[self.significantLocationManager stopUpdatingLocation];		 
		}

		[NSThread sleepForTimeInterval:30.0];
	}
	
}
-(void) stopTimer
{
	timerExeFlag = NO;
}

-(void) dealloc
{
	[delegate release];
	[significantLocationManager release];
	[bestEffortAtLocation release];
	[lastLocation release];
	[myTimer release];
	[super dealloc];
}

@end
