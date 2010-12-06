//
//  AlarmNameViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmNameInMapViewController.h"
#import "AlarmNewDetailSuperViewController.h"
#import "YCAlarmEntity.h"
#import "YCCellDescription.h"
#import "UIUtility.h"
#import "AlarmNameTableCell.h"
#import "AlarmPositionTableCell.h"


@implementation AlarmNameInMapViewController
@synthesize image;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = KInformationLabel;
	self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat cellHeight = 44;
	switch (indexPath.section) {
		case 0:
			cellHeight = kAlarmNameCellHeight;
			break;
		case 1:
			cellHeight = kAlarmPositionCellHeight;
			break;
		default:
			break;
	}
    return cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1; //每个组都是一个
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = nil;
	UITableViewCell *cell = nil;
	switch (indexPath.section) {
		case 0:
			CellIdentifier = @"AlarmNameTableCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [AlarmNameTableCell tableCellWithXib];
			}
			((AlarmNameTableCell*)cell).textLabel.text = self.alarm.alarmName;
			((AlarmNameTableCell*)cell).image = self.image;
			break;
		case 1:
			CellIdentifier = @"AlarmPositionCell";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			if (cell == nil) {
				cell = [AlarmPositionTableCell tableCellWithXib];
			}
			((AlarmPositionTableCell*)cell).textView.text = self.alarm.position;
			break;
		default:
			return nil;
			break;
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case 0:
			cell.backgroundView.alpha = 0.0;
			break;
		default:
			break;
	}
}






- (void)dealloc {

    [super dealloc];
}


@end
