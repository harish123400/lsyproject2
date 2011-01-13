//
//  YCAnnotation.m
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCAnnotation.h"


@implementation YCAnnotation

@synthesize coordinate;
@synthesize subtitle;
@synthesize title;
//@synthesize isCurrent;
@synthesize annotationType;

- (id)init{
	if (self=[super initWithCoordinate:CLLocationCoordinate2DMake(0, 0) addressDictionary:nil]) {
		
	}
	return self;
}


- (void)dealloc 
{
	[title release];
	[subtitle release];
	[super dealloc];
	
}

@end
