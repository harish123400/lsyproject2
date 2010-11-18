//
//  AlarmNewEditSuperViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmNewDetailSuperViewController.h"
#import "UIUtility.h"
#import "YCCellDescription.h"
#import "DataUtility.h"
#import "YCAlarmEntity.h"
#import "CheckmarkDisclosureIndicatorCell.h"


@implementation AlarmNewDetailSuperViewController

#pragma mark - 属性
#pragma mark 普通属性
@synthesize alarm;
@synthesize parentController;
@synthesize cellDescriptions;
@synthesize cellDescriptionIds;
@synthesize addAlarmButton;
@synthesize cancelAlarmButton;
@synthesize enablingSwitch;
@synthesize lastIndexPathPosition;


-(id)defaultDetailTextColor
{
	if (defaultDetailTextColor ==nil) {
		defaultDetailTextColor = [UIUtility defaultCellDetailTextColor];
		[defaultDetailTextColor retain];
	}
	return defaultDetailTextColor;
}

-(id)defaultTextColor
{
	if (defaultTextColor ==nil) {
		defaultTextColor = [UIUtility defaultCellTextColor];
		[defaultTextColor retain];
	}
	return defaultTextColor;
}

-(id)checkedTextColor
{
	if (checkedTextColor ==nil) {
		checkedTextColor = [UIUtility checkedCellTextColor];
		[checkedTextColor retain];
	}
	return checkedTextColor;
}

#pragma mark - 属性
#pragma mark Lazy creation of controls
- (UISwitch *)switchCtl
{
	if (enablingSwitch == nil) 
	{
		CGRect nameLabelRect = CGRectMake(195.0, 12.0, 94.0, 27.0);
		enablingSwitch = [[UISwitch alloc] initWithFrame:nameLabelRect];
		enablingSwitch.backgroundColor = [UIColor clearColor];
	}
	return enablingSwitch;
}

#define kProgressIndicatorSize	40.0
- (UIActivityIndicatorView *)progressInd
{
    if (progressInd == nil)
    {
        CGRect frame = CGRectMake(270.0, 11.0, kProgressIndicatorSize, kProgressIndicatorSize);
        progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        [progressInd startAnimating];
        progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [progressInd sizeToFit];
        progressInd.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleBottomMargin);
		
		progressInd.tag = kPositionCellIndTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return progressInd;
}

-(id)addAlarmButton
{
	if(addAlarmButton ==nil)
		addAlarmButton = [[UIBarButtonItem alloc]
						  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
						  target:self 
						  action:@selector(addButtonPressed:)];
	return addAlarmButton;
}

-(id)saveAlarmButton
{
	if(saveAlarmButton ==nil)
		saveAlarmButton = [[UIBarButtonItem alloc]
						  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
						  target:self 
						  action:@selector(saveButtonPressed:)];
	return saveAlarmButton;
}

-(id)cancelAlarmButton
{
	if(cancelAlarmButton==nil)
		cancelAlarmButton = [[UIBarButtonItem alloc]
							 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
							 target:self
							 action:@selector(cancelButtonPressed:)];
	return cancelAlarmButton;
}

#pragma mark - 事件响应
#pragma mark Even response
-(IBAction) enablingSwitchChanged:(id)sender
{
	
}
-(IBAction)cancelButtonPressed:(id)sender{

}

-(IBAction)saveButtonPressed:(id)sender{
	
}

-(IBAction)addButtonPressed:(id)sender{
	
}


#pragma mark - 工具函数
#pragma mark 
//取得在整个Table中的行号
-(NSUInteger) lineNumberAtIndexPath:(NSIndexPath *)indexPath 
{
	NSUInteger grow =0;
	for (NSUInteger i=0; i<indexPath.section; i++)
	{
		NSUInteger numberOfRowsInSection = [self tableView:(UITableView*)self.view numberOfRowsInSection:i];
		grow += numberOfRowsInSection;
	}
	grow += [indexPath row];
	return grow;
}

//根据viewTag取得描述对象
-(id)cellDescriptions:(NSArray*)theCellDescriptions viewTag:(NSUInteger)viewTag
{
	YCCellDescription *cellDes;
	for (NSUInteger i=0; i<theCellDescriptions.count; i++) {
		cellDes = [theCellDescriptions objectAtIndex:i];
		if (cellDes.ctlTag == viewTag) {
			break;
		}
	}
	return cellDes;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	//修改视图背景等
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	self.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;

}

#pragma mark -
#pragma mark Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSUInteger grow = [self lineNumberAtIndexPath:indexPath];//在整个Table中的行号
	
	//取cell描述对象
	YCCellDescription *des;
	if (grow < self.cellDescriptions.count) {
		des = (YCCellDescription*)[self.cellDescriptions objectAtIndex:grow];
	}
	if (des == nil) 
		return nil;
	
	static NSString *CellIdentifierDefault = @"CellIdentifierDefault";
	static NSString *CellIdentifierBool = @"CellIdentifierBool";
	static NSString *CellIdentifierCheck = @"CellIdentifierCheck";
	static NSString *CellIdentifierCheckAndInd = @"CellIdentifierCheckAndInd";
	static NSString *CellIdentifierNone = @"CellIdentifierNone";
	
	UITableViewCell *cell =nil;
	switch (des.cellType) {
		case kDefaultCellType:  //defalut type
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierDefault];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierDefault] autorelease];
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			/*
			 CGColorRef detailTextColor1 = cell.detailTextLabel.textColor.CGColor;
			 NSLog(@"%@",detailTextColor1);
			 
			 CGColorRef textColor1 = cell.textLabel.textColor.CGColor;
			 NSLog(@"%@",textColor1);
			 */
			
			break;
			
		case kCheckCellType:  //check type
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCheck];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierCheck] autorelease];
			}
			if ([des.typeData boolValue]){
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				self.lastIndexPathPosition = indexPath;
			}
			else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			
			break;
			
		case kCheckAndIndCellType:  //check and ind type
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCheck];
			if (cell == nil)
			{
				cell = [[[CheckmarkDisclosureIndicatorCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierCheckAndInd] autorelease];
			}
			
			if ([des.typeData boolValue]){
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
			else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			break;
			
		case kNoneCellType:  //none type
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierNone];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierNone] autorelease];
			}
			cell.selectionStyle = UITableViewCellSelectionStyleNone;    //被选择后，无变化
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			break;
			
		case kBoolCellType:
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierBool];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierBool] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;    //被选择后，无变化
				
				
				CGPoint cellP = cell.frame.origin;  //cell原点坐标
				CGSize  cellS = cell.frame.size;    //cell的尺寸
				
				UISwitch *switchCtlTmp = [[UISwitch alloc] init];
				//CGPoint ctlP = switchCtlTmp.frame.origin;  //控件的原点坐标
				CGSize  ctlS = switchCtlTmp.frame.size;      //控件的的尺寸
				[switchCtlTmp release];
				
				CGFloat ctlY= (cellP.y + cellS.height/2 - ctlS.height/2);  //控件的原点的Y
				CGRect nameLabelRect = CGRectMake(cellP.x+198, ctlY, ctlS.width, ctlS.height);
				UISwitch *switchCtl = [[UISwitch alloc] initWithFrame:nameLabelRect];
				switchCtl.backgroundColor = [UIColor clearColor];
				
				[cell.contentView addSubview: switchCtl];
				[switchCtl release];
			}
			
			UISwitch *switchInCell;
			NSArray *ctls = [cell.contentView subviews];
			for (int i=0; i<ctls.count; i++) {
				id obj = [ctls objectAtIndex:i];
				if ([ obj isKindOfClass:[UISwitch class]]) {
					switchInCell = obj;
					break;
				}
			}
			switchInCell.tag = des.ctlTag;
			switchInCell.on = [((NSNumber*)des.typeData) boolValue];      //拆卸附加值
			[switchInCell addTarget:self action:des.ctlAction forControlEvents:UIControlEventValueChanged];
			
			break;
			
		default:
			break;
	}
	
	
	// Configure the cell...
	if (grow < self.cellDescriptions.count) {
		YCCellDescription *des = (YCCellDescription*)[cellDescriptions objectAtIndex:grow];
		cell.textLabel.text = des.text;
		cell.detailTextLabel.text = des.detailText;
		cell.tag = des.ctlTag;
		if(des.image)
		{
			UIImage *image = [UIImage imageNamed:des.image];
			image = [UIUtility roundCorners:image];
			cell.imageView.image = image;
		}
		
		////////////设置字体颜色///////////////
		if (des.textColor) 
			cell.textLabel.textColor = des.textColor;
		else 
			cell.textLabel.textColor = self.defaultTextColor;
		   
		
		if (des.detailTextColor) 
			cell.detailTextLabel.textColor = des.detailTextColor;
		else 
			cell.detailTextLabel.textColor = self.defaultDetailTextColor;
		////////////设置字体颜色///////////////
		
		//////////////等待圈/////////////////
		if (des.cellBusinessType == kDesCellPosition) 
		{
			if ([((NSNumber*)des.typeData) boolValue]) 
			{
				cell.accessoryType = UITableViewCellAccessoryNone;
				[cell.contentView addSubview:self.progressInd];
			}
		}
		//////////////等待圈/////////////////
		
	}
	
	
    return cell;
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc 
{
	/*
	[alarm release];
	[parentController release];
	[cellDescriptionIds release];
	[cellDescriptions release];
	[addAlarmButton release];
	[saveAlarmButton release];
	[cancelAlarmButton release];
	[enablingSwitch release];
	[defaultDetailTextColor release];
	[defaultTextColor release];
	[checkedTextColor release];
	[lastIndexPathPosition release];
	[progressInd release];
	 */

    [super dealloc];
}

-(void)reflashView
{
	self.cellDescriptions = [YCCellDescription makeCellDescriptions:self.cellDescriptionIds alarm:self.alarm];
	[self.tableView reloadData];
}



@end

