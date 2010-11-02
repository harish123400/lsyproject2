//
//  SettingViewController.m
//  iArrived
//
//  Created by li shiyong on 10-11-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "YCParam.h"
#import "YCDeviceStatus.h"
#import "RegionCenter.h"
#import "DataUtility.h"
#import "YCAlarmEntity.h"

@implementation SettingViewController
@synthesize mapOffsetSwitch;
@synthesize signicantSeriveLabel;
@synthesize standardSeriveLabel;
@synthesize lastStandardSpeedLabel;
@synthesize currentSpeedLabel;
@synthesize regionsView;
@synthesize lastRegionsView;
@synthesize radiusForAlarmField;
@synthesize distanceForProAlarmField;

-(IBAction) radiusChanged:(id)sender
{
	YCParam *param = [YCParam paramSingleInstance];
	param.radiusForAlarm =  [self.radiusForAlarmField.text doubleValue];
	[YCParam updateParam];
}
-(IBAction) distancePreAlarmChanged:(id)sender
{
	YCParam *param = [YCParam paramSingleInstance];
	param.distanceForProAlarm =  [self.distanceForProAlarmField.text doubleValue];
}

-(IBAction) OKButtonPressed:(id)sender
{
	[self distancePreAlarmChanged:nil];
	[self radiusChanged:nil];
}

-(IBAction) refreshButtonPressed:(id)sender
{
	[self.distanceForProAlarmField resignFirstResponder];
	[self.radiusForAlarmField resignFirstResponder];
	
	YCParam *param = [YCParam paramSingleInstance];
	self.mapOffsetSwitch.on = param.enableOffset;
	self.radiusForAlarmField.text = [NSString stringWithFormat:@"%.1f",param.radiusForAlarm];
	self.distanceForProAlarmField.text = [NSString stringWithFormat:@"%.1f",param.distanceForProAlarm];

	
	YCDeviceStatus *devs = [YCDeviceStatus deviceStatusSingleInstance];
	self.lastStandardSpeedLabel.text =[NSString stringWithFormat:@"%.1f",devs.lastStandardLocationSpeed];
	self.currentSpeedLabel.text =[NSString stringWithFormat:@"%.1f",devs.currentLocationSpeed];

	
	if (devs.significantService)
		self.signicantSeriveLabel.text = @"Open";
	else 
		self.signicantSeriveLabel.text = @"Close";
	
	if (devs.standardService)
		self.standardSeriveLabel.text = @"Open";
	else 
		self.standardSeriveLabel.text = @"Close";
	
	NSArray *alarms = [DataUtility alarmArray];
	
	
	NSArray *regions = [RegionCenter regionCenterSingleInstance].regions;
	NSMutableString *regionsStr = [NSMutableString stringWithString:@""];
	for (NSUInteger i=0; i<regions.count; i++) 
	{
		CLRegion * region = [regions objectAtIndex:i];
		YCAlarmEntity *alarm =[DataUtility alarmArray:alarms alarmId:region.identifier];
		CLLocation *locRegion = 
		[[[CLLocation alloc] initWithLatitude:region.center.latitude
									longitude:region.center.longitude] autorelease];
		
		double distanceCur = [devs.currentLocation distanceFromLocation:locRegion];
		double distanceLastSign = [devs.lastSignificantLocation distanceFromLocation:locRegion];
		double distanceLastStand = [devs.lastStandardLocation distanceFromLocation:locRegion];

		[regionsStr appendFormat:@"%@  %6.1f %6.1f %6.1f %6.1f",alarm.alarmName,distanceCur,distanceLastStand,distanceLastSign,alarm.radius];
		[regionsStr appendString:@"\n"];
	}
	regionsView.text = regionsStr;
	 
	
	NSArray *lastRegions = [[RegionCenter regionCenterSingleInstance].regionsForContainsLastLocation allValues];
	NSMutableString *lastRegionsStr = [NSMutableString stringWithString:@""];
	for (NSUInteger i=0; i<lastRegions.count; i++) 
	{
		CLRegion * region = [lastRegions objectAtIndex:i];
		YCAlarmEntity *alarm =[DataUtility alarmArray:alarms alarmId:region.identifier];
		CLLocation *locRegion = 
		[[[CLLocation alloc] initWithLatitude:region.center.latitude
									longitude:region.center.longitude] autorelease];
		
		double distanceCur = [devs.currentLocation distanceFromLocation:locRegion];
		double distanceLastSign = [devs.lastSignificantLocation distanceFromLocation:locRegion];
		double distanceLastStand = [devs.lastStandardLocation distanceFromLocation:locRegion];
		
		[lastRegionsStr appendFormat:@"%@  %6.1f %6.1f %6.1f %6.1f",alarm.alarmName,distanceCur,distanceLastStand,distanceLastSign,alarm.radius];
		[lastRegionsStr appendString:@"\n"];
	}
	self.lastRegionsView.text = lastRegionsStr;
	
}



-(IBAction) mapOffsetSwitchChanged:(id)sender
{
	YCParam *param = [YCParam paramSingleInstance];
	param.enableOffset = self.mapOffsetSwitch.on;
}

-(void) viewWillAppear:(BOOL)animated
{
	[self refreshButtonPressed:nil];
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
}


- (void)dealloc {
    [super dealloc];
}


@end
