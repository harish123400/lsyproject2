//
//  YCCellDescription.m
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCCellDescription.h"
#import "YCRepeatType.h"
#import "YCPositionType.h"
#import "DicManager.h"
#import "AlarmPositionViewController.h"
#import "AlarmLRepeatTypeViewController.h"
#import "AlarmLSoundViewController.h"
#import "AlarmVibrateViewController.h"
#import "AlarmNameViewController.h"
#import "AlarmPositionMapViewController.h"
#import "AlarmMapCurrentViewController.h"
#import "AlarmMapSpecifyViewController.h"
#import "UIUtility.h"


@implementation YCCellDescription



@synthesize image;
@synthesize text;
@synthesize detailText;
@synthesize navActionTarget;
@synthesize cellType;
@synthesize typeData;
@synthesize ctlTag;
@synthesize ctlAction;
@synthesize cellBusinessType;

@synthesize textColor;
@synthesize detailTextColor;
@synthesize textFont;
@synthesize detailTextFont;

/*
-(id)initWithData:(NSString *)image text:(NSString *) text detailText:(NSString *)detailText actionTarget:(id)actionTarget
{
	if (self = [super init]) {
		self.image = image;
		self.text = text;
		self.detailText = detailText;
		self.actionTarget = actionTarget;
	}
	
	return self;

}
 */

- (void)dealloc {
	[image release];
	[text release];
	[detailText release];
	[navActionTarget release];
	[typeData release];
    [super dealloc];
}

#define  kAlarmPositionViewController      @"kAlarmPositionViewController" 
#define  kAlarmLRepeatTypeViewController   @"kAlarmLRepeatTypeViewController" 
#define  kAlarmLSoundViewController        @"kAlarmLSoundViewController" 
#define  kAlarmVibrateViewController       @"kAlarmVibrateViewController" 
#define  kAlarmNameViewController          @"kAlarmNameViewController" 
//#define  kAlarmPositionMapViewController   @"kAlarmPositionMapViewController"
#define  kAlarmMapCurrentViewController    @"kAlarmMapCurrentViewController"
#define  kAlarmMapSpecifyViewController    @"kAlarmMapSpecifyViewController"
+(UIViewController*) viewController:(NSString*) viewControllerString
{
	static NSMutableDictionary * dic;
	if (dic ==nil) {
		dic = [[NSMutableDictionary alloc] init];
		AlarmPositionViewController * positionCtler ;
		AlarmLRepeatTypeViewController *lrepreatCtler;
		AlarmLSoundViewController *lsoundCtler;
		AlarmVibrateViewController *vibrateCtler;
		AlarmNameViewController * nameCtler;
		AlarmMapCurrentViewController *curMapCtler;
		AlarmMapSpecifyViewController *speMapCtler;

		positionCtler = [[AlarmPositionViewController alloc] initWithStyle:UITableViewStyleGrouped];	
		lrepreatCtler = [[AlarmLRepeatTypeViewController alloc] initWithStyle:UITableViewStyleGrouped];
		lsoundCtler = [[AlarmLSoundViewController alloc] initWithStyle:UITableViewStyleGrouped];
		vibrateCtler = [[AlarmVibrateViewController alloc] initWithStyle:UITableViewStyleGrouped];
		nameCtler = [[AlarmNameViewController alloc] initWithNibName:@"AlarmNameViewController" bundle:nil];
		curMapCtler = [[AlarmMapCurrentViewController alloc] initWithNibName:@"AlarmPositionMapViewController" bundle:nil];
		speMapCtler = [[AlarmMapSpecifyViewController alloc] initWithNibName:@"AlarmPositionMapViewController" bundle:nil];
		
		[dic setObject:positionCtler forKey:kAlarmPositionViewController];
		[dic setObject:lrepreatCtler forKey:kAlarmLRepeatTypeViewController];
		[dic setObject:lsoundCtler forKey:kAlarmLSoundViewController];
		[dic setObject:vibrateCtler forKey:kAlarmVibrateViewController];
		[dic setObject:nameCtler forKey:kAlarmNameViewController];
		[dic setObject:curMapCtler forKey:kAlarmMapCurrentViewController];
		[dic setObject:speMapCtler forKey:kAlarmMapSpecifyViewController];
	}
	
	return [dic objectForKey:viewControllerString];
	
}


+(YCCellDescription*) makeCellDescription: (NSUInteger)desId alarm:(YCAlarmEntity*)alarm
{
	YCCellDescription *celldes  = [[[YCCellDescription alloc] init] autorelease];
	YCPositionType *obj;
	BOOL b = FALSE;
	
	switch (desId) {
		case kDesCellEnabling:
			//启用状态
			celldes.cellBusinessType = kDesCellEnabling;
			celldes.image = nil;
			celldes.text = NSLocalizedString(@"启用",@"指示该闹钟是否被启用的标签");
			celldes.detailText = nil;
			celldes.navActionTarget = nil;
			celldes.cellType = kBoolCellType;
			celldes.typeData = [NSNumber numberWithBool:alarm.enabling];
			celldes.ctlTag = 0;
			celldes.ctlAction = @selector(enablingSwitchChanged:);		
			break;
		case kDesCellCurrentLoc:
			//当前位置
			celldes.cellBusinessType = kDesCellCurrentLoc;
            obj = [[DicManager positionTypeDictionary] objectForKey:@"p001"];
			if ([obj.positionTypeId compare:alarm.positionType.positionTypeId] == NSOrderedSame)
				b = TRUE;
			celldes.image = nil;
			celldes.text = obj.positionTypeName;
			celldes.detailText = nil;
			celldes.navActionTarget = nil;
			celldes.cellType = kCheckCellType;
			celldes.typeData = [NSNumber numberWithBool:b];
			celldes.ctlTag = kCurrentPositionCellTag;
			celldes.ctlAction = nil;
			celldes.textColor = [UIUtility checkedCellTextColor];
			break;
		case kDesCellCurMapLoc:
			//地图指定位置 - 当前位置
			celldes.cellBusinessType = kDesCellCurMapLoc;
			obj = [[DicManager positionTypeDictionary] objectForKey:@"p002"];
			if ([obj.positionTypeId compare:alarm.positionType.positionTypeId] == NSOrderedSame)
				b = TRUE;
			celldes.image = nil;
			celldes.text = obj.positionTypeName;
			celldes.detailText = nil;
			celldes.navActionTarget = [YCCellDescription viewController:kAlarmMapCurrentViewController];
			celldes.cellType = kCheckAndIndCellType;
			celldes.typeData = [NSNumber numberWithBool:b];
			celldes.ctlTag = 0;
			celldes.ctlAction = nil;
			break;
		case kDesCellPosition:
			//位置
			celldes.cellBusinessType = kDesCellPosition;
			celldes.image = nil;
			celldes.text = nil;
			celldes.detailText = alarm.position;
			celldes.navActionTarget = [YCCellDescription viewController:kAlarmPositionViewController];
			celldes.cellType = kNoneCellType;
			celldes.typeData = nil;
			celldes.ctlTag = kPositionCellTag;
			celldes.ctlAction = nil;
			break;
		case kDesCellPositionEdit:
			//位置－编辑页面的
			celldes.cellBusinessType = kDesCellPosition;
			celldes.image = nil;
			celldes.text = NSLocalizedString(@"位置",@"编辑页面的位置的标签");
			celldes.detailText = alarm.position;
			celldes.navActionTarget = [YCCellDescription viewController:kAlarmMapSpecifyViewController];
			celldes.cellType = kDefaultCellType;
			celldes.typeData = nil;
			celldes.ctlTag = kPositionCellTag;
			celldes.ctlAction = nil;
			break;
		case kDesCellRepeat:
			//重复
			celldes.cellBusinessType = kDesCellRepeat;
			celldes.image = nil;
			celldes.text = NSLocalizedString(@"重复",@"指示是否重复使用的的标签"); 
			celldes.detailText = alarm.repeatType.repeatTypeName;
			celldes.navActionTarget = [YCCellDescription viewController:kAlarmLRepeatTypeViewController];
			celldes.cellType = kDefaultCellType;
			celldes.typeData = nil;
			celldes.ctlTag = 0;
			celldes.ctlAction = nil;
			break;
		case kDesCellRing:
			//铃声提示
			celldes.cellBusinessType = kDesCellRing;
				celldes.image = nil;
			celldes.text = NSLocalizedString(@"声音",@"指示是否振铃的标签");
			if (alarm.ring) 
				celldes.detailText = NSLocalizedString(@"打开",@"指示闹钟是否振铃的状态");
			else 
				celldes.detailText = NSLocalizedString(@"关闭",@"指示闹钟是否振铃的状态");
			celldes.navActionTarget = [YCCellDescription viewController:kAlarmLSoundViewController];
			celldes.cellType = kDefaultCellType;
			celldes.typeData = nil;
			celldes.ctlTag = 0;
			celldes.ctlAction = nil;
			break;
		case kDesCellVibrate:
			//震动提示
			celldes.cellBusinessType = kDesCellVibrate;
			celldes.image = nil;
			celldes.text = NSLocalizedString(@"震动",@"指示闹钟是否震动的标签");
			if (alarm.vibrate) 
				celldes.detailText = NSLocalizedString(@"打开",@"指示闹钟是否震动的状态");
			else 
				celldes.detailText = NSLocalizedString(@"关闭",@"指示闹钟是否震动的状态");
			celldes.navActionTarget = [YCCellDescription viewController:kAlarmVibrateViewController];
			celldes.cellType = kDefaultCellType;
			celldes.typeData = nil;
			celldes.ctlTag = 0;
			celldes.ctlAction = nil;
			break;
		case kDesCellAlarmName:
			//标签
			celldes.cellBusinessType = kDesCellAlarmName;
			celldes.image = nil;
			celldes.text = NSLocalizedString(@"标签",@"指示闹钟名字的标签，闹钟名字在闹钟列表上显示");
			celldes.detailText = alarm.alarmName;
			celldes.navActionTarget = [YCCellDescription viewController:kAlarmNameViewController];
			celldes.cellType = kDefaultCellType;
			celldes.typeData = nil;
			celldes.ctlTag = 0;
			celldes.ctlAction = nil;
			break;
		case kDesCellDebugCoordinate:
			//经纬度 坐标 －debug
			celldes.cellBusinessType = kDesCellDebugCoordinate;
			celldes.text = NSLocalizedString(@"坐标",@"");
			celldes.ctlTag = kDebugCoorCellTag;
			NSString *coorString = [[NSString alloc] initWithFormat:@"%f %f",alarm.coordinate.latitude,alarm.coordinate.longitude];
			celldes.detailText = coorString;
			break;
		default:
			break;
	}
	
	return celldes;
	
	/*
	 //交通类型
	 YCCellDescription *lableVeh  = [[YCCellDescription alloc] init];
	 lableVeh.image = nil;
	 lableVeh.text = NSLocalizedString(@"交通工具类型",@"指示使用闹钟人活动范围的标签"); 
	 lableVeh.detailText = alarmTmp.vehicleType.vehicleTypeName;
	 lableVeh.navActionTarget = nil;
	 [cellDesciptions addObject:lableVeh];
	 [lableVeh release];
	 */
	

}

+(NSArray*) makeCellDescriptions:(NSArray *)desIds alarm:(YCAlarmEntity*)alarm;
{
	/*
	static NSMutableArray *cellDesciptions;
	if(cellDesciptions)
		[cellDesciptions release];
	cellDesciptions = [[NSMutableArray alloc] init];
	 */
	NSMutableArray *cellDesciptions = [[[NSMutableArray alloc] init] autorelease];
	
	for (NSUInteger i =0; i<desIds.count; i++) {
		NSUInteger desid = [((NSNumber*)[desIds objectAtIndex:i]) integerValue];
		YCCellDescription * d =[YCCellDescription makeCellDescription:desid alarm:alarm ];
		[cellDesciptions addObject:d];
	}
	
	return cellDesciptions;
	
}

@end
