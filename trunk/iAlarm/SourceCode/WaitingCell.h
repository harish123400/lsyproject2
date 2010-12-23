//
//  WaitingCell.h
//  iAlarm
//
//  Created by li shiyong on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingCell : UITableViewCell {
	
	UIColor *defaultDetailTextLabelColor;
	
	UIActivityIndicatorView	*activityIndCtl;
	UIImage *defaultImage;
	UIImage *checkedImage;
}

@property(nonatomic,retain,readonly) UIActivityIndicatorView *activityIndCtl;
@property (nonatomic,retain) UIImage *defaultImage;
@property (nonatomic,retain) UIImage *checkedImage;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
-(void) setChechmark:(BOOL)isCheckmark;

@end
