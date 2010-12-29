//
//  AlarmLSoundViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIUtility.h"
#import "YCSound.h"
#import "AlarmModifyNotification.h"
#import "DicManager.h"
#import "AlarmLSoundViewController.h"
#import "AlarmDetailViewController.h"
#import "YCAlarmEntity.h"
#import "YCCellDescription.h"


@implementation AlarmLSoundViewController
@synthesize lastIndexPath;


//覆盖父类
-(IBAction)doneButtonPressed:(id)sender
{	
	YCSound *sound = [DicManager soundForSortId:lastIndexPath.row];
	self.alarm.sound = sound;
	
	//改变了，发送通知
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:kAlarmItemChangedNotification object:self];
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = KSoundViewTitle;
	//修改视图背景等
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	self.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
}


- (void)viewWillAppear:(BOOL)animated
{
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [DicManager soundDictionary].count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Configure the cell...
	YCSound *rep = [DicManager soundForSortId:indexPath.row];
	if (rep) {
		NSString *repeatString = rep.soundName;
		cell.textLabel.text = repeatString;
		
		if ([rep.soundId isEqualToString:self.alarm.sound.soundId]) {
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
	
	//done按钮可用
	self.navigationItem.rightBarButtonItem.enabled = YES;
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

