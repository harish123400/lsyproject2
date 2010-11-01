//
//  CheckmarkDisclosureIndicatorCell.m
//  iArrived
//
//  Created by li shiyong on 10-10-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CheckmarkDisclosureIndicatorCell.h"


@implementation CheckmarkDisclosureIndicatorCell


-(id)subCheckmarkCell
{
	if(subCheckmarkCell == nil)
	{
		subCheckmarkCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		subCheckmarkCell.frame = CGRectMake(0.0, 0.0, 290, 44);
		//subCheckmarkCell.accessoryType = UITableViewCellAccessoryCheckmark;
		//subCheckmarkCell.backgroundColor = [UIColor brownColor];
	}
	
	return subCheckmarkCell;
}




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

		// >
		super.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		// √
		[self insertSubview:self.subCheckmarkCell belowSubview:self.contentView];		
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	//[subCheckmarkCell setSelected:selected animated:animated];
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setAccessoryType:(UITableViewCellAccessoryType)accType
{
	subCheckmarkCell.accessoryType = accType;
}

- (void)dealloc {
	[subCheckmarkCell release];
    [super dealloc];
}



@end
