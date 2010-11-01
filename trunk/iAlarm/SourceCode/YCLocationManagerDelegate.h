//
//  YCLocationManagerDelegate.h
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCLocationManagerDelegateProtocol.h"
#import "YCLocationManager.h"

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface YCLocationManagerDelegate : NSObject 
<YCLocationManagerDelegateProtocol>
{
	

}

- (void)locationManager:(YCLocationManager *)manager didEnterRegion:(CLRegion *)region;
- (void)locationManager:(YCLocationManager *)manager didExitRegion:(CLRegion *)region;


@end
