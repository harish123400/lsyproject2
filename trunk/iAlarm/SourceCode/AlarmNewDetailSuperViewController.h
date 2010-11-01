//
//  AlarmNewEditSuperViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YCAlarmEntity;

@interface AlarmNewDetailSuperViewController : UITableViewController {
	YCAlarmEntity *alarm;
	
	UITableViewController *parentController; //父控制器
	NSArray* cellDescriptionIds;//TableCell描述Id的数组
	NSArray* cellDescriptions; //TableCell描述数组
	
	UIBarButtonItem *addAlarmButton;       //添加按钮
	UIBarButtonItem *saveAlarmButton;      //添加按钮
	UIBarButtonItem *cancelAlarmButton;    //取消按钮
	

	UISwitch *enablingSwitch;          //是否启用的控件
	UIColor *defaultDetailTextColor;
	UIColor *defaultTextColor;
	UIColor *checkedTextColor;
	
	NSIndexPath    *lastIndexPathPosition;  //使用当前位置或地图的cell
	UIActivityIndicatorView	*progressInd;  //“当前位置”cell处理“等待圈”控件

}

@property(nonatomic,retain) YCAlarmEntity *alarm;
@property(nonatomic,retain) UITableViewController *parentController;
@property(nonatomic,retain) NSArray* cellDescriptions;
@property (nonatomic,retain,readonly) NSArray* cellDescriptionIds;


@property (nonatomic, retain,readonly) UISwitch *enablingSwitch;
@property (nonatomic,readonly)  UIColor *defaultDetailTextColor;
@property (nonatomic,readonly)  UIColor *defaultTextColor;
@property (nonatomic,readonly)  UIColor *checkedTextColor;

@property (nonatomic,retain,readonly)  UIBarButtonItem *addAlarmButton;
@property (nonatomic,retain,readonly)  UIBarButtonItem *saveAlarmButton;
@property (nonatomic,retain,readonly)  UIBarButtonItem *cancelAlarmButton;
@property (nonatomic, retain) NSIndexPath * lastIndexPathPosition;
@property (nonatomic, retain,readonly) UIActivityIndicatorView *progressInd;


//取得在整个Table中的行号
-(NSUInteger) lineNumberAtIndexPath:(NSIndexPath *)indexPath;
//根据viewTag取得描述对象
-(id)cellDescriptions:(NSArray*)theCellDescriptions viewTag:(NSUInteger)viewTag;

-(IBAction)enablingSwitchChanged:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)addButtonPressed:(id)sender;



@end
