//
//  RootViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-15.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RootViewController.h"
#import "alarmNewDetailSuperViewController.h"
#import "AlarmDetailViewController.h"
#import "AlarmNewViewController.h"
#import "UIUtility.h"
#import "YCAlarmEntity.h"
#import "DataUtility.h"
#import "ApplicationCell.h"

#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

#define EditStateDidChangeNotification @"EditStateDidChangeNotification"

@implementation RootViewController

@synthesize tmpCell;
@synthesize alarmNewDetailSuperViewController;


#pragma mark -
#pragma mark View lifecycle

// When the playback state changes, set the play/pause button in the Navigation bar
//		appropriately.
- (void) handle_EditStateChanged: (id) notification {
	
	//行数>0,才可以编辑
	NSUInteger rowCount = [self tableView:(UITableView*)self.view numberOfRowsInSection:0];
	if (rowCount == 0) {
		[self.tableView setEditing:TRUE animated:YES] ;
	}
	
	[self.tableView setEditing:!self.tableView.editing animated:YES];
	if (self.tableView.editing)
		self.navigationItem.leftBarButtonItem = doneAlarmButton;
	else
		self.navigationItem.leftBarButtonItem = editAlarmButton;
	
}

// To learn about notifications, see "Notifications" in Cocoa Fundamentals Guide.
- (void) registerForMediaPlayerNotifications {
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	
	[notificationCenter addObserver: self
						   selector: @selector (handle_EditStateChanged:)
							   name: EditStateDidChangeNotification
							 object: nil];
}

-(IBAction)addAlarmButtonPressed:(id)sender
{

	self.alarmNewDetailSuperViewController = [[AlarmNewViewController alloc] initWithStyle:UITableViewStyleGrouped];
	self.alarmNewDetailSuperViewController.alarm = [DataUtility createAlarm];
	
	self.alarmNewDetailSuperViewController.parentController = self;
	self.alarmNewDetailSuperViewController.hidesBottomBarWhenPushed = YES;
	
	[UIUtility navigationController:self.navigationController 
					 viewController:self.alarmNewDetailSuperViewController 
							 isPush:YES
			   durationForAnimation:0.75
				  TransitionForType:kCATransitionPush 
			   TransitionForSubtype:kCATransitionFromTop];
	
	
	
	//转成非编辑状态
	if (self.tableView.editing)
	{	
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:EditStateDidChangeNotification object:self];
	}
	
}

-(IBAction)editOrDoneAlarmButtonPressed:(id)sender
{	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:EditStateDidChangeNotification object:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"时空闹钟",@"根视图标题");
	
	// Configure the table view.
    self.tableView.rowHeight = 73.0;
    self.tableView.backgroundColor = DARK_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	

	UIBarButtonItem *addAlarmButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
									   target:self 
									   action:@selector(addAlarmButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addAlarmButton;
    [addAlarmButton release];
	
	editAlarmButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
									   target:self
					                   action:@selector(editOrDoneAlarmButtonPressed:)];
	doneAlarmButton = [[UIBarButtonItem alloc]
					   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
					   target:self
					   action:@selector(editOrDoneAlarmButtonPressed:)];
    self.navigationItem.leftBarButtonItem = editAlarmButton;
	
	[self registerForMediaPlayerNotifications];
}


/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataUtility alarmArray] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	
    static NSString *CellIdentifier = @"Cell";
    
	ApplicationCell *cell = (ApplicationCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[[NSBundle mainBundle] loadNibNamed:@"IndividualSubviewsBasedApplicationCell" owner:self options:nil];
        cell = tmpCell;
        self.tmpCell = nil;
    }
    
	//cell.useDarkBackground = (indexPath.row % 2 == 0);
	cell.useDarkBackground = NO;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	// Configure the data for the cell.
	static UIImage *lImage ;
	if(lImage == nil)
		lImage = [UIImage imageNamed:@"MathGraph.png"];
	cell.icon = lImage;
	
	NSArray *alarms = [DataUtility alarmArray];
	YCAlarmEntity *alarm =[alarms objectAtIndex:indexPath.row];
	cell.alarmName = alarm.alarmName;
	cell.position = alarm.position;
	NSString *enabling = alarm.enabling ? NSLocalizedString(@"打开",@"闹钟的开关状态")
	                                    : NSLocalizedString(@"关闭",@"闹钟的开关状态");
	cell.enablingString =enabling;
	 
    return cell;
	
}

- (void) tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
 forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    NSUInteger row = [indexPath row];
	NSMutableArray *alarms = [DataUtility alarmArray];
    [alarms removeObjectAtIndex:row];
	[DataUtility saveAlarmArray:alarms];
    
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                     withRowAnimation:UITableViewRowAnimationLeft];
	
	//行数＝＝0，转成不可编辑的状态
	NSUInteger rowCount = [self tableView:(UITableView*)self.view numberOfRowsInSection:0];
	if (rowCount == 0 && self.tableView.editing) {
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:EditStateDidChangeNotification object:self];
	}
	
	[UIUtility sendAlarmUpdateNotification];
	
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	

	self.alarmNewDetailSuperViewController = [[AlarmDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
	NSArray *alarms = [DataUtility alarmArray];
	YCAlarmEntity *alarm =[alarms objectAtIndex:indexPath.row];
	
	self.alarmNewDetailSuperViewController.alarm = alarm;
	self.alarmNewDetailSuperViewController.parentController = self;
	self.alarmNewDetailSuperViewController .hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:self.alarmNewDetailSuperViewController animated:YES];
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor = ((ApplicationCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
	cell.backgroundColor = LIGHT_BACKGROUND;
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
	[[NSNotificationCenter defaultCenter] removeObserver: self
													name: EditStateDidChangeNotification
												  object: nil];
	[tmpCell release];
	[editAlarmButton release];
	[doneAlarmButton release];
	[alarmNewDetailSuperViewController release];
    [super dealloc];
}




@end

