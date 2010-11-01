//
//  AlarmModifyViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AlarmModify.h"


@class YCAlarmEntity;
@class AlarmNewDetailSuperViewController;

@interface AlarmModifyViewController : UIViewController {
	AlarmNewDetailSuperViewController *parentController;
	YCAlarmEntity *alarm;
}

@property(nonatomic,retain) AlarmNewDetailSuperViewController *parentController;
@property(nonatomic,retain) YCAlarmEntity *alarm;

@end
