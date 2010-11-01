//
//  YCRepeatTypes.h
//  iArrived
//
//  Created by li shiyong on 10-10-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define    krepeatTypeId        @"krepeatTypeId"
#define    krepeatTypeName      @"krepeatTypeName"
#define    ksortId              @"ksortId"

@interface YCRepeatType : NSObject <NSCoding, NSCopying>{
	NSString *repeatTypeId;         
	NSString *repeatTypeName;
	NSUInteger sortId;    //排序
}

@property (nonatomic,retain) NSString *repeatTypeId;
@property (nonatomic,retain) NSString *repeatTypeName;
@property (nonatomic,assign) NSUInteger sortId;

@end
