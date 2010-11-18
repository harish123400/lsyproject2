    //
//  AlarmModifyViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModifyViewController.h"
#import "YCAlarmEntity.h"



@implementation AlarmModifyViewController


-(id)parentController
{
	return parentController;
}
-(void)setParentController:(id)newObj
{
	if (newObj == parentController) {
		//[parentController retain];
		return;
	}
	
	[parentController release];
	parentController = newObj;
	[parentController retain];
}

-(id)alarm
{
	return alarm;
}
-(void)setAlarm:(id)newObj
{
	if (newObj == alarm) {
		//[alarm retain];
		return;
	}
	[alarm release];
	alarm = newObj;
	[alarm retain];
}


-(IBAction)doneButtonPressed:(id)sender
{	
	//子类覆盖
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
								   target:self 
								   action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
	self.navigationItem.rightBarButtonItem.enabled = NO;
    [doneButton release];
}


- (void)dealloc {
	[self.parentViewController release];
	[self.alarm release];
    [super dealloc];
}


@end
