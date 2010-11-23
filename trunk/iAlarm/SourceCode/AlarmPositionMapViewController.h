//
//  AlarmPositionMapViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModifyViewController.h"
#import "YCNavSuperControllerProtocol.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@class YCAnnotation;
@class AlarmNameViewController;
@interface AlarmPositionMapViewController : AlarmModifyViewController 
<MKMapViewDelegate,MKReverseGeocoderDelegate,YCNavSuperControllerProtocol,UISearchBarDelegate>
{
	NSTimer *myTimer;
	
	MKMapView* mapView;
	UIControl *maskView;
	UIActivityIndicatorView *activityIndicator;
	IBOutlet UISearchBar *searchBar;
	

	MKCoordinateRegion defaultMapRegion;
	BOOL isFirstShow;
	BOOL isAlreadyCenterCoord;    //中心坐标是否准备好

	NSArray *alarms;            //需要在地图上显示的
	
	//BOOL enablingNeting;        //网络是否可用
	//BOOL enablingLocation;      //定位是否可用
	
	NSMutableArray *mapAnnotations;  //地图标签集合
	
	//BOOL isInTab;                  //视图是在Tab上显示的
	
	MKReverseGeocoder *reverseGeocoder;
	
	//YCAnnotation *dragingAnnotation; 
	
	UIBarButtonItem *currentLocationBarItem;
	UIBarButtonItem *currentPinBarItem;
	UIBarButtonItem *searchBarItem;
	
	BOOL isCurrentLocationAtCenterRegion;   //当前位置在中心
	BOOL isCurrentPinAtCenterRegion;        //当前图钉在中心
	
	BOOL newAlarm;  //新创建的Alarm
	
	YCAnnotation *annotationManipulating;  //正在操作的
	
	YCAlarmEntity *alarmTemp;
	
	
	
}

@property (nonatomic,retain) IBOutlet MKMapView* mapView;
@property (nonatomic,retain) IBOutlet UIControl *maskView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *currentLocationBarItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *currentPinBarItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *searchBarItem;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;


//@property (nonatomic,assign) BOOL isCenterWithcurrent;
@property (nonatomic,retain) NSArray *alarms;

//@property (nonatomic,assign) BOOL enablingNeting;
//@property (nonatomic,assign) BOOL enablingLocation;

@property (nonatomic,retain) NSMutableArray *mapAnnotations;
@property (nonatomic,assign) BOOL newAlarm;

@property (nonatomic,retain) YCAnnotation *annotationManipulating;

@property (nonatomic,retain) YCAlarmEntity *alarmTemp;


-(IBAction)currentLocationButtonPressed:(id)sender;
-(IBAction)resetPinButtonPressed:(id)sender;
-(IBAction)currentPinButtonPressed:(id)sender;
-(IBAction)searchButtonPressed:(id)sender;
-(IBAction)cancelSearchButtonPressed:(id)sender;

//缓存地图数据
-(void)cacheMapData;
//显示覆盖视图
-(void)showMaskView;
//关掉覆盖视图
-(void)closeMaskViewWithAnimated:(BOOL)animated;
//显示地图
-(void)showMapView;


@end
