//
//  RegionCenter.m
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RegionsCenter.h"


@implementation RegionsCenter

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

+(RegionsCenter*)regionCenterSingleInstance
{
	static RegionsCenter *regionCenter =nil;
	if (regionCenter == nil) {
		regionCenter = [[RegionsCenter alloc] init];
	}
	return regionCenter;
}


@end
