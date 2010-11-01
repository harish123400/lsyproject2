//
//  AlarmPositionViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmModifyTableViewController.h"

@interface AlarmPositionViewController : AlarmModifyTableViewController {

    NSIndexPath    * lastIndexPath;
}
@property (nonatomic, retain) NSIndexPath * lastIndexPath;

-(IBAction) backButtonPressed:(id)sender;

@end
