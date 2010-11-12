//
//  AlarmPositionMapViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModifyViewController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



@interface AlarmPositionMapViewController : AlarmModifyViewController 
<MKMapViewDelegate,CLLocationManagerDelegate>
{
	NSTimer *myTimer;
	
	MKMapView* mapView;
	UIView *maskView;
	UIActivityIndicatorView *activityIndicator;
	

	MKCoordinateRegion defaultMapRegion;
	BOOL isFirstShow;
	BOOL isCenterWithcurrent;     //是否以当前位置为地图中心
	BOOL isAlreadyCenterCoord;    //中心坐标是否准备好

	NSArray *alarms;            //需要在地图上显示的
	
}

@property (nonatomic,retain) IBOutlet MKMapView* mapView;
@property (nonatomic,retain) IBOutlet UIView *maskView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic,assign) BOOL isCenterWithcurrent;
@property (nonatomic,retain) NSArray *alarms;

@end
