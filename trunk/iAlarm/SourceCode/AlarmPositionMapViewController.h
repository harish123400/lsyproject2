//
//  AlarmPositionMapViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModifyViewController.h"
#import "YCNavSuperControllerProtocol.h"
#import "BSForwardGeocoder.h"
#import "YCSearchController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@class YCAnnotation;
@class AlarmNameViewController;
@interface AlarmPositionMapViewController : AlarmModifyViewController 
<MKMapViewDelegate,MKReverseGeocoderDelegate,YCNavSuperControllerProtocol,BSForwardGeocoderDelegate,UIAlertViewDelegate,YCSearchControllerDelegete>
{
	NSTimer *myTimer;
	
	MKReverseGeocoder *reverseGeocoder;
	BSForwardGeocoder *forwardGeocoder;
	YCSearchController *searchController;
	
	IBOutlet MKMapView* mapView;            
	IBOutlet UIControl *maskView;                           //覆盖View
	IBOutlet UIControl *curlView;                           //地图卷起后，显示的view
	IBOutlet UIView *curlbackgroundView;                    //maskView,curlView的背景view。做卷起动画时候需要
	IBOutlet UIActivityIndicatorView *activityIndicator;    //覆盖View上的等待指示器
	IBOutlet UISearchBar *searchBar;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UISegmentedControl *mapTypeSegmented;          //curlView上的按钮控件
	IBOutlet UIBarButtonItem *currentLocationBarItem;       //地图转到－>当前位置
	IBOutlet UIBarButtonItem *currentPinBarItem;            //地图转到－>当前图钉
	IBOutlet UIBarButtonItem *searchBarItem;                //显示搜索bar
	IBOutlet UIBarButtonItem *resetPinBarItem;              //重放当前图钉
	IBOutlet UIBarButtonItem *pageCurlBarItem;              //卷起地图
	UIBarButtonItem *locationingBarItem;                    //显示正在定位的指示器的barItem
	
	BOOL regionCenterWithCurrentLocation;  //初始化时候使用当前位置作为地图的中心点
	BOOL newAlarm;                //新创建的Alarm
	BOOL isFirstShow;             //第一次显示
	BOOL isAlreadyCenterCoord;    //中心坐标是否准备好
	BOOL isCurl;                  //是否已经半卷
	BOOL isCurrentLocationAtCenterRegion;   //当前位置在中心
	BOOL isCurrentPinAtCenterRegion;        //当前图钉在中心
	//BOOL searching;                         //数据查询中
	
	MKCoordinateRegion defaultMapRegion;   //地图的可视范围，设置该变量方便代码编写
	NSArray *alarms;                       //需要在地图上显示的
	NSMutableArray *mapAnnotations;        //地图标签集合
	YCAlarmEntity *alarmTemp;
	YCAnnotation *annotationAlarmEditing;  //编辑中的Alarm的annotation
	id<MKAnnotation> annotationManipulating;  //正在操作的
	
}

@property (nonatomic,retain) IBOutlet MKMapView* mapView;
@property (nonatomic,retain) IBOutlet UIControl *maskView;
@property (nonatomic,retain) IBOutlet UIControl *curlView;
@property (nonatomic,retain) IBOutlet UIView *curlbackgroundView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic,retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic,retain) IBOutlet UISegmentedControl *mapTypeSegmented;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *currentLocationBarItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *currentPinBarItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *searchBarItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *resetPinBarItem;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *pageCurlBarItem;
@property (nonatomic,retain,readonly) UIBarButtonItem *locationingBarItem;

@property (nonatomic,retain) BSForwardGeocoder *forwardGeocoder;
@property (nonatomic,retain) YCSearchController *searchController;
@property (nonatomic,assign) BOOL regionCenterWithCurrentLocation;
@property (nonatomic,assign) BOOL newAlarm;
@property (nonatomic,retain) NSArray *alarms;
@property (nonatomic,retain) YCAlarmEntity *alarmTemp;
@property (nonatomic,retain) NSMutableArray *mapAnnotations;
@property (nonatomic,retain) YCAnnotation *annotationAlarmEditing;
@property (nonatomic,retain) id<MKAnnotation> annotationManipulating;


-(IBAction)currentLocationButtonPressed:(id)sender;
-(IBAction)resetPinButtonPressed:(id)sender;
-(IBAction)currentPinButtonPressed:(id)sender;
-(IBAction)searchButtonPressed:(id)sender;
-(IBAction)pageCurlButtonPressed:(id)sender;
-(IBAction)mapTypeSegmentedChanged:(id)sender;

/////////////////////////////////////////////
//private函数
////显示覆盖视图
-(void)showMaskView;
////关掉覆盖视图
-(void)closeMaskViewWithAnimated:(BOOL)animated;
////显示地图
//-(void)showMapView;

/////////////////////////////////////////////


@end
