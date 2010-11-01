//
//  AlarmNameViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmModifyViewController.h"


@interface AlarmNameViewController : AlarmModifyViewController {
	
	UITextField *alarmNameTextField;
}

@property(nonatomic,retain) IBOutlet UITextField *alarmNameTextField;


-(IBAction) backButtonPressed:(id)sender;
-(IBAction) textFieldDoneEditing:(id)sender;


@end
