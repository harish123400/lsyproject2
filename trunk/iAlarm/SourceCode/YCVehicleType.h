//
//  YCVehicleType.h
//  iArrived
//
//  Created by li shiyong on 10-10-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define    kvehicleTypeId        @"kvehicleTypeId"
#define    kvehicleTypeName      @"kvehicleTypeName"

@interface YCVehicleType : NSObject <NSCoding, NSCopying>{
	NSString *vehicleTypeId;         
	NSString *vehicleTypeName;
}

@property (nonatomic,retain) NSString *vehicleTypeId;
@property (nonatomic,retain) NSString *vehicleTypeName;

@end
