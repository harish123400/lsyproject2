//
//  YCParam.h
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>


@interface YCParam : NSObject {
	
	CLLocationDistance radiusForAlarm;                          //提示距离，距离多远时候进行提示
	CLLocationDistance distanceForProAlarm;        //距离多远，启动Standard Location服务
	CLLocationAccuracy desiredAccuracyForStartStandardLocation; //Standard Location服务的精度
	NSTimeInterval     intervalForStartStandardLocation;        //过了多久，启动Standard Location服务
	
	BOOL enableOffset;                             //是否启用偏移坐标
	CLLocationCoordinate2D offsetCoordinateOfMap;  //地图的偏移坐标
	
	
	CLLocationDistance invalidLocationAccuracy;    //无效定位精度阀值
	
	NSTimeInterval     timeSpanForStandardLocation;  //标准定位持续时间
	BOOL enableOfAllLocAlarms;                        //是否启用所有闹钟
	BOOL ignoreEdgeMoving;                           //是否忽略边缘活动
	CLLocationDistance edgeDistance;                 //边缘的距离
	
	
	BOOL closeLeaveNotify;                           //关闭离开通知
	MKCoordinateSpan defaultMapSpan;                 //默认的地图显示比例

}

@property (nonatomic,assign) CLLocationDistance radiusForAlarm;
@property (nonatomic,assign) CLLocationDistance distanceForProAlarm;
@property (nonatomic,assign) CLLocationAccuracy desiredAccuracyForStartStandardLocation;
@property (nonatomic,assign) NSTimeInterval     intervalForStartStandardLocation;
@property (nonatomic,assign) BOOL enableOffset;
@property (nonatomic,assign) CLLocationCoordinate2D offsetCoordinateOfMap;
@property (nonatomic,assign) CLLocationDistance invalidLocationAccuracy;

@property (nonatomic,assign) NSTimeInterval     timeSpanForStandardLocation;
@property (nonatomic,assign) BOOL enableOfAllLocAlarms;    
@property (nonatomic,assign) BOOL ignoreEdgeMoving; 
@property (nonatomic,assign) CLLocationDistance edgeDistance;
@property (nonatomic,assign) BOOL closeLeaveNotify;
@property (nonatomic,assign) MKCoordinateSpan defaultMapSpan;

+(YCParam*) paramSingleInstance;
+(void)updateParam;

@end
