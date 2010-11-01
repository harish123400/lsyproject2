//
//  AlarmDetailViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmNewDetailSuperViewController.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <MapKit/MapKit.h>

@class YCAlarmEntity;

@interface AlarmNewViewController : AlarmNewDetailSuperViewController 
<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,MKReverseGeocoderDelegate> {

	CLLocationManager *locationManager;
	MKReverseGeocoder *reverseGeocoder;
	BOOL locationing;  //正在定位
	
	CLLocation *bestEffortAtLocation;
}

@property (nonatomic, retain,readonly) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *bestEffortAtLocation;


@end
