//
//  YCParam.m
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCParam.h"
#import "DataUtility.h"
#import "UIUtility.h"
#import "YCAlarmEntity.h"

@implementation YCParam


@synthesize radiusForAlarm;
@synthesize distanceForProAlarm;
@synthesize desiredAccuracyForStartStandardLocation;
@synthesize intervalForStartStandardLocation;

@synthesize enableOffset;
@synthesize offsetCoordinateOfMap;
@synthesize invalidLocationAccuracy;

@synthesize timeSpanForStandardLocation;  
@synthesize enableOfAllLocAlarms;                        
@synthesize ignoreEdgeMoving;                           


+(YCParam*) paramSingleInstance
{
	static YCParam* obj = nil;
	if (obj == nil) {
		obj = [[YCParam alloc] init];
		obj.radiusForAlarm = 800.0;
		obj.distanceForProAlarm = 2000.0;
		obj.desiredAccuracyForStartStandardLocation = kCLLocationAccuracyNearestTenMeters;
		obj.intervalForStartStandardLocation = 90.0;
		obj.enableOffset = NO;
		CLLocationCoordinate2D tmp  = {0.0,0.0};
		obj.offsetCoordinateOfMap = tmp;
		obj.invalidLocationAccuracy = 1000.0;
		
		obj.timeSpanForStandardLocation = 3.0;
		obj.enableOfAllLocAlarms = YES;
		obj.ignoreEdgeMoving = YES;
		
		[obj retain];
	}
	
	return obj;
	
}

+(void)updateParam
{
	//半径 Debug
	NSArray * alarms = [DataUtility alarmArray];
	for (NSUInteger i=0; i<alarms.count; i++) {
		YCAlarmEntity *alarm = [alarms objectAtIndex:i];
		alarm.radius = [self paramSingleInstance].radiusForAlarm;
	}
	[DataUtility saveAlarmArray:alarms];
	
	[UIUtility sendNotifyForAlart:nil notifyName :@"updateParam"];
	
}

- (void)dealloc {
    [super dealloc];
}

@end
