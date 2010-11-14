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
#import <CoreLocation/CoreLocation.h>


@class YCAnnotation;
@interface AlarmPositionMapViewController : AlarmModifyViewController 
<MKMapViewDelegate,MKReverseGeocoderDelegate>
{
	NSTimer *myTimer;
	
	MKMapView* mapView;
	UIView *maskView;
	UIActivityIndicatorView *activityIndicator;
	

	MKCoordinateRegion defaultMapRegion;
	BOOL isFirstShow;
	BOOL isAlreadyCenterCoord;    //中心坐标是否准备好

	NSArray *alarms;            //需要在地图上显示的
	
	BOOL enablingNeting;        //网络是否可用
	BOOL enablingLocation;      //定位是否可用
	
	NSMutableArray *mapAnnotations;  //地图标签集合
	
	BOOL isInTab;                  //视图是在Tab上显示的
	
	MKReverseGeocoder *reverseGeocoder;
	
	YCAnnotation *dragingAnnotation; 
	
}

@property (nonatomic,retain) IBOutlet MKMapView* mapView;
@property (nonatomic,retain) IBOutlet UIView *maskView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;

-(IBAction)currentLocationButtonPressed:(id)sender;

//@property (nonatomic,assign) BOOL isCenterWithcurrent;
@property (nonatomic,retain) NSArray *alarms;

@property (nonatomic,assign) BOOL enablingNeting;
@property (nonatomic,assign) BOOL enablingLocation;

@property (nonatomic, retain) NSMutableArray *mapAnnotations;

//缓存地图数据
-(void)cacheMapData;
//显示覆盖视图
-(void)showMaskView;
//关掉覆盖视图
-(void)closeMaskViewWithAnimated:(BOOL)animated;
//显示地图
-(void)showMapView;


@end
