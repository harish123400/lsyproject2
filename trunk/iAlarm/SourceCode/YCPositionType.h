//
//  YCPositionType.h
//  iArrived
//
//  Created by li shiyong on 10-10-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define    kpositionTypeId        @"kpositionTypeId"
#define    kpositionTypeName      @"kpositionTypeName"
#define    kpositionSortId        @"kpositionSortId"

@interface YCPositionType : NSObject {
	NSString *positionTypeId;         
	NSString *positionTypeName;
	NSUInteger sortId;    //排序
}

@property (nonatomic,retain) NSString *positionTypeId;
@property (nonatomic,retain) NSString *positionTypeName;
@property (nonatomic,assign) NSUInteger sortId;

@end
