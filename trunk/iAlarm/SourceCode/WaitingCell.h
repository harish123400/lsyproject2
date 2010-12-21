//
//  WaitingCell.h
//  iAlarm
//
//  Created by li shiyong on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingCell : UITableViewCell {
	UIActivityIndicatorView	*activityIndCtl;
}

@property(nonatomic,retain,readonly) UIActivityIndicatorView *activityIndCtl;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
