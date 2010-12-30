//
//  WaitingCell.h
//  iAlarm
//
//  Created by li shiyong on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingCell : UITableViewCell {
	
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
	IBOutlet UIView *activityView;
}

@property(nonatomic,retain,readonly) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain,readonly) IBOutlet UILabel *activityLabel;
@property(nonatomic,retain,readonly) IBOutlet UIView *activityView;

-(void) setWaiting:(BOOL)waiting;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;


@end
