//
//  RootViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-15.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlarmDetailViewController;
@class ApplicationCell;
@class AlarmNewDetailSuperViewController;
@interface RootViewController : UITableViewController 
<UITableViewDelegate,UITableViewDataSource>{
	
	ApplicationCell *tmpCell;
	
	//需要切换的按钮
	UIBarButtonItem *editAlarmButton;
	UIBarButtonItem *doneAlarmButton;
	
	AlarmNewDetailSuperViewController *alarmNewDetailSuperViewController;
}
@property (nonatomic, assign) IBOutlet ApplicationCell *tmpCell;
@property (nonatomic, retain) IBOutlet AlarmNewDetailSuperViewController *alarmNewDetailSuperViewController;

-(IBAction)addAlarmButtonPressed:(id)sender;
-(IBAction)editOrDoneAlarmButtonPressed:(id)sender;

@end
