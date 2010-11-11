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
	MKMapView* mapView;
	UIView *maskView;
	UIActivityIndicatorView *activityIndicator;
	
	CLLocationCoordinate2D centerCoord; //地图中心坐标
	BOOL centerWithcurrent;     //是否以当前位置为地图中心
	NSArray *alarms;            //需要在地图上显示的
	
}

@property (nonatomic,retain) IBOutlet MKMapView* mapView;
@property (nonatomic,retain) IBOutlet UIView *maskView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic,assign) CLLocationCoordinate2D centerCoord;
@property (nonatomic,assign) BOOL centerWithcurrent;
@property (nonatomic,retain) NSArray *alarms;

@end
