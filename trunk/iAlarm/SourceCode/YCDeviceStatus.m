//
//  YCDeviceStatus.m
//  iAlarm
//
//  Created by li shiyong on 10-11-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCDeviceStatus.h"
#import "YCLocationManager.h"
#import "StandardLocationManager.h"
#import "Reachability.h"


@implementation YCDeviceStatus

- (CLLocationManager *)locationManager
{
	if (locationManager == nil) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}
	return locationManager;
}

- (BOOL)significantService
{
	significantService = [YCLocationManager locationManagerSigleInstance].running;
	return significantService;
}



- (BOOL)standardService
{
	standardService = [StandardLocationManager standardLocationManagerSigleInstance].running;
	return standardService;
}

- (CLLocation *)lastStandardLocation
{
	if (lastStandardLocation != nil ) [lastStandardLocation release];
	lastStandardLocation = [StandardLocationManager standardLocationManagerSigleInstance].lastLocation;
	[lastStandardLocation retain];
	return lastStandardLocation;
}

- (CLLocationSpeed) lastStandardLocationSpeed
{
	lastStandardLocationSpeed = self.lastStandardLocation.speed;
	return lastStandardLocationSpeed;
}

- (CLLocation *)lastSignificantLocation
{
	if (lastSignificantLocation != nil ) [lastSignificantLocation release];
	lastSignificantLocation = [YCLocationManager locationManagerSigleInstance].lastLocation;
	[lastSignificantLocation retain];
	return lastSignificantLocation;
}

- (CLLocationSpeed) lastSignificantLocationSpeed
{
	lastSignificantLocationSpeed = self.lastSignificantLocation.speed;
	return lastSignificantLocationSpeed;
}

- (CLLocation *)currentLocation
{
	[self.locationManager startUpdatingLocation];
	if (currentLocation != nil ) [currentLocation release];
	currentLocation = self.locationManager.location;
	[currentLocation retain];
	[self.locationManager stopUpdatingLocation];
	return currentLocation;
}

- (CLLocationSpeed) currentLocationSpeed
{
	currentLocationSpeed = self.currentLocation.speed;
	return currentLocationSpeed;
}

- (BOOL) connectedToInternet
{
	BOOL retVal = NO;
	Reachability *internetReach = [Reachability reachabilityForInternetConnection];
	if (!internetReach.connectionRequired) 
	{
		switch (internetReach.currentReachabilityStatus) {
			case ReachableViaWiFi:
			case ReachableViaWWAN:
				retVal = YES;
				break;
			default:
				retVal = NO;
				break;
		}
	}
	
	return retVal;
}
- (BOOL) enabledLocation
{
	return [CLLocationManager locationServicesEnabled];
	//return YES; //TODO,本程序是否运行定位不能确定！！！
}

/*
//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	self->connectedToInternet = [curReach connectionRequired] && 
	                            (curReach.currentReachabilityStatus == ReachableViaWiFi || ReachableViaWWAN);
}
 */


+(YCDeviceStatus*) deviceStatusSingleInstance
{
	static YCDeviceStatus* obj = nil;
	if (obj == nil) {
		obj = [[YCDeviceStatus alloc] init];
		[obj retain];
	}
	
	return obj;
	
	/*
	[[NSNotificationCenter defaultCenter] addObserver: obj selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	obj->internetReach = [[Reachability reachabilityForInternetConnection] retain];
	obj->connectedToInternet = [obj->internetReach currentReachabilityStatus];
	[obj->internetReach startNotifier];
	 */
	
}

- (void)dealloc {
	
	[locationManager release];
	[lastStandardLocation release];
	[lastSignificantLocation release];
	[currentLocation release];
    [super dealloc];
}




@end
