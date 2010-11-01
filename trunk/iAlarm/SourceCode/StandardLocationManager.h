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
}
@property (nonatomic,readonly) CLLocationManager *locationManager;

+(StandardLocationManager*) standardLocationManagerSigleInstance;

-(void) start;
-(void) stop;

@end
