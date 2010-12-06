//
//  AlarmNameViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmModifyTableViewController.h"


@interface AlarmNameInMapViewController : AlarmModifyTableViewController
<UITableViewDataSource,UITableViewDelegate> 
{
	UIImage *image;
}

@property (nonatomic,retain) UIImage *image;


@end
