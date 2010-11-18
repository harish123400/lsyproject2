//
//  AlarmLSoundViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmLSoundViewController.h"
#import "AlarmDetailViewController.h"
#import "YCAlarmEntity.h"
#import "YCCellDescription.h"


@implementation AlarmLSoundViewController

@synthesize ringSwitch;

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
	self.alarm.ring = self.ringSwitch.on;
	[self.parentController reflashView];
}


- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"声音",@"指示是否振铃的标签");
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


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    	cell.selectionStyle = UITableViewCellSelectionStyleNone;    //被选择后，无变化
		
		
		CGPoint cellP = cell.frame.origin;  //cell原点坐标
		CGSize  cellS = cell.frame.size;    //cell的尺寸
		
		UISwitch *switchCtlTmp = [[UISwitch alloc] init];
		//CGPoint ctlP = switchCtlTmp.frame.origin;  //控件的原点坐标
		CGSize  ctlS = switchCtlTmp.frame.size;      //控件的的尺寸
		[switchCtlTmp release];
		
		CGFloat ctlY= (cellP.y + cellS.height/2 - ctlS.height/2);  //控件的原点的Y
		CGRect nameLabelRect = CGRectMake(cellP.x+198, ctlY, ctlS.width, ctlS.height);
		self.ringSwitch = [[[UISwitch alloc] initWithFrame:nameLabelRect] autorelease];
		self.ringSwitch.backgroundColor = [UIColor clearColor];
		
		[cell.contentView addSubview: self.ringSwitch];
		
	}
	
	// Configure the cell...
	cell.textLabel.text = NSLocalizedString(@"声音",@"指示是否振铃的标签");
	ringSwitch.on = self.alarm.ring;
	
    
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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
	self.ringSwitch = nil;
}


- (void)dealloc {
	[self.ringSwitch release];
    [super dealloc];
}


@end

