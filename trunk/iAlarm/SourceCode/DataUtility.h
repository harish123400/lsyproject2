//
//  DataUtility.h
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YCAlarmEntity;

@interface DataUtility : NSObject {

}

//产生一个唯一的序列号
+(NSString*) genSerialCode;
//取得所有闹钟的列表
+(NSMutableArray*) alarmArray;
//根据一个默认条件，产生一个新闹钟
+(YCAlarmEntity*) createAlarm;
//保存闹钟列表
+(void) saveAlarmArray:(NSArray*)array;

//取得alarm对象在Array中的索引
+(NSUInteger) alarmArray:(NSArray*)alarmArray alarmAtArray:(YCAlarmEntity*)alarm;

//根据Id找到闹钟
+(YCAlarmEntity*) alarmArray:(NSArray*)alarmArray alarmId:(NSString*)alarmId;

@end
