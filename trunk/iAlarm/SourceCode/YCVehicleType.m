//
//  YCVehicleType.m
//  iArrived
//
//  Created by li shiyong on 10-10-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCVehicleType.h"


@implementation YCVehicleType

@synthesize vehicleTypeId;
@synthesize vehicleTypeName;

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
	
	[encoder encodeObject:vehicleTypeId forKey:kvehicleTypeId];
	[encoder encodeObject:vehicleTypeName forKey:kvehicleTypeName];
	
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {		
		self.vehicleTypeId = [decoder decodeObjectForKey:kvehicleTypeId];
		self.vehicleTypeName = [decoder decodeObjectForKey:kvehicleTypeName];
    }
    return self;
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    YCVehicleType *copy = [[[self class] allocWithZone: zone] init];
	/*
    copy.vehicleTypeId = [[self.vehicleTypeId copyWithZone:zone] autorelease];
    copy.vehicleTypeName = [[self.vehicleTypeName copyWithZone:zone] autorelease];
	 */
	copy.vehicleTypeId = self.vehicleTypeId;
    copy.vehicleTypeName = self.vehicleTypeName;
    return copy;
}

- (void)dealloc {
	[vehicleTypeId release];
	[vehicleTypeName release];
    [super dealloc];
}

@end
