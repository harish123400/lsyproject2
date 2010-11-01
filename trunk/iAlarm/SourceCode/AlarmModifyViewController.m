    //
//  AlarmModifyViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModifyViewController.h"
#import "AlarmNewDetailSuperViewController.h"
#import "YCAlarmEntity.h"



@implementation AlarmModifyViewController

//@synthesize parentViewController;
//@synthesize alarm;

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

- (void)dealloc {
	[self.parentViewController release];
	[self.alarm release];
    [super dealloc];
}


@end
