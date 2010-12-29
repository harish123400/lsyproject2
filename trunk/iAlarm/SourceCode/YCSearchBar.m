//
//  YCSearchBar.m
//  TestSearchBar
//
//  Created by li shiyong on 10-12-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapNotification.h"
#import "YCSearchBar.h"


@implementation YCSearchBar

@synthesize canResignFirstResponder;

//覆盖super
- (BOOL)resignFirstResponder
{
	if (self.canResignFirstResponder) 
	{
		return [super resignFirstResponder];
	}
	
	return NO;
}

//覆盖super
- (BOOL)becomeFirstResponder{
	if (self.hidden) { //如果被被隐藏
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:kSearchBarBecomeFirstResponderNotification object:self];
	}
	return [super becomeFirstResponder];
}



@end
