//
//  AlarmDetailViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmNewDetailSuperViewController.h"
#import <UIKit/UIKit.h>


@class YCAlarmEntity;

@interface AlarmDetailViewController : AlarmNewDetailSuperViewController 
<UITableViewDelegate,UITableViewDataSource> {
	
	YCAlarmEntity *alarmTmp;
}

@property(nonatomic,readonly) YCAlarmEntity *alarmTmp;


@end
