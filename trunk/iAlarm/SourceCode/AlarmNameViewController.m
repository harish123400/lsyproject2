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


-(IBAction) backButtonPressed:(id)sender
{	
	//闹钟名是否为空
	if ([self.alarmNameTextField.text length] != 0) {
		//手工改动了闹钟的名字
		if ([self.alarm.alarmName compare:self.alarmNameTextField.text] != NSOrderedSame) {
			self.alarm.nameChanged = YES;
			self.alarm.alarmName = self.alarmNameTextField.text;
		}
		
		self.parentController.cellDescriptions = 
		[YCCellDescription makeCellDescriptions:self.parentController.cellDescriptionIds alarm:self.alarm];
	}

	[self.parentController.tableView reloadData];
	
	[self.alarmNameTextField keyboardAppearance];
	
}

-(IBAction) textFieldDoneEditing:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"标签",@"指示闹钟名字的标签，闹钟名字在闹钟列表上显示");
	//修改输入文本筐的风格，设置焦点
	alarmNameTextField.borderStyle = UITextBorderStyleRoundedRect;
	alarmNameTextField.textColor = [UIUtility checkedCellTextColor];
	[alarmNameTextField becomeFirstResponder];  //调用键盘
	self.alarmNameTextField.enablesReturnKeyAutomatically = YES; //闹钟名为空，Done按钮不可用
	
}

- (void)viewWillAppear:(BOOL)animated
{
	alarmNameTextField.text = alarm.alarmName;
	[self.view reloadInputViews];
	//不好用，没道理
	//self.navigationItem.backBarButtonItem.action = @selector(backButtonPressed:);
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self backButtonPressed:nil];
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	
	////分类的数据////
	[self.parentViewController release];
	[self.alarm release];
	////分类的数据////
	
	[self.alarmNameTextField release];
    [super dealloc];
}


@end
