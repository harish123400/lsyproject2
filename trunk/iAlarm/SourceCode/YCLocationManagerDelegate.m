//
//  YCLocationManagerDelegate.m
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCLocationManagerDelegate.h"
#import "DataUtility.h"
#import "YCAlarmEntity.h"
#import "YCRepeatType.h"
#import "RegionsCenter.h"
#import "YCSound.h"
#import "UIUtility.h"


@implementation YCLocationManagerDelegate

- (void)locationManager:(YCLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	NSArray *alarms = [DataUtility alarmArray];
	NSString *alarmId = region.identifier;
	YCAlarmEntity *alarm = [DataUtility alarmArray:alarms alarmId:alarmId];
	NSString *alarmName = alarm.alarmName;
	NSString *soundName = alarm.sound.soundName;
	
	NSString *arrivedString = NSLocalizedString(@"已经到了!",@"");
	NSString *notificationMsg = [[NSString alloc] initWithFormat:@"%@%@",alarmName,arrivedString];
	
	[UIUtility sendNotify:notificationMsg 
				notifyName:@"didEnterRegion" 
				 fireDate:nil
		   repeatInterval:0 
				soundName:soundName];

}

- (void)locationManager:(YCLocationManager *)manager didExitRegion:(CLRegion *)region
{

	NSArray *alarms = [DataUtility alarmArray];
	NSString *alarmId = region.identifier;
	YCAlarmEntity *alarm = [DataUtility alarmArray:alarms alarmId:alarmId];
	NSString *alarmName = alarm.alarmName;
	NSString *soundName = alarm.sound.soundName;
	
	//只闹一次
	if ([alarm.repeatType.repeatTypeId isEqualToString:@"r002"]) 
	{
		alarm.enabling = NO;
		[[[RegionsCenter regionCenterSingleInstance] regions]removeObject:alarm];
	}
	
	NSString *arrivedString = NSLocalizedString(@"已经离开!",@"");
	NSString *notificationMsg = [[NSString alloc] initWithFormat:@"%@%@",alarmName,arrivedString];
	
	[UIUtility sendNotify:notificationMsg 
				notifyName:@"didExitRegion" 
				 fireDate:nil
		   repeatInterval:0 
				soundName:soundName];
	
}

@end
