//
//  WaitingCell.m
//  iAlarm
//
//  Created by li shiyong on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIUtility.h"
#import "WaitingCell.h"


@implementation WaitingCell

/*
@synthesize activityIndicator;
@synthesize activityLabel;
@synthesize activityView;
 */

-(id) activityIndicator{
	if (!activityIndicator ) {
		activityIndicator = [[UIActivityIndicatorView alloc] 
							 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicator.frame = CGRectMake(152.0,12.0,20.0,20.0);
		activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
											|UIViewAutoresizingFlexibleBottomMargin;
	}
	return activityIndicator;
}

-(id) activityLabel{
	if (!activityLabel ) {
		activityLabel = [[UILabel alloc] init];
		activityLabel.backgroundColor = [UIColor clearColor];    //背景色
		activityLabel.textColor = [UIColor grayColor];           //文本颜色
		activityLabel.font = [UIFont boldSystemFontOfSize:15.0]; //字体：加粗
		activityLabel.textAlignment = UITextAlignmentRight;      //文本右对齐
		activityLabel.frame = CGRectMake(5.0,12.0,133.0,20.0);
		activityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
										|UIViewAutoresizingFlexibleBottomMargin;
	}
	return activityLabel;
}

-(id) activityView{
	if (!activityView ) {
		activityView = [[UILabel alloc] init];
		activityView.backgroundColor = [UIColor clearColor];
		activityView.frame = CGRectMake(130.0,0.0,190.0,44.0);
		activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
									   |UIViewAutoresizingFlexibleRightMargin
									   |UIViewAutoresizingFlexibleBottomMargin;
		
		[activityView addSubview:self.activityIndicator];
		[activityView addSubview:self.activityLabel];
		activityView.hidden = YES;
	}
	return activityView;
}

-(void) setWaiting:(BOOL)waiting{
	
	if (waiting){
		self.activityView.hidden = NO;
		self.activityIndicator.hidden = NO;
		self.activityLabel.hidden = NO;
		[self.activityIndicator startAnimating];
	}else {
		self.activityView.hidden = YES;
		self.activityIndicator.hidden = YES;
		self.activityLabel.hidden = YES;
		[self.activityIndicator stopAnimating];
	}
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
		[self.contentView addSubview: self.activityView];
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
	return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

- (void)dealloc {
	[activityIndicator release];
	[activityLabel release];
	[activityView release];
    [super dealloc];
}


@end
