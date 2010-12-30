//
//  AlarmModifyViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class YCAlarmEntity;
@interface AlarmModifyViewController : UIViewController {
	YCAlarmEntity *alarm;
}

@property(nonatomic,retain) YCAlarmEntity *alarm;
-(IBAction)doneButtonPressed:(id)sender;

@end
