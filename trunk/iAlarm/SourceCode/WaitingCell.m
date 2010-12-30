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
		activityIndicator.frame = CGRectMake(145.0,12.0,20.0,20.0);
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
		activityLabel.font = [UIFont boldSystemFontOfSize:16.0]; //字体：加粗
		activityLabel.textAlignment = UITextAlignmentCenter;     //文本右对齐
		activityLabel.adjustsFontSizeToFitWidth = YES;           //字号自适应
		activityLabel.minimumFontSize = 12.0;
		//activityLabel.frame = CGRectMake(0.0,12.0,125.0,20.0);
		activityLabel.frame = CGRectMake(30.0,12.0,95.0,20.0);
		activityLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
										|UIViewAutoresizingFlexibleBottomMargin;
	}
	return activityLabel;
}

-(id) activityImageView{
	if (!activityImageView ) {
		activityImageView = [[UIImageView alloc] init];
		activityImageView.backgroundColor = [UIColor clearColor];    //背景色
		activityImageView.frame = CGRectMake(17,12.0,13,20.0);
		activityImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin 
										|UIViewAutoresizingFlexibleBottomMargin;
	}
	return activityImageView;
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
		[activityView addSubview:self.activityImageView];
		
		activityView.hidden = YES;
	}
	return activityView;
}


-(id) accessoryImageView{
	if (!accessoryImageView ) {
		accessoryImageView = [[UIImageView alloc] init];
		accessoryImageView.backgroundColor = [UIColor clearColor];    //背景色
		accessoryImageView.frame = CGRectMake(0,12.0,13,20.0);
	}
	return accessoryImageView;
}

-(void)setAccessoryType:(UITableViewCellAccessoryType)type{
	
	if (UITableViewCellAccessoryNone==type) {
		self.accessoryView = nil;
		super.accessoryType = UITableViewCellAccessoryNone;
	}else {  //目前只支持 大头针＋>
		UIView *accessoryView = [[[UILabel alloc] init] autorelease];
		accessoryView.backgroundColor = [UIColor clearColor];
		accessoryView.frame = CGRectMake(0.0,0.0,35.0,44.0);
		
		UIImageView *accessoryImageView1 = [[[UIImageView alloc] init] autorelease];
		accessoryImageView1.backgroundColor = [UIColor clearColor];    
		accessoryImageView1.frame = CGRectMake(0,12.0,16,20.0);
		accessoryImageView1.image = [UIImage imageNamed:@"Pin-2x.png"];
		
		UIImageView *accessoryImageView2 = [[[UIImageView alloc] init] autorelease];
		accessoryImageView2.backgroundColor = [UIColor clearColor];    
		accessoryImageView2.frame = CGRectMake(13,15.0,10,13.0);
		accessoryImageView2.image = [UIImage imageNamed:@"DisclosureIndicator.png"];
		accessoryImageView2.highlightedImage = [UIImage imageNamed:@"DisclosureIndicator-HighLighted.png"];
		
		[accessoryView addSubview:accessoryImageView1];
		[accessoryView addSubview:accessoryImageView2];
		
		self.accessoryView = accessoryView;
	}
}

-(void) setWaiting:(BOOL)waiting{
	
	if (waiting){
		self.accessoryType = UITableViewCellAccessoryNone; //显示等待就隐藏accessoryView
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
