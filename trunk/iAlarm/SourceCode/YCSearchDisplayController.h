//
//  YCSearchDisplayController.h
//  iAlarm
//
//  Created by li shiyong on 10-12-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YCSearchBar;
@interface YCSearchDisplayController : UISearchDisplayController {
	NSString *lastSearchString;
	NSString *originalPlaceholderString;
	
}

@property(nonatomic,retain) NSString *lastSearchString;
@property(nonatomic,retain) NSString *originalPlaceholderString;

@end
