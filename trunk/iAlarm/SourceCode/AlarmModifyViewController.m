    //
//  AlarmModifyViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModifyNotification.h"
#import "AlarmModifyViewController.h"
#import "YCAlarmEntity.h"



@implementation AlarmModifyViewController


-(id)alarm
{
	return alarm;
}
-(void)setAlarm:(id)newObj
{
	[newObj retain];
	[alarm release];
	alarm = newObj;
}


-(IBAction)doneButtonPressed:(id)sender
{	
	//子类覆盖
	//改变了，发送通知
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:kAlarmItemChangedNotification object:self];
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
	[self.alarm release];
    [super dealloc];
}


@end
