    //
//  AlarmMapspecifyViewController.m
//  iAlarm
//
//  Created by li shiyong on 10-11-12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmMapSpecifyViewController.h"
#import "YCAlarmEntity.h"
#import "YCAnnotation.h"

@implementation AlarmMapSpecifyViewController

#pragma mark -
#pragma mark View lifecycle


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self->defaultMapRegion.center = self.alarm.coordinate;
	self->isAlreadyCenterCoord = YES;
	if (self->isFirstShow)
	[self performSelector:@selector(cacheMapData) withObject:nil afterDelay:0.5];
}


#pragma mark - 
#pragma mark MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
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
