//
//  LocationUtility.m
//  iArrived
//
//  Created by li shiyong on 10-10-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocationUtility.h"
//#import "StandardManagerDelegate.h"
//#import "SignificantManagerDelegate.h"


@implementation LocationUtility

//区域 是否在 “区域”列表中
+(BOOL) includeRegion:(CLRegion*)theRegion atRegions:(NSDictionary*)regions
{
	CLRegion *tmp = [regions objectForKey:theRegion.identifier];
	return tmp !=nil ? YES : NO ;
}

+(BOOL) includeRegion:(CLRegion*)theRegion atRegionArray:(NSArray*)regions
{
	BOOL result = NO;
	for (NSUInteger i = 0; i< regions.count; i++) {
		CLRegion * region = [regions objectAtIndex:i];
		if ([theRegion.identifier isEqualToString:region.identifier]) {
			result = YES;
			break;
		}
	}
	return result;
}


//指定位置 与 “区域”列表中的“任一”区域的中心距离 >  “任一”区域的半径
+(BOOL) includeNoContainsLocation:(CLLocation*)theLocation atRegions:(NSArray*)atRegions
{
	BOOL result = NO;
	for (NSUInteger i = 0; i< atRegions.count; i++) {
		CLRegion * region = [atRegions objectAtIndex:i];
		BOOL isContain = [region containsCoordinate:theLocation.coordinate];
		if (!isContain) {
			result = YES;
			break;
		}
	}
	return result;
}

/*
//指定位置 与 "区域"列表中的“任一”区域的中心距离  < 预警示设定距离
+(BOOL) lessDistance:(CLLocationDistance)distance 
			location:(CLLocation*)theLocation 
		   atRegions:(NSArray*)regions;
{
	BOOL result = NO;
	for (NSUInteger i = 0; i< regions.count; i++) {
		CLRegion *region = [regions objectAtIndex:i];
		CLLocation *regionLocation = [[CLLocation alloc] initWithLatitude:region.center.latitude 
																longitude:region.center.longitude];
		CLLocationDistance distanceFromRegion = [theLocation distanceFromLocation:regionLocation];
		
		BOOL isNear = distanceFromRegion <= distance;
		if (isNear) {
			result = YES;
			break;
		}
	}
	return result;
}
 */

//指定位置 与 "所有区域"列表（不在“包含最后区域”列表中）中的“任一”区域的中心距离  < 预警示设定距离 
+(BOOL) includeLessDistance:(CLLocationDistance)distance 
			location:(CLLocation*)theLocation 
		   atRegions:(NSArray*)regions 
		   noRegions:(NSDictionary*) noRegions
{
	BOOL result = NO;
	for (NSUInteger i = 0; i< regions.count; i++) {
		CLRegion *region = [regions objectAtIndex:i];
		
		//区域是否在“包含最后区域”列表中
		BOOL include = [LocationUtility includeRegion:region atRegions:noRegions];
		if(include) continue;
		
		CLLocation *regionLocation = [[CLLocation alloc] initWithLatitude:region.center.latitude 
																longitude:region.center.longitude];
		CLLocationDistance distanceFromRegion = [theLocation distanceFromLocation:regionLocation];
		
		BOOL isNear = distanceFromRegion <= distance;
		if (isNear) {
			result = YES;
			break;
		}
	}
	return result;
}

//指定位置 与 "所有区域"列表（不在“包含最后区域”列表中）中的“任一”区域的中心距离  < 区域半径; 
//返回：符合条件的"区域列表"
+(NSArray*) containsLocation:(CLLocation*)theLocation 
				   atRegions:(NSArray*)regions 
				   noRegions:(NSDictionary*) noRegions
{
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	
	for (NSUInteger i = 0; i< regions.count; i++) {
		CLRegion * region = [regions objectAtIndex:i];
		
		//区域是否在“包含最后区域”列表中
		BOOL include = [LocationUtility includeRegion:region atRegions:noRegions];
		if(include) continue;
		
		BOOL isContain = [region containsCoordinate:theLocation.coordinate];
		if (isContain) [array addObject:region];
		
	}
	
	return array;
}

+(NSArray*) noContainsLocation:(CLLocation*)theLocation atRegions:(NSArray*)regions
{
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	
	for (NSUInteger i = 0; i< regions.count; i++) {
		CLRegion * region = [regions objectAtIndex:i];
		
		BOOL isContain = [region containsCoordinate:theLocation.coordinate];
		if (!isContain) [array addObject:region];
	}
	
	return array;
}





@end
