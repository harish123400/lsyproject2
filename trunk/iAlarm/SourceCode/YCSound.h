//
//  YCSounds.h
//  iArrived
//
//  Created by li shiyong on 10-10-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define    ksoundId        @"ksoundId"
#define    ksoundName      @"ksoundName"

@interface YCSound : NSObject <NSCoding, NSCopying>{
	NSString *soundId;         
	NSString *soundName;
}

@property (nonatomic,retain) NSString *soundId;
@property (nonatomic,retain) NSString *soundName;

@end
