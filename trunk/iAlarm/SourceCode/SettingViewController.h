//
//  SettingViewController.h
//  iArrived
//
//  Created by li shiyong on 10-11-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingViewController : UIViewController {

	UISwitch *mapOffsetSwitch;
	
	UILabel *signicantSeriveLabel;
	UILabel *standardSeriveLabel;
	UILabel *lastStandardSpeedLabel;
	UILabel *currentSpeedLabel;
	
	UITextView *regionsView;
	UITextView *lastRegionsView;

}
@property (nonatomic,retain) IBOutlet UISwitch *mapOffsetSwitch;

@property (nonatomic,retain) IBOutlet UILabel *signicantSeriveLabel;
@property (nonatomic,retain) IBOutlet UILabel *standardSeriveLabel;
@property (nonatomic,retain) IBOutlet UILabel *lastStandardSpeedLabel;
@property (nonatomic,retain) IBOutlet UITextView *regionsView;
@property (nonatomic,retain) IBOutlet UITextView *lastRegionsView;
@property (nonatomic,retain) IBOutlet UILabel *currentSpeedLabel;

-(IBAction) refreshButtonPressed:(id)sender;
-(IBAction) mapOffsetSwitchChanged:(id)sender;

@end
