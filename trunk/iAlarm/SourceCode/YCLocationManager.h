//
//  YCLocationManager.h
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCLocationManagerDelegateProtocol.h"
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface YCLocationManager : NSObject <CLLocationManagerDelegate>
{
	
	CLLocationManager *significantLocationManager;
	id<YCLocationManagerDelegateProtocol> delegate;
	BOOL running; //是否正在运行
	
	CLLocation *bestEffortAtLocation;

}

@property(readonly, nonatomic) CLLocationManager *significantLocationManager;
@property(assign, nonatomic,readonly) id<YCLocationManagerDelegateProtocol> delegate;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;

+(YCLocationManager*) locationManagerSigleInstance;

- (void)startMonitoringForRegion:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)stopMonitoringForRegion:(CLRegion *)region;
- (void)removeAllRegionMonitored;

//对区域列表进行检查
- (void)monitorRegionCenter;

-(void) start;
-(void) stop;
-(void) restart;

@end
