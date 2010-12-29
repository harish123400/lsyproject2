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


- (id) activityIndCtl{
	
	if (!self->activityIndCtl) {
		self->activityIndCtl = [[UIActivityIndicatorView alloc] init];
		self->activityIndCtl.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		self->activityIndCtl.hidesWhenStopped = YES;
		self->activityIndCtl.backgroundColor = [UIColor clearColor];
	}
	
	/////////////////////
	////activityInd控件位置
	CGPoint cellP = self.contentView.frame.origin;  //cell原点坐标
	CGSize  cellS = self.contentView.frame.size;    //cell的尺寸
	
	CGFloat accViewW = 0.0;//指示器view宽
	if (self.accessoryType != UITableViewCellAccessoryNone) {
		accViewW = 18.0;
	}

	
	UIActivityIndicatorView *ctlTmp = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	CGSize  ctlS = ctlTmp.frame.size;      //控件的的尺寸
	[ctlTmp release];
	
	CGFloat ctlY= (cellP.y + cellS.height/2 - ctlS.height/2);  //控件的原点的Y
	CGFloat ctlX= cellS.width - ctlS.width - accViewW - 10;
	CGRect ctlRect = CGRectMake(ctlX, ctlY, ctlS.width, ctlS.height);
	/////////////////////
	self->activityIndCtl.frame = ctlRect;
	
	
	return self->activityIndCtl;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        //[self.contentView addSubview: self.activityIndCtl];
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
	return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

-(void) setWaiting:(BOOL)waiting{
	
	if (waiting){
		[self.activityIndCtl removeFromSuperview];         //先删除后加入，为了改变位置
		[self.contentView addSubview: self.activityIndCtl];
		[self.activityIndCtl startAnimating];
	}
	else 
		[self.activityIndCtl stopAnimating];
}



- (void)dealloc {
	[defaultDetailTextLabelColor release];
	[activityIndCtl release];
    [super dealloc];
}


@end
