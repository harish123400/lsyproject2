//
//  AlarmLRepeatTypeViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmLRepeatTypeViewController.h"
#import "DicManager.h"
#import "YCRepeatType.h"
#import "YCCellDescription.h"
#import "UIUtility.h"
#import "YCAlarmEntity.h"


@implementation AlarmLRepeatTypeViewController
@synthesize lastIndexPath;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

-(IBAction) backButtonPressed:(id)sender
{
	if (self.lastIndexPath) {
		YCRepeatType *rep = [DicManager repeatTypeForSortId:lastIndexPath.row];
		alarm.repeatType = rep;
		[self.parentController  reflashView];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"重复",@"指示是否重复使用的的标签");
	
	//修改视图背景等
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	//self.tableView.style = UITableViewStyleGrouped ;
	self.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self backButtonPressed:nil];
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [DicManager repeatTypeDictionary].count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Configure the cell...
	YCRepeatType *rep = [DicManager repeatTypeForSortId:indexPath.row];
	if (rep) {
		NSString *repeatString = rep.repeatTypeName;
		cell.textLabel.text = repeatString;
		
		if ([rep.repeatTypeId compare:self.alarm.repeatType.repeatTypeId] == NSOrderedSame) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.textLabel.textColor = [UIUtility checkedCellTextColor];
			self.lastIndexPath = indexPath;
		}else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.textLabel.textColor = [UIUtility defaultCellTextColor];
		}
	}

	return cell;

}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
	
	NSString *result = NSLocalizedString(@"重复",@"指示是否重复使用的的标签");
	return result;
	
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int newRow = [indexPath row];
    int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    
    if (newRow != oldRow)
    {
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
		newCell.textLabel.textColor = [UIUtility checkedCellTextColor];
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath]; 
        oldCell.accessoryType = UITableViewCellAccessoryNone;
		oldCell.textLabel.textColor = [UIUtility defaultCellTextColor];
		lastIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[lastIndexPath release];
    [super dealloc];
}


@end

