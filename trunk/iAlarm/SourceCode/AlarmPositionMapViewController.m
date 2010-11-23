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
@synthesize currentPinBarItem;
@synthesize annotationManipulating;
@synthesize alarmTemp;
@synthesize searchBar;
@synthesize searchBarItem;

- (MKReverseGeocoder *)reverseGeocoder:(CLLocationCoordinate2D)coordinate
{
    if (reverseGeocoder) {
		[reverseGeocoder release];
	}
	reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
	reverseGeocoder.delegate = self;
	
	return reverseGeocoder;
}

#pragma mark - 
#pragma mark - UI元素操作

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
		[UIView setAnimationDuration:2.5];
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
	MKCoordinateSpan spanTmp = {90.0,90.0};
	regionTmp.span = spanTmp;
	regionTmp.center = self->defaultMapRegion.center;
	[self.mapView setRegion:regionTmp animated:NO];
	
}


-(BOOL) isValidCoordinate:(CLLocationCoordinate2D)coordinate
{
	BOOL retVal = NO;
	int la = (int)coordinate.latitude;
	int lo = (int)coordinate.longitude;
	if (la == 0 && lo == 0 ) 
		retVal = NO;
	else 
		retVal = YES;
	
	return retVal;
}

-(BOOL) isValidSpan:(MKCoordinateSpan)span
{	
	double lad = span.latitudeDelta;
	double lod = span.longitudeDelta;
	if (lad > 120.0 || lad < 0.00001) return NO;
	if (lod > 120.0 || lod < 0.00001) return NO;
	
	return YES;
}

-(BOOL)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{	
	///////////////////////
	//对区域数据进行校验
	if(![self isValidCoordinate:region.center]) return NO;
	if(![self isValidSpan:region.span]) return NO;
	///////////////////////	
	
	[self.mapView setRegion:region animated:animated];
	return YES;
}

//选中Annotation －显示的标题
-(void)selectAnnotationAtIndex:(NSNumber*)index
{
	NSInteger nIndex = [index intValue];
	if(nIndex >=0 && nIndex < self.mapAnnotations.count)
		[self.mapView selectAnnotation:[self.mapAnnotations objectAtIndex:[index intValue]] animated:YES];
}


//显示地图
-(void)showMapView
{
	//关掉覆盖视图
	[self closeMaskViewWithAnimated:YES];
	//第一次显示，按默认比例显示到当前位置
	BOOL b = [self setRegion:self->defaultMapRegion animated:YES];
	
	if (!b) { //加载上一次的正确的区域
		[self setRegion:[YCParam paramSingleInstance].lastLoadMapRegion animated:YES];
	}
	
	NSInteger index = [self.mapAnnotations indexOfObject:self.annotationManipulating];
	[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:1.5];
	
	//显示完成后，把maskview的触摸事件绑定
	[self.maskView addTarget:self action:@selector(cancelSearchButtonPressed:) forControlEvents:UIControlEventTouchDown];
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
		
		if ([self isKindOfClass:[AlarmPositionMapViewController class]]) 
		{
			if(self.newAlarm)  //AlarmNew
			{
				annotation.title = NSLocalizedString(@"Drag to Move Pin",@"使用地图定位，图钉的开始提示");
				annotation.subtitle = @"";
				annotation.annotationType = YCMapAnnotationTypeLocating;
			}else {
				annotation.annotationType = YCMapAnnotationTypeStandardEnabledDrag;
			}

		}else {
			if([temp.alarmId isEqualToString:self.alarmTemp.alarmId])
			{
				annotation.annotationType = YCMapAnnotationTypeMovingTarget;
			}else{
				annotation.annotationType = YCMapAnnotationTypeStandard;
			}
		}
		
		if([temp.alarmId isEqualToString:self.alarmTemp.alarmId])
			self.annotationManipulating = annotation;
		
		
		[array addObject:annotation];
		[annotation release];
	}
	self.mapAnnotations = array;
	[array release];
	
	
	[self.mapView addAnnotations:mapAnnotations];
	
}





#pragma mark -
#pragma mark Event


-(void)setDoneStyleToBarButtonItem:(UIBarButtonItem*)buttonItem
{
	buttonItem.style =  UIBarButtonItemStyleDone;
}

-(IBAction)currentLocationButtonPressed:(id)sender
{
	/*
	if (self.mapView.userLocation.location)
	{
		self->isCurrentLocationAtCenterRegion = YES;
		//设置屏幕中心，与范围
		CLLocationCoordinate2D coordOfCurrent = self.mapView.userLocation.location.coordinate;
		self->defaultMapRegion.center = coordOfCurrent;
		[self setRegion:self->defaultMapRegion animated:YES];
	}
	 */
	if (self.mapView.userLocation.location)
	{
		self->isCurrentLocationAtCenterRegion = YES;
		//设置屏幕中心，与范围
		CLLocationCoordinate2D coordOfCurrent = self.mapView.userLocation.location.coordinate;
		self->defaultMapRegion.center = coordOfCurrent;
		[self setRegion:self->defaultMapRegion animated:YES];
		[self performSelector:@selector(setDoneStyleToBarButtonItem:) withObject:self.currentLocationBarItem afterDelay:0.2];
	}
}
-(IBAction)currentPinButtonPressed:(id)sender
{	
	if ([self isValidCoordinate:self.annotationManipulating.coordinate])
	{
		//仅仅设置中心
		[self.mapView setCenterCoordinate:self.annotationManipulating.coordinate animated:YES];
		[self performSelector:@selector(setDoneStyleToBarButtonItem:) withObject:self.currentPinBarItem afterDelay:0.2];
	}
}

-(IBAction)resetPinButtonPressed:(id)sender
{
	[self.mapView removeAnnotation:self.annotationManipulating];
	self.annotationManipulating.coordinate = self.mapView.region.center;
	[self.mapView addAnnotation:self.annotationManipulating];
	//反转坐标－地址
	((YCAnnotation*) self.annotationManipulating).subtitle = @"";
	reverseGeocoder = [self reverseGeocoder:self.annotationManipulating.coordinate]; 
	[reverseGeocoder start];
	//选中
	NSInteger index = [self.mapAnnotations indexOfObject:self.annotationManipulating];
	[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:1.5];
	
}



-(IBAction)doneButtonPressed:(id)sender
{	
	//覆盖父类
	self.alarm.coordinate = self.alarmTemp.coordinate;
	self.alarm.alarmName = self.alarmTemp.alarmName;
	self.alarm.position = self.alarmTemp.position;
	[self.parentController reflashView];
	[self.navigationController popViewControllerAnimated:YES];
}



-(IBAction)searchButtonPressed:(id)sender
{
	self.maskView.alpha = 0.90;
	self.maskView.backgroundColor = [UIColor darkGrayColor];
	
	self.searchBar.hidden = NO;
	self.maskView.hidden = NO;
	[self.searchBar becomeFirstResponder];  //search bar调用键盘
}

-(IBAction)cancelSearchButtonPressed:(id)sender
{
	self.searchBar.hidden = YES;
	self.maskView.hidden = YES;
	[self.searchBar resignFirstResponder];  //search bar放弃键盘
}


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	mapView.delegate = self;
	self->isFirstShow = YES;
	self.navigationItem.rightBarButtonItem.enabled = NO;//Done按钮
	
	//search bar
	self.searchBar.delegate = self;
	self.searchBar.hidden = YES;
	
	//判断闹钟坐标是否有效
	if (![self isValidCoordinate:self.alarm.coordinate]) 
		self.alarm.coordinate = [YCParam paramSingleInstance].lastLoadMapRegion.center;
	
	self.alarmTemp = [self.alarm copy];
	
	//self->defaultMapRegion.span = [YCParam paramSingleInstance].defaultMapSpan;
	//self->defaultMapRegion.center = self.alarmTemp.coordinate;
	self->defaultMapRegion = MKCoordinateRegionMakeWithDistance(self.alarmTemp.coordinate,1500.0,1500.0);

	[self showMaskView];
	[self addAnnotation];
	[self performSelector:@selector(showMapView) withObject:nil afterDelay:0.5];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(@"位置",@"视图标题");
	[self performSelector:@selector(setDoneStyleToBarButtonItem:) withObject:self.currentPinBarItem afterDelay:0.5];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	//保存最后加载的区域
	[YCParam paramSingleInstance].lastLoadMapRegion = self.mapView.region;
}


#pragma mark - 
#pragma mark - MKMapViewDelegate
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
	NSLog(@"开始加载地图");
}


- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	NSLog(@"完成加载地图");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
	NSLog(@"失败加载地图");
}



- (void)showDetails:(id)sender
{
	//back按钮
	self.title = nil;
	
	//取得当前操作的Annotation
	MKAnnotationView *annotationView = (MKAnnotationView *)((UIView*)sender).superview.superview;
	self.annotationManipulating = annotationView.annotation;
	
	AlarmNameViewController *nameViewCtl = [[AlarmNameViewController alloc] initWithNibName:@"AlarmNameViewController" bundle:nil];
	nameViewCtl.alarm = self.alarmTemp;
	nameViewCtl.parentController = self;
	[self.navigationController pushViewController:nameViewCtl animated:YES];
	[nameViewCtl release];
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
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
		case YCMapAnnotationTypeStandardEnabledDrag:
			pinView.draggable = YES;
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
			self.alarmTemp.coordinate = annotationView.annotation.coordinate;
			//反转坐标－地址
			((YCAnnotation*) annotationView.annotation).subtitle = @"";
			reverseGeocoder = [self reverseGeocoder:annotationView.annotation.coordinate]; 
			[reverseGeocoder start];
			//激活Done按钮
			self.navigationItem.rightBarButtonItem.enabled = YES;
			break;
		default:
			break;

	}

}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	self.currentLocationBarItem.style =  UIBarButtonItemStyleBordered;
	self.currentPinBarItem.style =  UIBarButtonItemStyleBordered;
}

/*
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	
	//设置当前位置bar按钮风格
	if (self->isCurrentLocationAtCenterRegion) 
	{
		self.currentLocationBarItem.style =  UIBarButtonItemStyleDone;
		self->isCurrentLocationAtCenterRegion = NO;
	}else {
		self.currentLocationBarItem.style =  UIBarButtonItemStyleBordered;
	}
	 
}
 */

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
	
	if (!self.alarmTemp.nameChanged) {
		if (title == nil) 
			title = kDefaultLocationAlarmName;
		self.alarmTemp.alarmName = title;
	}
	self.alarmTemp.position = position;
	
	self.annotationManipulating.title = self.alarmTemp.alarmName;
	self.annotationManipulating.subtitle = @"";
	[self performSelector:@selector(resetAnnotation:) withObject:self.alarmTemp.position afterDelay:0.5]; //延时生成，获得动画效果
	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	double lat = geocoder.coordinate.latitude;
	double lon = geocoder.coordinate.longitude;
	NSString *latstr = [UIUtility convertLatitude:lat decimal:0];
	NSString *lonstr = [UIUtility convertLongitude:lon decimal:0];
	NSString *position = [[[NSString alloc] initWithFormat:@"%@ %@",latstr,lonstr] autorelease];
	
	self.alarmTemp.position = position;
	
	self.annotationManipulating.title = self.alarmTemp.alarmName;
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

#pragma mark -
#pragma mark UISearchBarDelegate
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	NSLog(@"Searching for: %@", theSearchBar.text);
	/*
	if(forwardGeocoder == nil)
	{
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
	// Forward geocode!
	[forwardGeocoder findLocation:searchBar.text];
	 */
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
	[self cancelSearchButtonPressed:theSearchBar];
}



@end
