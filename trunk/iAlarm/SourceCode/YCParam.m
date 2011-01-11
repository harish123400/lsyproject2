//
//  YCParam.m
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSCoder-YC.h"
#import "YCParam.h"
#import "DataUtility.h"
#import "UIUtility.h"
#import "YCAlarmEntity.h"

@implementation YCParam


@synthesize radiusForAlarm;
@synthesize distanceForProAlarm;
@synthesize desiredAccuracyForStartStandardLocation;
@synthesize intervalForStartStandardLocation;
@synthesize invalidLocationAccuracy;
@synthesize timeSpanForStandardLocation;  
@synthesize enableOfAllLocAlarms;                        
@synthesize ignoreEdgeMoving; 
@synthesize edgeDistance;
@synthesize closeLeaveNotify;
@synthesize defaultMapSpan;

@synthesize enableOffset;
@synthesize offsetCoordinateOfMap;
@synthesize lastTimeStampOfOffset;                 
@synthesize validDistanceOfOffset; 
@synthesize lastLoadMapRegion;

#define kParamFilename @"param.plist"
+ (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kParamFilename];
}

+(YCParam*) paramSingleInstance
{
	static YCParam* obj = nil;
	if (obj == nil) {
		obj = (YCParam*)[NSKeyedUnarchiver unarchiveObjectWithFile:[YCParam dataFilePath]];
		if (obj == nil) {
			obj = [[YCParam alloc] init];
			obj.lastLoadMapRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(-1000,-1000), MKCoordinateSpanMake(0, 0));
		}

		obj.radiusForAlarm = 1200.0;
		obj.distanceForProAlarm = 2000.0;
		obj.desiredAccuracyForStartStandardLocation = kCLLocationAccuracyNearestTenMeters;
		obj.intervalForStartStandardLocation = 60.0;

		obj.invalidLocationAccuracy = 1200.0;
		
		obj.timeSpanForStandardLocation = 3.0;
		obj.enableOfAllLocAlarms = YES;
		obj.ignoreEdgeMoving = YES;
		obj.edgeDistance = 150;
		obj.closeLeaveNotify = NO;
		MKCoordinateSpan tmpSpan = {0.0112872,0.0109863};
		obj.defaultMapSpan = tmpSpan;
		
		obj.enableOffset = NO;
		CLLocationCoordinate2D tmp  = {0.0,0.0};
		obj.offsetCoordinateOfMap = tmp;
		obj.lastTimeStampOfOffset = nil;
		obj.validDistanceOfOffset = 5000.0;
		
		
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

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeMKCoordinateRegion:lastLoadMapRegion forKey:klastLoadMapRegion];
}

- (id)initWithCoder:(NSCoder *)decoder {
	
    if (self = [super init]) {		
		self.lastLoadMapRegion = [decoder decodeMKCoordinateRegionForKey:klastLoadMapRegion];
    }
    return self;
}



-(void)saveParam{
	[NSKeyedArchiver archiveRootObject:self toFile:[YCParam dataFilePath]];
}




- (void)dealloc {
	[lastTimeStampOfOffset release];
    [super dealloc];
}

@end
