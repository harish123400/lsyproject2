//
//  LocationUtility.h
//  iArrived
//
//  Created by li shiyong on 10-10-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationUtility : NSObject {

}


//区域 是否在 “区域”列表中
+(BOOL) includeRegion:(CLRegion*)theRegion atRegions:(NSDictionary*)regions;
+(BOOL) includeRegion:(CLRegion*)theRegion atRegionArray:(NSArray*)regions;

//指定位置(theLocation) 大于 “区域”列表(atRegions)中的“任一”区域的半径
//YES:有符合条件的区域
+(BOOL) includeNoContainsLocation:(CLLocation*)theLocation atRegions:(NSArray*)atRegions;

//指定位置 与 "区域"列表中的“任一”区域的中心距离  < 预警示设定距离
//+(BOOL) lessDistance:(CLLocationDistance)distance location:(CLLocation*)theLocation atRegions:(NSArray*)regions;

//指定位置(theLocation) 与 "所有区域"列表(atRegions) 中心的距离 小于 预警示设定距离;而且该区域 不在 noRegions列表中
//YES:有符合条件的区域
+(BOOL) includeLessDistance:(CLLocationDistance)distance location:(CLLocation*)theLocation atRegions:(NSArray*)regions noRegions:(NSDictionary*) noRegions;

//指定位置(theLocation) 包含在 "所有区域"列表(atRegions)的半径中;而且该区域 不在 noRegions列表中 
//返回：符合条件的"区域列表"
+(NSArray*) containsLocation:(CLLocation*)theLocation atRegions:(NSArray*)regions noRegions:(NSDictionary*) noRegions;

//指定位置(theLocation) 不包含在 "所有区域"列表(atRegions)的半径中; 
//返回：符合条件的"区域列表"
+(NSArray*) noContainsLocation:(CLLocation*)theLocation atRegions:(NSArray*)regions;







@end
