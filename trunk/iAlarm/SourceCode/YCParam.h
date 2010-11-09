//
//  YCParam.h
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface YCParam : NSObject {
	
	CLLocationDistance radiusForAlarm;                          //提示距离，距离多远时候进行提示
	CLLocationDistance distanceForProAlarm;        //距离多远，启动Standard Location服务
	CLLocationAccuracy desiredAccuracyForStartStandardLocation; //Standard Location服务的精度
	NSTimeInterval     intervalForStartStandardLocation;        //过了多久，启动Standard Location服务
	
	BOOL enableOffset;                             //是否启用偏移坐标
	CLLocationCoordinate2D offsetCoordinateOfMap;  //地图的偏移坐标
	
	
	CLLocationDistance invalidLocationAccuracy;    //无效定位精度

}

@property (nonatomic,assign) CLLocationDistance radiusForAlarm;
@property (nonatomic,assign) CLLocationDistance distanceForProAlarm;
@property (nonatomic,assign) CLLocationAccuracy desiredAccuracyForStartStandardLocation;
@property (nonatomic,assign) NSTimeInterval     intervalForStartStandardLocation;



@property (nonatomic,assign) BOOL enableOffset;
@property (nonatomic,assign) CLLocationCoordinate2D offsetCoordinateOfMap;
@property (nonatomic,assign) CLLocationDistance invalidLocationAccuracy;

+(YCParam*) paramSingleInstance;
+(void)updateParam;

@end
