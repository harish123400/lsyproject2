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
#import "YCParam.h"


@implementation YCLocationManagerDelegate

#define karrivedString NSLocalizedString(@"%@即将到达!\n大约距离:%.0f米",@"")
#define kleavedString NSLocalizedString(@"%@已经离开!\n大约距离:%.0f米",@"")
- (void)locationManager:(YCLocationManager *)manager didEnterRegion:(CLRegion *)region
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
	

	CLLocation *curLocation = manager.significantLocationManager.location;
	CLLocation *regLocation = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
	CLLocationDistance distance = [curLocation distanceFromLocation:regLocation];
	[regLocation release];
	
	//NSString *arrivedString = NSLocalizedString(@"%@即将到达!\n大约距离:%.0f",@"");
	NSString *notificationMsg = [[NSString alloc] initWithFormat:karrivedString,alarmName,distance];
	
	[UIUtility sendNotify:notificationMsg 
				notifyName:@"didEnterRegion" 
				 fireDate:nil
		   repeatInterval:0 
				soundName:soundName];
	[notificationMsg release];

}

- (void)locationManager:(YCLocationManager *)manager didExitRegion:(CLRegion *)region
{
	//关闭离开通知
	if([YCParam paramSingleInstance].closeLeaveNotify) return;

	NSArray *alarms = [DataUtility alarmArray];
	NSString *alarmId = region.identifier;
	YCAlarmEntity *alarm = [DataUtility alarmArray:alarms alarmId:alarmId];
	NSString *alarmName = alarm.alarmName;
	NSString *soundName = alarm.sound.soundName;
	
	CLLocation *curLocation = manager.significantLocationManager.location;
	CLLocation *regLocation = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
	CLLocationDistance distance = [curLocation distanceFromLocation:regLocation];
	[regLocation release];
	
	NSString *notificationMsg = [[NSString alloc] initWithFormat:kleavedString,alarmName,distance];
	
	[UIUtility sendNotify:notificationMsg 
				notifyName:@"didExitRegion" 
				 fireDate:nil
		   repeatInterval:0 
				soundName:soundName];
	[notificationMsg release];
	
}

@end
