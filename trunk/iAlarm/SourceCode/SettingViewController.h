//
//  SettingViewController.h
//  iArrived
//
//  Created by li shiyong on 10-11-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingViewController : UIViewController {

	UILabel *signicantSeriveLabel;
	UILabel *standardSeriveLabel;
	UISwitch *mapOffsetSwitch;
}
 
@property (nonatomic,retain) IBOutlet UILabel *signicantSeriveLabel;
@property (nonatomic,retain) IBOutlet UILabel *standardSeriveLabel;
@property (nonatomic,retain) IBOutlet UISwitch *mapOffsetSwitch;

-(IBAction) mapOffsetSwitchChanged:(id)sender;

@end
