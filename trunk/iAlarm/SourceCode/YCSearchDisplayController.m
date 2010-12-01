//
//  YCSearchDisplayController.m
//  iAlarm
//
//  Created by li shiyong on 10-12-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCSearchDisplayController.h"


@implementation YCSearchDisplayController

@synthesize lastSearchString;
@synthesize originalPlaceholderString;


- (void)dealloc
{
	
	[lastSearchString release];
	[originalPlaceholderString release];
	
	[super dealloc];
}

/////////////////////////////////////
//退出搜索时候，保持最后搜索字符串在 bar上
- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
	if (visible) 
	{
		[super setActive:visible animated:animated];
		self.searchBar.text = self.lastSearchString;
		self.searchBar.placeholder = self.originalPlaceholderString;
	}else {
		self.lastSearchString = self.searchBar.text ;
		if (self.lastSearchString !=nil && [self.lastSearchString length] >0) 
		{
			self.searchBar.placeholder = lastSearchString;
		}
		self.searchBar.text = nil;
		
		[super setActive:visible animated:animated];
	}

}
//退出搜索时候，保持最后搜索字符串在 bar上
/////////////////////////////////////


@end
