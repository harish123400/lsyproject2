//
//  YCAlarmEntity.h
//  iArrived
//
//  Created by li shiyong on 10-10-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#define    kalarmId                 @"kalarmId"
#define    kalarmName               @"kalarmName"
#define    kposition                @"kposition"
#define    kpositionShort           @"kpositionShort"
#define    kdescription             @"kdescription"
#define    ksortId                  @"ksortId"
#define    kenabling                @"kenabling"
#define    kcoordinate              @"kcoordinate"
#define    kvibration               @"kvibration"
#define    kring                    @"kring"
#define    knameChanged             @"knameChanged"
#define    kasoundId                @"kasoundId"
#define    karepeatTypeId           @"karepeatTypeId"
#define    kavehicleTypeId          @"kavehicleTypeId"
#define    kradius                  @"kradius"
#define    klocationAccuracy        @"klocationAccuracy"

@class YCSound;
@class YCRepeatType;
@class YCVehicleType;
@class YCPositionType;
@interface YCAlarmEntity : NSObject <NSCoding, NSCopying> {
	
	NSString *alarmId;         
	NSString *alarmName;            
	NSString *position;                      //地点，使用MapKit取得
	NSString *positionShort;                 //短地点
	NSString *description;                   //描述
	NSUInteger sortId;                       //排序，用于界面显示
	BOOL enabling;                           //启用状态
	CLLocationCoordinate2D coordinate;       //坐标
	CLLocationAccuracy locationAccuracy;     //定位时候的精度
	
	BOOL vibrate;                            //是否震动
	BOOL ring;                               //是否静音
	BOOL nameChanged;                        //闹钟名字是否被用户自己修改过
	YCPositionType *positionType;            //位置类型 当前位置，地图指定位置
	YCSound *sound;                          //声音
	YCRepeatType *repeatType;                //重复类型，一次，二次，永远
	YCVehicleType *vehicleType;              //公交，地铁等等
	NSString *soundId;
	NSString *repeatTypeId;
	NSString *vehicleTypeId;
	CLLocationDistance radius;               //半径
	
	
}

@property (nonatomic,retain) NSString *alarmId;
@property (nonatomic,retain) NSString *alarmName;
@property (nonatomic,retain) NSString *position;
@property (nonatomic,retain) NSString *positionShort;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) YCPositionType *positionType;
@property (nonatomic,retain) YCSound *sound;
@property (nonatomic,retain) YCRepeatType *repeatType;
@property (nonatomic,retain) YCVehicleType *vehicleType;
@property (nonatomic,retain) NSString *soundId;
@property (nonatomic,retain) NSString *repeatTypeId;
@property (nonatomic,retain) NSString *vehicleTypeId;


@property (nonatomic,assign) NSUInteger sortId;
@property (nonatomic,assign) BOOL enabling;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,assign) CLLocationAccuracy locationAccuracy;
@property (nonatomic,assign) BOOL vibrate;
@property (nonatomic,assign) BOOL ring;
@property (nonatomic,assign) BOOL nameChanged;
@property (nonatomic,assign) CLLocationDistance radius;

//-(id)initWithDefault;

@end


