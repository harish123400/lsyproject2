    //
//  AlarmMapCurrent.m
//  iAlarm
//
//  Created by li shiyong on 10-11-12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmMapCurrentViewController.h"
#import "YCAlarmEntity.h"


@implementation AlarmMapCurrentViewController

-(void)timeoutForMapCurrentLocation
{
	if (myTimer !=nil) 
	{
		[myTimer invalidate];
		[myTimer release];
		myTimer = nil;
		
		//关掉覆盖视图
		[super closeMaskViewWithAnimated:YES];
		
		//显示重试按钮  TODO
	}
}

//显示地图
-(void)showMapView
{
	//地图定位不可用
	if(!self.enablingLocation || !self.enablingNeting) 
	{
		int tmp = (int)self.alarm.coordinate.latitude;
		if (tmp !=0 ) //闹钟坐标有效，使用闹钟地址
		{
			self->defaultMapRegion.center = self.alarm.coordinate;
			self->isAlreadyCenterCoord = YES;
		}else { //闹钟地址也不可用，做超时处理
			[self timeoutForMapCurrentLocation];
			return;
		}

	}
	
	[super showMapView];
	
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self performSelector:@selector(timeoutForMapCurrentLocation) withObject:nil afterDelay:10.0];//10秒，后超时
}

#pragma mark - 
#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
	if ([annotation isKindOfClass: [MKUserLocation class]]) 
	{
		self->defaultMapRegion.center = self.mapView.userLocation.location.coordinate;
		self->isAlreadyCenterCoord = YES;
		if (self->isFirstShow) [self cacheMapData];	//仅第一显示需要		

		return nil;
	}
	
	return [super mapView:theMapView viewForAnnotation:annotation];
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
