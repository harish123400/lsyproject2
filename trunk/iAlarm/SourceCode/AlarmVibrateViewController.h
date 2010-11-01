//
//  AlarmVibrateViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmModifyTableViewController.h"


@interface AlarmVibrateViewController : AlarmModifyTableViewController {
	
	UISwitch *vibrateSwitch;

}

@property(nonatomic,retain) IBOutlet UISwitch *vibrateSwitch;

-(IBAction) backButtonPressed:(id)sender;


@end
