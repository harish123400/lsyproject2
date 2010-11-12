//
//  AlarmPositionMapViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmPositionMapViewController.h"
#import "YCAnnotation.h"
#import "YCAlarmEntity.h"
#import "UIUtility.h"
#import "YCParam.h"
#import "YCLog.h"
#import "AlarmMapSpecifyViewController.h"


@implementation AlarmPositionMapViewController

@synthesize mapView;
@synthesize maskView;
@synthesize activityIndicator;
@synthesize alarms;
@synthesize enablingNeting;        
@synthesize enablingLocation;    
@synthesize mapAnnotations;


#pragma mark - 
#pragma mark - UI元素操作

-(void)addAnnotation
{
	[self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSUInteger i =0; i<self.alarms.count; i++) 
	{
		YCAlarmEntity *alarmTemp = [self.alarms objectAtIndex:i];
		YCAnnotation *annotation = [[YCAnnotation alloc] initWithCoordinate:alarmTemp.coordinate addressDictionary:nil];
		annotation.title = alarmTemp.alarmName;
		annotation.subtitle = alarmTemp.position;
		if ([alarmTemp.alarmId isEqualToString:self.alarm.alarmId]) 
		{
			if ([self isKindOfClass:[AlarmMapSpecifyViewController class]]) 
			{
				annotation.annotationType = YCMapAnnotationTypeStandard;
			}else {
				if(isInTab)
					annotation.annotationType = YCMapAnnotationTypeMovingTarget;
				else 
					annotation.annotationType = YCMapAnnotationTypeLocating;
			}
		}else {
			annotation.annotationType = YCMapAnnotationTypeStandard;
		}


		
		[array addObject:annotation];
		[annotation release];
	}
	self.mapAnnotations = array;
	[array release];
	
	[self.mapView addAnnotations:mapAnnotations];
	
}

//显示覆盖视图
-(void)showMaskView
{
	self.maskView.alpha = 1.0f;
	[self.activityIndicator startAnimating];
}

//关掉覆盖视图
-(void)closeMaskViewWithAnimated:(BOOL)animated
{
	if (animated) 
	{
		[self.activityIndicator stopAnimating];
		[UIView beginAnimations:@"Unmask" context:NULL];
		[UIView setAnimationDuration:0.5];
		self.maskView.alpha = 0.0f;
		[UIView commitAnimations];
	}else {
		[self.activityIndicator stopAnimating];
		self.maskView.alpha = 0.0f;
	}
	
}

//缓存地图数据
-(void)cacheMapData
{
	[[YCLog logSingleInstance] addlog:@"cacheMapData"];
	
	
	//先缩小取得地图数据
	[self.mapView setRegion:self->defaultMapRegion animated:NO];
	
	//放大
	MKCoordinateRegion regionTmp;
	MKCoordinateSpan spanTmp = {10.0,10.0};
	regionTmp.span = spanTmp;
	regionTmp.center = self->defaultMapRegion.center;
	[self.mapView setRegion:regionTmp animated:NO];
	

}


//显示地图
-(void)showMapView
{

	if (self->isAlreadyCenterCoord) 
	{
		[myTimer invalidate];
		[myTimer release];
		myTimer = nil;
		
		//关掉覆盖视图
		[self closeMaskViewWithAnimated:YES];
		if (self->isFirstShow)
		{
			//第一次显示，按默认比例显示到当前位置
			[self.mapView setRegion:self->defaultMapRegion animated:YES];
			self->isFirstShow = NO;
			[[YCLog logSingleInstance] addlog:@"showMapView fisrt"];
		}else {
			//非第一显示，仅设置屏幕中心
			[self.mapView setCenterCoordinate:self->defaultMapRegion.center animated:YES];
			[[YCLog logSingleInstance] addlog:@"showMapView Not fisrt"];
		}
		
		[self addAnnotation];
	}

}


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	mapView.delegate = self;
	self->isFirstShow = YES;
	self->defaultMapRegion.span = [YCParam paramSingleInstance].defaultMapSpan;
	
	self.enablingLocation = YES; // debug - TODO;
	self.enablingNeting = YES;  // debug - TODO;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self showMaskView];
}

-(void)viewDidAppear:(BOOL)animated
{

	[super viewDidAppear:animated];
	
	NSTimeInterval ti = 0.2;
	myTimer = [[NSTimer timerWithTimeInterval:ti target:self selector:@selector(showMapView) userInfo:nil repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
	
}





#pragma mark - 
#pragma mark - MKMapViewDelegate
/*
- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
	NSLog(@"mapViewDidStopLocatingUser");
}
 */

/*
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	
	for (NSUInteger i=0; i<views.count; i++) {
		id viewo = [views objectAtIndex:i];
		if ([viewo isKindOfClass: [MKUserLocation class]]) 
		{
			//设置当前位置为屏幕中心
			CLLocation *location1 = self.mapView.userLocation.location;
			[self.mapView setCenterCoordinate:location1.coordinate animated:YES];

			

			
			
			//设置比例尺
			MKCoordinateSpan span = {0.02,0.02};
			MKCoordinateRegion region;
			region.span = span;
			
			region.center = self.mapView.userLocation.coordinate;
			[self.mapView setRegion:region animated:YES];
			

		}
		
	}
	
}

 */
- (void)showDetails:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
	static NSString* pinViewAnnotationIdentifier = @"pinViewAnnotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	[mapView dequeueReusableAnnotationViewWithIdentifier:pinViewAnnotationIdentifier];
	
	if (!pinView)
	{
		pinView = [[[MKPinAnnotationView alloc]
											   initWithAnnotation:annotation reuseIdentifier:pinViewAnnotationIdentifier] autorelease];
		
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		pinView.rightCalloutAccessoryView = rightButton;
		
	}
	
	UIImageView *sfIconView = nil;
	switch (((YCAnnotation*)annotation).annotationType) 
	{
		case YCMapAnnotationTypeStandard:
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkicon.png"]];
			break;
		case YCMapAnnotationTypeLocating:
			pinView.pinColor = MKPinAnnotationColorPurple;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkicon.png"]];
			break;
		case YCMapAnnotationTypeMovingTarget:
			pinView.pinColor = MKPinAnnotationColorGreen;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkicon.png"]];
			break;
		default:
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkicon.png"]];
			break;
	}
	pinView.leftCalloutAccessoryView = sfIconView;
	[sfIconView release];
	pinView.annotation = annotation;
	
	return pinView;
	
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	[[YCLog logSingleInstance] addlog:@"加载地图完成"];

}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	[[YCLog logSingleInstance] addlog:@"加载地图错误"];
}

#pragma mark -
#pragma mark Memory management
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
