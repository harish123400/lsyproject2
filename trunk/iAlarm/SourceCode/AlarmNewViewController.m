//
//  AlarmDetailViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmNewViewController.h"
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
#import "CheckmarkDisclosureIndicatorCell.h"
#import "YCLog.h"
#import "YCParam.h"
#import "AlarmPositionMapViewController.h"
#import "AlarmModify.h"


@implementation AlarmNewViewController


#pragma mark -
#pragma mark Property
@synthesize bestEffortAtLocation;

-(NSArray*) cellDescriptionIds;
{
	
	if(cellDescriptionIds == nil)
	{
	cellDescriptionIds = [[NSMutableArray alloc] init];
	[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellCurrentLoc]];      //当前位置
	[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellPositionEdit]];    //地图
	[(NSMutableArray*)cellDescriptionIds addObject:[NSNumber numberWithInteger:kDesCellPosition]];        //位置
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
-(IBAction)cancelButtonPressed:(id)sender{

	//创建，由上下动画
	[UIUtility navigationController:self.navigationController 
					 viewController:self 
							 isPush:NO
			   durationForAnimation:0.75
				  TransitionForType:kCATransitionPush 
			   TransitionForSubtype:kCATransitionFromBottom];
	
}

-(IBAction)addButtonPressed:(id)sender{
	
	////保存闹钟////
	NSMutableArray* alarms = (NSMutableArray*)[DataUtility alarmArray];
	//新创建的闹钟就加入数组
	[alarms insertObject:alarm atIndex:0];
	
	[DataUtility saveAlarmArray:alarms];
	////保存闹钟////
	
	
	
	//创建，由下向上动画
	[UIUtility navigationController:self.navigationController 
					 viewController:self 
							 isPush:NO
			   durationForAnimation:0.75
				  TransitionForType:kCATransitionPush 
			   TransitionForSubtype:kCATransitionFromBottom];
	 
	 
	
	////刷新上一个视图////
	[parentController.tableView reloadData];
	[UIUtility sendAlarmUpdateNotification];
	
}

#pragma mark -
#pragma mark Location,reverseGeocoder manager
- (CLLocationManager *)locationManager 
{
	
    if (locationManager != nil) {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.purpose = @"我的位置闹钟in";
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	locationManager.distanceFilter = kCLDistanceFilterNone;
	[locationManager setDelegate:self];
	
	return locationManager;
}

- (MKReverseGeocoder *)reverseGeocoder:(CLLocationCoordinate2D)coordinate
{
    if (reverseGeocoder) {
		[reverseGeocoder release];
	}
	reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
	
	return reverseGeocoder;
}



#pragma mark -
#pragma mark Util

-(void)showLocationProgress
{	
	//重新生成cell描述数组
	//self.cellDescriptions = [YCCellDescription makeCellDescriptions:self.cellDescriptionIds alarm:alarm];
	//设定等待文字
	YCCellDescription *cellDes = [self cellDescriptions:self.cellDescriptions viewTag:kPositionCellTag];
	cellDes.textColor = [UIColor grayColor];
	cellDes.text = NSLocalizedString(@"正在定位...",@"");
	cellDes.detailText = @"";
	cellDes.typeData = [NSNumber numberWithBool:YES];//显示等待圈
	[self.tableView reloadData];
	
	/*
	//显示等待圈
	UITableViewCell * posCell = (UITableViewCell *)[self.tableView viewWithTag: kPositionCellTag];
	posCell.accessoryType = UITableViewCellAccessoryNone;
	[posCell.contentView addSubview:self.progressInd];
	 */
}

-(void)hideLocationProgress
{
	//设定等待文字
	YCCellDescription *cellDes = [self cellDescriptions:self.cellDescriptions viewTag:kPositionCellTag];
	cellDes.typeData = [NSNumber numberWithBool:NO];//隐藏等待圈
	[self.tableView reloadData];
	/*
	UIActivityIndicatorView * locind = (UIActivityIndicatorView *)[self.view viewWithTag: kPositionCellIndTag];
	[locind removeFromSuperview];
	 */
}

-(void)beginReverse
{
	CLLocationCoordinate2D coordinate = [self.bestEffortAtLocation coordinate];
	//坐标
	self.alarm.coordinate = coordinate;
	self.alarm.locationAccuracy = self.bestEffortAtLocation.horizontalAccuracy;
	
	//反转坐标－地址
	reverseGeocoder = [self reverseGeocoder:coordinate]; 
	reverseGeocoder.delegate = self;
	[reverseGeocoder start];
}

-(void)endReverse
{
	//隐藏等待圈
	//[self hideLocationProgress];
	
	//重新生成cell描述数组
	self.cellDescriptions = [YCCellDescription makeCellDescriptions:self.cellDescriptionIds alarm:alarm];
	[self.tableView reloadData];
	// 改变保存按钮状态，显示等待指示控件
	locationing = NO;
	self.addAlarmButton.enabled = YES;
}


-(void)beginLocation
{
	// 改变保存按钮状态，显示等待指示控件
	locationing = YES;
	self.addAlarmButton.enabled = NO;
	[self showLocationProgress];
	//[self performSelector:@selector(showLocationProgress) withObject:nil afterDelay:1.5];


	// Start the location manager.
	[[self locationManager] startUpdatingLocation];
	[self performSelector:@selector(endLocation) withObject:nil afterDelay:[YCParam paramSingleInstance].timeSpanForStandardLocation];
}

-(void)endLocation
{
	// Stop the location manager.
	[[self locationManager] stopUpdatingLocation];  
	
	if(self.bestEffortAtLocation==nil)
	{
		//重新生成cell描述数组
		self.cellDescriptions = [YCCellDescription makeCellDescriptions:self.cellDescriptionIds alarm:alarm];
		YCCellDescription *cellDes = [self cellDescriptions:self.cellDescriptions viewTag:kPositionCellTag];
		cellDes.detailTextColor = [UIColor grayColor];
		cellDes.detailText = NSLocalizedString(@"定位失败！请在“设置”中打开定位服务，或稍候再试。",@"定位失败的提示");
		//self.alarm.position = NSLocalizedString(@"定位失败！请在“设置”中打开定位服务，或稍候再试。",@"定位失败的提示");
		[self.tableView reloadData];
		
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"alarm-didUpdateToLocation 无效精度:%.1f",self.bestEffortAtLocation.horizontalAccuracy ]];
		[[YCLog logSingleInstance] addlog:@"返回"];
	}else {
		[self beginReverse];
	}

	locationing = NO;
	
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.addAlarmButton;
    self.navigationItem.leftBarButtonItem = self.cancelAlarmButton;
	self.addAlarmButton.enabled = NO;
	
	// 定义cell数据
	self.cellDescriptions = [YCCellDescription makeCellDescriptions:self.cellDescriptionIds alarm:alarm];
	
	[self performSelector:@selector(beginLocation) withObject:nil afterDelay:1.0];  //等待x秒,执行定位
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(@"添加闹钟",@"视图标题");
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return 4;
			break;
		default:
			return 0;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
 

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{

	NSString *result = nil;
	if (section == 0) 
	{
		result = NSLocalizedString(@"位置",@"编辑页面的位置的标签");
	}
	return result;
	
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *result = @"this is Footer";
	return result;
}
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//取消行选中
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (locationing) 
		return;
	
	
	NSUInteger grow = [self lineNumberAtIndexPath:indexPath];//在整个Table中的行号
	//取cell描述对象
	YCCellDescription *des;
	if (grow < self.cellDescriptions.count) {
		des = (YCCellDescription*)[self.cellDescriptions objectAtIndex:grow];
	}
	if (des == nil) 
		return ;

	

	///////地址类型的单选 ///////
	if (des.cellBusinessType == kDesCellCurrentLoc || des.cellBusinessType == kDesCellCurMapLoc) 
	{
		int newRow = [indexPath row];
		int oldRow = (lastIndexPathPosition != nil) ? [lastIndexPathPosition row] : -1;
		
		if (newRow != oldRow)
		{
			UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
			newCell.accessoryType = UITableViewCellAccessoryCheckmark;
			newCell.textLabel.textColor = self.checkedTextColor;
			
			UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPathPosition]; 
			oldCell.accessoryType = UITableViewCellAccessoryNone;
			oldCell.textLabel.textColor = self.defaultTextColor;
			
			lastIndexPathPosition = indexPath;
		}
		
		YCPositionType *pt;
		if(des.ctlTag == kCurrentPositionCellTag)
			pt = [DicManager positionTypeForSortId:0];
		else
			pt = [DicManager positionTypeForSortId:1];
		self.alarm.positionType = pt;
	}
	///////地址类型的单选 ///////
	
	//执行定位
	//if (des.ctlTag == kCurrentPositionCellTag) 
	if (des.cellBusinessType == kDesCellCurrentLoc)
	{
		[self performSelector:@selector(beginLocation) withObject:nil afterDelay:0.35];  //等待x秒
		return;
	}
	
	
	///////nav 导航///////
	UIViewController *ctler = des.navActionTarget;
	if(ctler == nil)
		return;
	ctler.parentController = self;
	ctler.alarm = alarm;
	
	//地图特殊处理
	if ([ctler isKindOfClass:[AlarmPositionMapViewController class]]) 
	{
		NSArray *alarmsTemp = [[NSArray alloc] initWithObjects:ctler.alarm,nil];
		((AlarmPositionMapViewController*)ctler).alarms = alarmsTemp;
		[alarmsTemp release];
		((AlarmPositionMapViewController*)ctler).newAlarm = YES;
	} 
	
	//back按钮
	self.title = nil;
	
	[self.navigationController pushViewController:ctler animated:YES];
	///////nav 导航///////



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
		case kBoolCellType:     //不允许选中
			return nil;
			break;
		//case kCheckCellType:       //不允许选中   //效果不好
		//case kCheckAndIndCellType: //不允许选中
		//	return nil;
		//	break;
		default:
			return indexPath;
			break;
	}
	
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	[[YCLog logSingleInstance] addlog:@"alarm-didUpdateToLocation"];
    
	NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    if (abs(howRecent) > 5.0) return;
	
	if (newLocation.horizontalAccuracy > [[YCParam paramSingleInstance] invalidLocationAccuracy])
	{
		[[YCLog logSingleInstance] addlog:[NSString stringWithFormat:@"alarm-didUpdateToLocation 无效精度:%.1f",newLocation.horizontalAccuracy ]];
		[[YCLog logSingleInstance] addlog:@"返回"];
		return;
	}
	
	if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) 
	{
        self.bestEffortAtLocation = newLocation;
		if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy)
		{
			[[self locationManager] stopUpdatingLocation];
		}
    }
	 
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	//self.addAlarmButton.enabled = NO;
	NSLog(@"didFailWithError.");
}


#pragma mark -
#pragma mark MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	
	NSString * locality = placemark.locality; //城市
	NSString * thoroughfare = placemark.thoroughfare; //街道
	NSString * subthoroughfare = placemark.subThoroughfare;//街道号
	
	self.alarm.position = [[[NSString alloc] initWithFormat:@"%@%@,%@",thoroughfare,subthoroughfare,locality] autorelease];
	if (!self.alarm.nameChanged) {
		self.alarm.alarmName = [[[NSString alloc] initWithFormat:@"%@",thoroughfare] autorelease];
	}
	
	[self performSelector:@selector(endReverse) withObject:nil afterDelay:0.1];  //数据更新后，等待x秒
	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    //NSLog(@"MKReverseGeocoder has failed.");
	double lat = self.alarm.coordinate.latitude;
	double lon = self.alarm.coordinate.longitude;
	NSString *latstr = [UIUtility convertLatitude:lat decimal:0];
	NSString *lonstr = [UIUtility convertLongitude:lon decimal:0];
	NSString *position = [[[NSString alloc] initWithFormat:@"%@ %@",latstr,lonstr] autorelease];
	self.alarm.position = position;
	[self performSelector:@selector(endReverse) withObject:nil afterDelay:0.1];  //等待x秒，结束
}


#pragma mark -
#pragma mark Memory management
- (void)dealloc {
	
	[locationManager release];
	[reverseGeocoder release];
	[bestEffortAtLocation release];
	 
    [super dealloc];
}


@end

