//
//  AlarmModifyViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YCAlarmEntity;
@class AlarmNewDetailSuperViewController;


@interface UIViewController (iArrived)

	//AlarmDetailViewController *parentController;
	//YCAlarmEntity *alarm;

@property(nonatomic,retain) AlarmNewDetailSuperViewController *parentController;
@property(nonatomic,retain) YCAlarmEntity *alarm;

@end
 
/*
@protocol AlarmModify

@property(nonatomic,retain) AlarmDetailViewController *parentController;
@property(nonatomic,retain) YCAlarmEntity *alarm;

@end
 */



