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
#import "AlarmNameViewController.h"


@implementation AlarmPositionMapViewController


#pragma mark -
#pragma mark 属性

@synthesize mapView;
@synthesize maskView;
@synthesize activityIndicator;
@synthesize alarms;
@synthesize newAlarm; 
@synthesize mapAnnotations;
@synthesize currentLocationBarItem;
@synthesize annotationManipulating;
@synthesize alarmTemp;

- (MKReverseGeocoder *)reverseGeocoder:(CLLocationCoordinate2D)coordinate
{
    if (reverseGeocoder) {
		[reverseGeocoder release];
	}
	reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
	
	return reverseGeocoder;
}


#pragma mark -
#pragma mark Event
-(IBAction)currentLocationButtonPressed:(id)sender
{
	if (self.mapView.userLocation.location)
	{
		self->isCurrentLocationAtCenterRegion = YES;
		//设置屏幕中心
		CLLocationCoordinate2D coordOfCurrent = self.mapView.userLocation.location.coordinate;
		//[self.mapView setCenterCoordinate:coordOfCurrent animated:YES];

		self->defaultMapRegion.center = coordOfCurrent;
		[self.mapView setRegion:self->defaultMapRegion animated:YES];
	}
}

-(IBAction)doneButtonPressed:(id)sender
{	
	//覆盖父类
	self.alarm.coordinate = self.annotationManipulating.coordinate;
	self.alarm.alarmName = self.annotationManipulating.title;
	self.alarm.position = self.annotationManipulating.subtitle;
	[self.parentController reflashView];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 
#pragma mark - UI元素操作

-(void)selectAnnotationAtIndex:(NSNumber*)index
{
	[self.mapView selectAnnotation:[self.mapAnnotations objectAtIndex:[index intValue]] animated:YES];
}


-(void)addAnnotation
{
	[self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSUInteger i =0; i<self.alarms.count; i++) 
	{
		YCAlarmEntity *temp = [self.alarms objectAtIndex:i];
		YCAnnotation *annotation = [[YCAnnotation alloc] initWithCoordinate:temp.coordinate addressDictionary:nil];
		annotation.title = temp.alarmName;
		annotation.subtitle = temp.position;
		annotation.coordinate = temp.coordinate;

		if ([self isKindOfClass:[AlarmMapSpecifyViewController class]]) 
		{
			annotation.annotationType = YCMapAnnotationTypeLocating;
			if(self.newAlarm)  //AlarmNew
			{
				annotation.title = NSLocalizedString(@"Drag to Move Pin",@"使用地图定位，图钉的开始提示");
				annotation.subtitle = @"";
			}
		}else {
			if([temp.alarmId isEqualToString:self.alarm.alarmId])
			{
				annotation.annotationType = YCMapAnnotationTypeMovingTarget;
			}else{
				annotation.annotationType = YCMapAnnotationTypeStandard;
			}
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
			[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:0] afterDelay:2.0];
		}else {
			//非第一显示，仅设置屏幕中心
			//[self.mapView setCenterCoordinate:self->defaultMapRegion.center animated:YES];
			[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:0] afterDelay:1.0];
		}
	
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
	//Done按钮
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self->defaultMapRegion.span = [YCParam paramSingleInstance].defaultMapSpan;
	[self addAnnotation];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(@"位置",@"视图标题");
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


- (void)showDetails:(id)sender
{
	//back按钮
	self.title = nil;
	
	//取得当前操作的Annotation
	MKAnnotationView *annotationView = (MKAnnotationView *)((UIView*)sender).superview.superview;
	self.annotationManipulating = annotationView.annotation;
	
	AlarmNameViewController *nameViewCtl = [[AlarmNameViewController alloc] initWithNibName:@"AlarmNameViewController" bundle:nil];
    self.alarmTemp = [self.alarm copy];
	nameViewCtl.alarm = self.alarmTemp;
	nameViewCtl.alarm.alarmName = self.annotationManipulating.title;
	nameViewCtl.parentController = self;
	[self.navigationController pushViewController:nameViewCtl animated:YES];
	[nameViewCtl release];
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
			pinView.draggable = YES;
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState 
{
	self.annotationManipulating = annotationView.annotation;
	switch (newState) 
	{
		case MKAnnotationViewDragStateStarting:  //开始拖拽的－紫色
			((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorPurple;
			break;
		case MKAnnotationViewDragStateEnding:   //结束拖拽－显示地址
			//坐标
			self.alarm.coordinate = annotationView.annotation.coordinate;
			//反转坐标－地址
			reverseGeocoder = [self reverseGeocoder:annotationView.annotation.coordinate]; 
			reverseGeocoder.delegate = self;
			((YCAnnotation*) annotationView.annotation).subtitle = @"";
			[reverseGeocoder start];
			//激活Done按钮
			self.navigationItem.rightBarButtonItem.enabled = YES;
			break;
		default:
			break;

	}

}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	//设置当前位置bar按钮风格
	if (self->isCurrentLocationAtCenterRegion) 
	{
		[[YCLog logSingleInstance] addlog:@"isCurrentLocationAtCenterRegion == YES"];
		self.currentLocationBarItem.style =  UIBarButtonItemStyleDone;
		self->isCurrentLocationAtCenterRegion = NO;
	}else {
		[[YCLog logSingleInstance] addlog:@"isCurrentLocationAtCenterRegion == NO"];
		self.currentLocationBarItem.style =  UIBarButtonItemStyleBordered;
	}

}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate

-(void)resetAnnotation:(NSString*)subtitle
{
	self.annotationManipulating.subtitle = subtitle;
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	NSString *title = [UIUtility titleStringFromPlacemark:placemark];
	NSString *position = [UIUtility positionStringFromPlacemark:placemark];
	
	if (!self.alarm.nameChanged) {
		if (title == nil) 
			title = kDefaultLocationAlarmName;
		self->alarm.alarmName = title;
	}
	self.annotationManipulating.title = self->alarm.alarmName;
	self.annotationManipulating.subtitle = @"";
	[self performSelector:@selector(resetAnnotation:) withObject:position afterDelay:0.5]; //延时生成，获得动画效果
	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	double lat = geocoder.coordinate.latitude;
	double lon = geocoder.coordinate.longitude;
	NSString *latstr = [UIUtility convertLatitude:lat decimal:0];
	NSString *lonstr = [UIUtility convertLongitude:lon decimal:0];
	NSString *position = [[[NSString alloc] initWithFormat:@"%@ %@",latstr,lonstr] autorelease];
	self.annotationManipulating.subtitle = @"";
	[self performSelector:@selector(resetAnnotation:) withObject:position afterDelay:0.5]; //延时生成，获得动画效果
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


#pragma mark -
#pragma mark YCNavSuperControllerProtocol
-(void)reflashView
{
	self.annotationManipulating.title = self.alarmTemp.alarmName;
	//激活Done按钮
	self.navigationItem.rightBarButtonItem.enabled = YES;
}




@end
