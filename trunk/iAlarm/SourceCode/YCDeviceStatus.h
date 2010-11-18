//
//  YCDeviceStatus.h
//  iAlarm
//
//  Created by li shiyong on 10-11-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@class Reachability;
@interface YCDeviceStatus : NSObject {

	BOOL significantService; //SignificantService 服务是否启动
	BOOL standardService; //standardService 服务是否启动
	
	CLLocationManager *locationManager;
	
	CLLocation *lastStandardLocation;  //上次标准定位位置
	CLLocationSpeed lastStandardLocationSpeed; //上次标准定位点时候的速度;
	
	CLLocation *lastSignificantLocation;  //上次significant定位位置
	CLLocationSpeed lastSignificantLocationSpeed; //上次significant定位点时候的速度;
	
	CLLocation *currentLocation;  //当前定位位置
	CLLocationSpeed currentLocationSpeed; //当前速度;
	
	
	BOOL connectedToInternet;
	BOOL enabledLocation;
	
	
}
@property (nonatomic,assign,readonly) BOOL significantService;
@property (nonatomic,assign,readonly) BOOL standardService;

@property (nonatomic,retain,readonly) CLLocationManager *locationManager;

@property (nonatomic,retain,readonly) CLLocation *lastStandardLocation;
@property (nonatomic,assign,readonly) CLLocationSpeed lastStandardLocationSpeed;

@property (nonatomic,retain,readonly) CLLocation *lastSignificantLocation;
@property (nonatomic,assign,readonly) CLLocationSpeed lastSignificantLocationSpeed;

@property (nonatomic,retain,readonly) CLLocation *currentLocation;
@property (nonatomic,assign,readonly) CLLocationSpeed currentLocationSpeed;

@property (nonatomic,assign,readonly) BOOL connectedToInternet;
@property (nonatomic,assign,readonly) BOOL enabledLocation;



+(YCDeviceStatus*) deviceStatusSingleInstance;

@end
