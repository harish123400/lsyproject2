//
//  CheckmarkDisclosureIndicatorCell.h
//  iArrived
//
//  Created by li shiyong on 10-10-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CheckmarkDisclosureIndicatorCell : UITableViewCell {
	
	UITableViewCell *subCheckmarkCell;

}
//@property(nonatomic) UITableViewCellAccessoryType accessoryType

@property (nonatomic,retain,readonly) IBOutlet UITableViewCell *subCheckmarkCell;



@end
