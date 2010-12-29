//
//  AlarmModifyTableViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocalizedString.h"
#import <UIKit/UIKit.h>
#import "YCNavSuperControllerProtocol.h"

@class YCAlarmEntity;
@interface AlarmModifyTableViewController : UITableViewController {
	id<YCNavSuperControllerProtocol> parentController;
	YCAlarmEntity *alarm;
}

@property(nonatomic,retain) id<YCNavSuperControllerProtocol> parentController;
@property(nonatomic,retain) YCAlarmEntity *alarm;
@end
