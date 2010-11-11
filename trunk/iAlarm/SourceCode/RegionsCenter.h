//
//  RegionCenter.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RegionsCenter : NSObject {
	NSMutableArray *regions;                    //所有需要监控的区域
	NSMutableDictionary *regionsForContainsLastLocation; //上一次定位的点所在的区域（“最后所在区域”）
}
@property(readonly, nonatomic)NSMutableArray *regions;
@property(readonly, nonatomic)NSMutableDictionary *regionsForContainsLastLocation;

+(RegionsCenter*)regionCenterSingleInstance;

@end
