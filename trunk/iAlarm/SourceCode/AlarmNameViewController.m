//
//  AlarmNameViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmNameViewController.h"
#import "AlarmNewDetailSuperViewController.h"
#import "YCAlarmEntity.h"
#import "YCCellDescription.h"
#import "UIUtility.h"


@implementation AlarmNameViewController


@synthesize alarmNameTextField;
@synthesize alarmPositionLabel;

-(IBAction)doneButtonPressed:(id)sender
{	
	/////////覆盖父类
	///
	//闹钟名是否为空
	if ([self.alarmNameTextField.text length] != 0) {
		//手工改动了闹钟的名字
		if (![self.alarm.alarmName isEqualToString:self.alarmNameTextField.text])
		{
			self.alarm.nameChanged = YES;
			self.alarm.alarmName = self.alarmNameTextField.text;
		}
		
	}else {
		self.alarm.nameChanged = NO;
		self.alarm.alarmName = kDefaultLocationAlarmName;
	}
	
	[self.parentController reflashView];
	[self.alarmNameTextField keyboardAppearance];
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) textFieldDoneEditing:(id)sender
{
	[self doneButtonPressed:nil];
}

-(IBAction) textFieldChanged:(id)sender
{
	if ( [self.alarm.alarmName isEqualToString:self.alarmNameTextField.text] //手工改动了闹钟的名字
		)//|| [self.alarmNameTextField.text length] == 0) //闹钟名是否为空
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"标签",@"指示闹钟名字的标签，闹钟名字在闹钟列表上显示");
	//修改输入文本筐的风格，设置焦点
	alarmNameTextField.borderStyle = UITextBorderStyleRoundedRect;
	alarmNameTextField.textColor = [UIUtility checkedCellTextColor];
	[alarmNameTextField becomeFirstResponder];  //调用键盘
	self.alarmNameTextField.enablesReturnKeyAutomatically = NO; 
	
	self.alarmPositionLabel.font = [UIFont systemFontOfSize:15];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.alarmNameTextField.text = alarm.alarmName;
	self.alarmPositionLabel.text = alarm.position;
	[self.view reloadInputViews];
	//不好用，没道理
	//self.navigationItem.backBarButtonItem.action = @selector(backButtonPressed:);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.alarmNameTextField = nil;
}


- (void)dealloc {
	/*
	////分类的数据////
	[self.parentViewController release];
	[self.alarm release];
	////分类的数据////
	 */
	
	[self.alarmNameTextField release];
    [super dealloc];
}


@end
