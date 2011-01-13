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

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */

+ (NSString *)applicationDocumentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
- (NSString *)applicationDocumentsDirectory {
	return [YCParam applicationDocumentsDirectory];
}


+(YCParam*) paramSingleInstance
{
	static YCParam* obj = nil;
	if (obj == nil) {
		NSString *filePathName = [[YCParam applicationDocumentsDirectory] stringByAppendingPathComponent:kParamFilename];
		obj = [(YCParam*)[NSKeyedUnarchiver unarchiveObjectWithFile:filePathName] retain];
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
		
		
	}
	
	return obj;
}



#pragma mark -
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



-(void)saveParam{
	NSString *filePathName = [self.applicationDocumentsDirectory stringByAppendingPathComponent:kParamFilename];
	[NSKeyedArchiver archiveRootObject:self toFile:filePathName];
}




- (void)dealloc {
	[lastTimeStampOfOffset release];
    [super dealloc];
}



@end
