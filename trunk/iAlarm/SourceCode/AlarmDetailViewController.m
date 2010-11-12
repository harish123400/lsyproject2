//
//  AlarmDetailViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmDetailViewController.h"
#import "UIUtility.h"
#import "YCCellDescription.h"
#import "YCAlarmEntity.h"
#import "DicManager.h"
#import "YCSound.h"
#import "DataUtility.h"
#import "YCVehicleType.h"
#import "YCRepeatType.h"
#import "YCPositionType.h"
#import "AlarmNameViewController.h"
#import "AlarmVibrateViewController.h"
#import "AlarmLSoundViewController.h"
#import "AlarmLRepeatTypeViewController.h"
#import "AlarmPositionViewController.h"
#import "LocationUtility.h"
#import "AlarmPositionMapViewController.h"
#import <CoreGraphics/CoreGraphics.h>
//#import <CoreLocation/CoreLocation.h>


@implementation AlarmDetailViewController

#pragma mark -
#pragma mark Property

@synthesize alarmTmp;

-(NSArray*) cellDescriptionIds;
{
	if(cellDescriptionIds == nil)
	{
		cellDescriptionIds = [[NSMutableArray alloc] init];
		[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellEnabling]];        //是否启用
		[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellPositionEdit]];    //编辑页面－位置
		[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellRepeat]];          //重复
		[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellRing]];            //声音
		[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellVibrate]];         //震动
		[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellAlarmName]];       //标签
		//[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellDebugCoordinate]]; //debug 
	}
	
	return cellDescriptionIds;
}


#pragma mark - 事件响应
#pragma mark Even response
-(IBAction) enablingSwitchChanged:(id)sender
{
	alarmTmp.enabling = ((UISwitch*)sender).on;
}
-(IBAction)cancelButtonPressed:(id)sender{
	//编辑，由左向右动画
	[self.navigationController popViewControllerAnimated:YES]; 
}

-(IBAction)saveButtonPressed:(id)sender{
	
	////保存闹钟////
	NSMutableArray* alarms = (NSMutableArray*)[DataUtility alarmArray];
	
	//取得索引
	NSUInteger alarmIndex =[DataUtility alarmArray:alarms alarmAtArray:alarm];
	//替换
	if (alarmIndex < alarms.count) 
		[alarms replaceObjectAtIndex:alarmIndex withObject:alarmTmp];
	
	[DataUtility saveAlarmArray:alarms];
	////保存闹钟////
	
	//编辑，由左向右动画
	[self.navigationController popViewControllerAnimated:YES]; 
	
	////刷新上一个视图////
	[self.parentController.tableView reloadData];
	
	[UIUtility sendAlarmUpdateNotification];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"编辑闹钟",@"视图标题");
	alarmTmp = [self.alarm copy];
	
	self.navigationItem.rightBarButtonItem = self.saveAlarmButton;
    self.navigationItem.leftBarButtonItem = self.cancelAlarmButton;
	
	// 定义cell数据
	self.cellDescriptions = [YCCellDescription makeCellDescriptions:self.cellDescriptionIds alarm:alarm];

}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 4;
			break;
		default:
			return 0;
			break;
	}
}
 


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

/*
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{

	NSString *result = @"this is Header";
	return result;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *result = @"this is Footer";
	return result;
}
 */




#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger grow = [self lineNumberAtIndexPath:indexPath];//在整个Table中的行号
	//取cell描述对象
	YCCellDescription *des;
	if (grow < self.cellDescriptions.count) {
		des = (YCCellDescription*)[self.cellDescriptions objectAtIndex:grow];
	}
	if (des == nil) 
		return ;
	
	UIViewController *ctler = des.navActionTarget;
	ctler.parentController = self;
	ctler.alarm = alarmTmp;
	
	//地图特殊处理
	if ([ctler isKindOfClass:[AlarmPositionMapViewController class]]) 
	{
		NSArray *alarmsTemp = [[NSArray alloc] initWithObjects:ctler.alarm,nil];
		((AlarmPositionMapViewController*)ctler).alarms = alarmsTemp;
		[alarmsTemp release];
		//使用闹钟地址作为中心
		((AlarmPositionMapViewController*)ctler).isCenterWithcurrent = NO; 
		
	} 
	[self.navigationController pushViewController:ctler animated:YES];

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger grow = [self lineNumberAtIndexPath:indexPath];//在整个Table中的行号
	
	//取cell描述对象
	YCCellDescription *des;
	if (grow < self.cellDescriptions.count) {
		des = (YCCellDescription*)[self.cellDescriptions objectAtIndex:grow];
	}
	if (des == nil) 
		return indexPath;
	
	switch (des.cellType) {
		case kDefaultCellType:  //defalut type
			return indexPath;
			break;
		case kBoolCellType:     //不允许选择
			return nil;
			break;
		default:
			return indexPath;
			break;
	}
	
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
	[alarmTmp release];
    [super dealloc];
}


@end

