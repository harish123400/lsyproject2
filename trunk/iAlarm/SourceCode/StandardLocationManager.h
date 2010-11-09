//
//  StandardLocationManager.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface StandardLocationManager : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager *locationManager;
	BOOL running; //是否正在运行
	CLLocation *bestEffortAtLocation;
	CLLocation *lastLocation;
}
@property (nonatomic,readonly) CLLocationManager *locationManager;
@property (nonatomic,retain) CLLocation *bestEffortAtLocation;
@property (nonatomic,retain) CLLocation *lastLocation;
@property(nonatomic,assign,readonly) BOOL running; //是否正在运行


+(StandardLocationManager*) standardLocationManagerSigleInstance;

-(void) beginLocation;
-(void) endLocation;

@end
