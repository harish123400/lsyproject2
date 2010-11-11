//
//  YCRegion.h
//  iAlarm
//
//  Created by li shiyong on 10-11-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YCAlarmEntity;
@class CLRegion;
@interface YCRegion : NSObject {
	
	YCAlarmEntity *alarm;
	CLRegion *clRegion;
}

@property (nonatomic,retain) YCAlarmEntity *alarm;
@property (nonatomic,retain) CLRegion *clRegion;

@end
