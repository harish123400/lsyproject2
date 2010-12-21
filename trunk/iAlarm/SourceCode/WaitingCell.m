//
//  WaitingCell.m
//  iAlarm
//
//  Created by li shiyong on 10-12-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WaitingCell.h"


@implementation WaitingCell

- (id) activityIndCtl{
	
	if (!self->activityIndCtl) {
		
		/////////////////////
		////switch控件位置
		CGPoint cellP = self.frame.origin;  //cell原点坐标
		CGSize  cellS = self.frame.size;    //cell的尺寸
		
		UIActivityIndicatorView *ctlTmp = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		CGSize  ctlS = ctlTmp.frame.size;      //控件的的尺寸
		[ctlTmp release];
		
		CGFloat ctlY= (cellP.y + cellS.height/2 - ctlS.height/2);  //控件的原点的Y
		CGRect ctlRect = CGRectMake(cellP.x+270, ctlY, ctlS.width, ctlS.height);
		/////////////////////
		
		self->activityIndCtl = [[UIActivityIndicatorView alloc] initWithFrame:ctlRect];
		self->activityIndCtl.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		self->activityIndCtl.hidesWhenStopped = YES;
		self->activityIndCtl.backgroundColor = [UIColor clearColor];
	}
	
	
	return self->activityIndCtl;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self.contentView addSubview: self.activityIndCtl];
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
	return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}



- (void)dealloc {
	[activityIndCtl release];
    [super dealloc];
}


@end
