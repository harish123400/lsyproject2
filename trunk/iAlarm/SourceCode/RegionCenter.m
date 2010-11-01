//
//  RegionCenter.m
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RegionCenter.h"


@implementation RegionCenter

-(NSMutableArray*)regions
{
	if (regions == nil) {
		regions = [[NSMutableArray alloc] init];
	}
	return regions;
}

-(NSMutableDictionary *)regionsForContainsLastLocation
{
	if (regionsForContainsLastLocation == nil) {
		regionsForContainsLastLocation = [[NSMutableDictionary alloc] init];
	}
	return regionsForContainsLastLocation;
}

+(RegionCenter*)regionCenterSingleInstance
{
	static RegionCenter *regionCenter =nil;
	if (regionCenter == nil) {
		regionCenter = [[RegionCenter alloc] init];
	}
	return regionCenter;
}


@end
