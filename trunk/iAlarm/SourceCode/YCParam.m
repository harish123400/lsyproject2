//
//  YCParam.m
//  iArrived
//
//  Created by li shiyong on 10-10-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCParam.h"


@implementation YCParam


@synthesize radiusForAlarm;
@synthesize distanceForProAlarm;
@synthesize desiredAccuracyForStartStandardLocation;
@synthesize intervalForStartStandardLocation;

@synthesize enableOffset;
@synthesize offsetCoordinateOfMap;


+(YCParam*) paramSingleInstance
{
	static YCParam* obj = nil;
	if (obj == nil) {
		obj = [[YCParam alloc] init];
		obj.radiusForAlarm = 800.0;
		obj.distanceForProAlarm = 2000.0;
		obj.desiredAccuracyForStartStandardLocation = kCLLocationAccuracyNearestTenMeters;
		obj.intervalForStartStandardLocation = 60;
		obj.enableOffset = NO;
		CLLocationCoordinate2D tmp  = {0.0,0.0};
		obj.offsetCoordinateOfMap = tmp;
		
		[obj retain];
	}
	
	return obj;
	
}

- (void)dealloc {
    [super dealloc];
}

@end
