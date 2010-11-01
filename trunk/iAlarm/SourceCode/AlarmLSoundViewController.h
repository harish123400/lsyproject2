//
//  AlarmLSoundViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmModifyTableViewController.h"


@interface AlarmLSoundViewController : AlarmModifyTableViewController {
	
	UISwitch *ringSwitch;
	
}

@property(nonatomic,retain) IBOutlet UISwitch *ringSwitch;

-(IBAction) backButtonPressed:(id)sender;

@end
