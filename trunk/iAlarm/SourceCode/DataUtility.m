//
//  DataUtility.m
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataUtility.h"
#import "YCAlarmEntity.h"
#import "DicManager.h"
#import "YCPositionType.h"
#import "YCParam.h"

@implementation DataUtility

#define kFilename @"alarms.plist"
+ (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

+(NSString*) genSerialCode
{
	NSUInteger x = arc4random()/100;
	NSString *s = [NSString stringWithFormat:@"%d", time(NULL)];
	NSString *ss = [NSString stringWithFormat:@"%@%d",s,x];
	
	//[s stringByAppendingFormat:@"%d",x];
	return ss;
}


//取得所有闹钟的列表
+(NSMutableArray*) alarmArray
{
	static NSMutableArray *alarms;
	
	if (!alarms) {
		alarms  = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithFile:[DataUtility dataFilePath]];
		[alarms retain];//NSKeyedUnarchiver 读出的对象autorelease
		
		if (alarms ==nil) { //文件还不存在的时候（一个闹钟也没有的时候）
			alarms = [[NSMutableArray alloc] init];
		}
		for (NSUInteger i=0; i<[alarms count]; i++) {
			YCAlarmEntity *obj = (YCAlarmEntity *)[alarms objectAtIndex:i];
			obj.sound = [[DicManager soundDictionary] objectForKey:obj.soundId];
			obj.repeatType = [[DicManager repeatTypeDictionary] objectForKey:obj.repeatTypeId];
			obj.vehicleType = [[DicManager vehicleTypeDictionary] objectForKey:obj.vehicleTypeId];
		}
	}
	return alarms;
}


//保存闹钟列表
+(void) saveAlarmArray:(NSArray*)array
{
	[NSKeyedArchiver archiveRootObject:array toFile:[DataUtility dataFilePath]];
}

//根据一个默认条件，产生一个新闹钟
+(YCAlarmEntity*) createAlarm
{
	YCAlarmEntity *alarm = [[[YCAlarmEntity alloc] init] autorelease];
	alarm.alarmId = [DataUtility genSerialCode];
	alarm.alarmName = NSLocalizedString(@"位置闹钟",@"");
	alarm.positionType = [[DicManager positionTypeDictionary] objectForKey:@"p001"];
	alarm.position = @"";      
	alarm.description  = @"";              
	alarm.sortId = 0;       
	alarm.enabling = TRUE; 
	CLLocationCoordinate2D coor ={0.0,0.0};
	alarm.coordinate = coor;            
	alarm.vibrate = TRUE;
	alarm.ring = TRUE;
	
	alarm.sound = [[DicManager soundDictionary] objectForKey:@"s001"];
	alarm.repeatType = [[DicManager repeatTypeDictionary] objectForKey:@"r001"];
	alarm.vehicleType = [[DicManager vehicleTypeDictionary] objectForKey:@"v001"];
	
	alarm.radius = [[YCParam paramSingleInstance] radiusForAlarm];

	return alarm;
}

//取得alarm对象在Array中的索引
+(NSUInteger) alarmArray:(NSArray*)alarmArray alarmAtArray:(YCAlarmEntity*)alarm
{
	NSUInteger index = -1;
	for (NSInteger i=0; i<alarmArray.count; i++) {
		YCAlarmEntity* obj = [alarmArray objectAtIndex:i];
		if (obj==alarm) {
			index = i;
			break;
		}
	}
	return index;
}

//根据Id找到闹钟
+(YCAlarmEntity*) alarmArray:(NSArray*)alarmArray alarmId:(NSString*)alarmId
{
	YCAlarmEntity *result = nil;
	for (NSInteger i=0; i<alarmArray.count; i++) {
		YCAlarmEntity* obj = [alarmArray objectAtIndex:i];
		if ([obj.alarmId isEqualToString:alarmId]) {
			result = obj;
			break;
		}
	}
	return result;
	
}

@end
