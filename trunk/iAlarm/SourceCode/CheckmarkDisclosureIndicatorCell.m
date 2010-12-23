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
		[self insertSubview:self.subCheckmarkCell belowSubview:self.contentView];
    }
    return self;
}


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier checkmark:(BOOL)isCheckmark{
	
	if ((self = [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier])) {
		// √
		if (isCheckmark) 
			self.subCheckmarkCell.accessoryType = UITableViewCellAccessoryCheckmark;		
    }
    return self;	
}


-(void) setAccessoryType:(UITableViewCellAccessoryType)accType
{
	self.subCheckmarkCell.accessoryType = accType;
}
 

-(void) setChechmark:(BOOL)isCheckmark
{
	if (isCheckmark) 
		[self insertSubview:self.subCheckmarkCell belowSubview:self.contentView];	
	else 
		[self.subCheckmarkCell removeFromSuperview];
}

- (void)dealloc {
	[subCheckmarkCell release];
    [super dealloc];
}



@end
