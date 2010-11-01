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
#import "RegionCenter.h"


@implementation YCLocationManagerDelegate

- (void)locationManager:(YCLocationManager *)manager didEnterRegion:(CLRegion *)region
{
	UIApplication *app = [UIApplication sharedApplication];
	// Clear out the old notification before scheduling a new one.
	/*
	NSArray *oldNotifications = [app scheduledLocalNotifications];
	if (0 < [oldNotifications count]) {
		[app cancelAllLocalNotifications];
	}
	 */
	
	
	NSArray *alarms = [DataUtility alarmArray];
	NSString *alarmId = region.identifier;
	YCAlarmEntity *alarm = [DataUtility alarmArray:alarms alarmId:alarmId];
	NSString *alarmName = alarm.alarmName;
	
	NSString *arrivedString = NSLocalizedString(@"已经到了!",@"");
	NSString *notificationMsg = [[NSString alloc] initWithFormat:@"%@%@",alarmName,arrivedString];

	
	// Create a new notification
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.repeatInterval = 0;
	notification.soundName = @"ping.caf";//@"default";
	notification.alertBody = notificationMsg;
	notification.userInfo = [NSDictionary dictionaryWithObject:@"didEnterRegion"forKey:@"name"];
	[notificationMsg release];
	
	

	[app scheduleLocalNotification:notification];
	[notification release];

	
}

- (void)locationManager:(YCLocationManager *)manager didExitRegion:(CLRegion *)region
{
	UIApplication *app = [UIApplication sharedApplication];

	
	NSArray *alarms = [DataUtility alarmArray];
	NSString *alarmId = region.identifier;
	YCAlarmEntity *alarm = [DataUtility alarmArray:alarms alarmId:alarmId];
	NSString *alarmName = alarm.alarmName;
	
	//只闹一次
	if ([alarm.repeatType.repeatTypeId isEqualToString:@"r002"]) 
	{
		alarm.enabling = NO;
		[[[RegionCenter regionCenterSingleInstance] regions]removeObject:alarm];
	}
	
	NSString *arrivedString = NSLocalizedString(@"已经离开!",@"");
	NSString *notificationMsg = [[NSString alloc] initWithFormat:@"%@%@",alarmName,arrivedString];
	
	
	// Create a new notification
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.repeatInterval = 0;
	notification.soundName = @"ping.caf";//@"default";
	notification.alertBody = notificationMsg;
	notification.userInfo = [NSDictionary dictionaryWithObject:@"didExitRegion"forKey:@"name"];
	[notificationMsg release];
	
	
	
	[app scheduleLocalNotification:notification];
	[notification release];
	
}

@end
