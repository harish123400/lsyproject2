//
//  SettingViewController.m
//  iArrived
//
//  Created by li shiyong on 10-11-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "YCParam.h"


@implementation SettingViewController
@synthesize signicantSeriveLabel;
@synthesize standardSeriveLabel;
@synthesize mapOffsetSwitch;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction) mapOffsetSwitchChanged:(id)sender
{
	YCParam *param = [YCParam paramSingleInstance];
	param.enableOffset = self.mapOffsetSwitch.on;
}

-(void) viewWillAppear:(BOOL)animated
{
	YCParam *param = [YCParam paramSingleInstance];
	
	if (param.significantService)
		self.signicantSeriveLabel.text = @"Open";
	else 
		self.signicantSeriveLabel.text = @"Close";
	
	if (param.standardService)
		self.standardSeriveLabel.text = @"Open";
	else 
		self.standardSeriveLabel.text = @"Close";
	

	self.mapOffsetSwitch.on = param.enableOffset;
	
	

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
