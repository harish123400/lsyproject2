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
@synthesize curlView;
@synthesize curlbackgroundView;
@synthesize activityIndicator;
@synthesize searchBar;
@synthesize toolBar;
@synthesize mapTypeSegmented;
@synthesize currentLocationBarItem;
@synthesize currentPinBarItem;
@synthesize searchBarItem;
@synthesize resetPinBarItem;
@synthesize pageCurlBarItem;

@synthesize forwardGeocoder;
@synthesize searchController;
@synthesize regionCenterWithCurrentLocation;
@synthesize alarms;
@synthesize newAlarm; 
@synthesize alarmTemp;
@synthesize mapAnnotations;
@synthesize annotationAlarmEditing;
@synthesize annotationManipulating;


- (MKReverseGeocoder *)reverseGeocoder:(CLLocationCoordinate2D)coordinate
{
    if (reverseGeocoder) {
		[reverseGeocoder release];
	}
	reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
	reverseGeocoder.delegate = self;
	
	return reverseGeocoder;
}

-(id)locationingBarItem
{
	if (self->locationingBarItem == nil) 
	{
		CGRect frame = CGRectMake(0, 0, 20, 20);
		UIActivityIndicatorView *progressInd = [[[UIActivityIndicatorView alloc] initWithFrame:frame] autorelease];
		self->locationingBarItem = [[UIBarButtonItem alloc] initWithCustomView:progressInd];
		[progressInd startAnimating];
	}
	
	return self->locationingBarItem;
}

#pragma mark - 
#pragma mark - UI元素操作

-(void)setToolBarItemsEnabled:(BOOL)enabled
{
	NSArray *baritems = self.toolBar.items ;
	for(NSUInteger i=0;i<baritems.count;i++)
	{
		[[baritems objectAtIndex:i] setEnabled:enabled];
	}
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
	if (lad > 180.0 || lad < 0.0) return NO;
	if (lod > 180.0 || lod < 0.0) return NO;
	
	return YES;
}

-(BOOL) isValidRegion:(MKCoordinateRegion)region
{	
	if(![self isValidCoordinate:region.center]) return NO;
	if(![self isValidSpan:region.span]) return NO;
	return YES;
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
		[UIView setAnimationDuration:1.0];
		self.maskView.alpha = 0.0f;
		[UIView commitAnimations];
	}else {
		[self.activityIndicator stopAnimating];
		self.maskView.alpha = 0.0f;
	}
	
}

- (void)zoomToWorld:(CLLocationCoordinate2D)world animated:(BOOL)animated
{   
	if (![self isValidCoordinate:world]) //无效返回
		return;
	
    MKCoordinateRegion current = mapView.region;
	if([self isValidRegion:current])
	{
		MKCoordinateRegion zoomOut = { { (current.center.latitude + world.latitude)/2.0 , (current.center.longitude + world.longitude)/2.0 }, {90, 90} };
		[self.mapView setRegion:zoomOut animated:animated];
	}else {
		MKCoordinateRegion zoomOut = { { world.latitude, world.longitude }, {90, 90} };
		[self.mapView setRegion:zoomOut animated:animated];
	}
}

- (void)zoomToPlace:(MKCoordinateRegion)place animated:(BOOL)animated
{
	if (![self isValidRegion:place]) //无效返回
		return;
	
    [self.mapView setRegion:place animated:animated];
}


- (void)animateToWorldWithObj:(id/*CLLocationCoordinate2D*/)obj
{   
	CLLocationCoordinate2D target;
	[obj getValue:&target];
	
	[self zoomToWorld:target animated:YES];
	
}

- (void)animateToPlaceWithObj:(id/*MKCoordinateRegion*/)obj
{
	MKCoordinateRegion target;
	[obj getValue:&target];
	
	[self zoomToPlace:target animated:YES];
}

////坐标转换 to world -> to Place
////返回值：延时
-(double)setMapRegion:(MKCoordinateRegion)region 
			FromWorld:(BOOL)fromWorld 
	  animatedToWorld:(BOOL)animatedToWorld 
	 animatedToPlace:(BOOL)animatedToPlace
{	
	double delay =0.0f;
	
	//先ZoomToWorld
	if (fromWorld) 
	{
		MKCoordinateRegion current = self.mapView.region;
		if (current.span.latitudeDelta < 10) 
		{
			if (animatedToWorld) 
			{   delay +=0.3;
				CLLocationCoordinate2D coordinate = region.center;
				NSValue *coordinateObj = [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
				[self performSelector:@selector(animateToWorldWithObj:) withObject:coordinateObj afterDelay:delay];
			}else {
				[self zoomToWorld:region.center animated:NO];
			}
		}else {
			[self zoomToWorld:region.center animated:NO];
		}

	}
	
	//ZoomTo目标
	if (animatedToPlace) 
	{
		if(delay > 0.1) delay +=1.4;
		NSValue *regionObj = [NSValue valueWithBytes:&region objCType:@encode(MKCoordinateRegion)];
		[self performSelector:@selector(animateToPlaceWithObj:) withObject:regionObj afterDelay:delay];
	}else {
		[self zoomToPlace:region animated:NO];
	}
	
	return delay;
}


//选中Annotation －显示标题
-(void)selectAnnotationAtIndex:(NSNumber*)index
{
	NSInteger nIndex = [index intValue];
	if(nIndex >=0 && nIndex < self.mapAnnotations.count)
		[self.mapView selectAnnotation:[self.mapAnnotations objectAtIndex:nIndex] animated:YES];
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
		
		if (self.regionCenterWithCurrentLocation) 
		{
			if([temp.alarmId isEqualToString:self.alarmTemp.alarmId])
			{
				annotation.annotationType = YCMapAnnotationTypeMovingToTarget;
			}else{
				annotation.annotationType = YCMapAnnotationTypeStandard;
			}
		}else {
			if(self.newAlarm)  //AlarmNew
			{
				annotation.title = KMapNewAnnotationTitle;
				annotation.subtitle = @"";
				annotation.annotationType = YCMapAnnotationTypeLocating;
			}else {
				annotation.annotationType = YCMapAnnotationTypeStandardEnabledDrag;
			}
		}

		
		
		if([temp.alarmId isEqualToString:self.alarmTemp.alarmId])
			self.annotationAlarmEditing = annotation;
		
		
		[array addObject:annotation];
		[annotation release];
	}
	
	if (self.annotationAlarmEditing == nil)  //在tab上点击打开的情况
	{
		self.annotationAlarmEditing =  [[YCAnnotation alloc]init];
		annotationAlarmEditing.annotationType = YCMapAnnotationTypeStandard;
	}
	
	self.mapAnnotations = array;
	[array release];
	
	
	[self.mapView addAnnotations:mapAnnotations];
	
}

////设置正在定位barItem处于定位状态
-(void)setLocationBarItem:(BOOL)locationing
{
	NSMutableArray *baritems = [NSMutableArray array];
	[baritems addObjectsFromArray:self.toolBar.items];
	
	if(locationing)
		[baritems replaceObjectAtIndex:0 withObject:self.locationingBarItem];
	else 
		[baritems replaceObjectAtIndex:0 withObject:self.currentLocationBarItem];

	[self.toolBar setItems:baritems animated:NO];
}

#pragma mark -
#pragma mark Location Notification 

#define kLocationedNotification           @"kLocationedNotification"
#define kTimeOutForLocationNotification   @"kTimeOutForLocationNotification"

- (void) handle_Locationed: (id) notification 
{
	[self setLocationBarItem:NO];
	[self setToolBarItemsEnabled:YES];
	
	if(self->isFirstShow)
	{
		self->isFirstShow = NO;
		//关掉覆盖视图
		[self closeMaskViewWithAnimated:YES];
		
		//先到世界地图，在下来
		[self setMapRegion:self->defaultMapRegion FromWorld:YES animatedToWorld:NO animatedToPlace:YES];
		
		//选中Annotation
		NSInteger index = [self.mapAnnotations indexOfObject:self.annotationAlarmEditing];
		[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:1.5];
		
	}else {
		[self setMapRegion:self->defaultMapRegion FromWorld:NO animatedToWorld:NO animatedToPlace:YES];
	}
	
}


- (void) handle_TimeOutForLocation: (id) notification 
{
	[self setLocationBarItem:NO];
	[self setToolBarItemsEnabled:YES];
	
	 if(self->isFirstShow)
	 {
		 self->isFirstShow = NO;
		 //关掉覆盖视图
		 [self closeMaskViewWithAnimated:YES];
		 
		 MKCoordinateRegion last = [YCParam paramSingleInstance].lastLoadMapRegion;
		 if ([self isValidRegion:last]) 
		 {
			 self->defaultMapRegion = last;//加载上一次的正确的区域
			[self setMapRegion:self->defaultMapRegion FromWorld:NO animatedToWorld:NO animatedToPlace:YES];
		 }//如果没有最后一次正确的加载，那么听天由命吧，估计是显示一个世界地图
		 
	 }
	 
}
 

-(void)checkLocation
{
	static double timePassed = 0.0;
	if (self.mapView.userLocation.location)
	{
		[myTimer invalidate];
		[myTimer release];
		myTimer = nil;
		
		self->defaultMapRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate,1500.0,1500.0);
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:kLocationedNotification object:self];
	}else {
		//Time out 
		timePassed +=0.5;
		if (timePassed > 10.0)  //10秒time out
		{
			timePassed = 0;
			
			[myTimer invalidate];
			[myTimer release];
			myTimer = nil;
			
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter postNotificationName:kTimeOutForLocationNotification object:self];

		}
	}
	
}

-(void)startCheckLocationTimer
{
	NSTimeInterval ti = 0.2;
	myTimer = [[NSTimer timerWithTimeInterval:ti target:self selector:@selector(checkLocation) userInfo:nil repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
}



#pragma mark -
#pragma mark Event

-(void)setDoneStyleToBarButtonItem:(UIBarButtonItem*)buttonItem
{
	buttonItem.style =  UIBarButtonItemStyleDone;
}

-(IBAction)doneButtonPressed:(id)sender
{	
	//覆盖父类
	self.alarm.coordinate = self.alarmTemp.coordinate;
	self.alarm.alarmName = self.alarmTemp.alarmName;
	self.alarm.position = self.alarmTemp.position;
	self.alarm.nameChanged = self.alarmTemp.nameChanged;
	[self.parentController reflashView];
	[self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)currentLocationButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页

	[self setLocationBarItem:YES];
	[self setToolBarItemsEnabled:NO];
	[self startCheckLocationTimer];
}
-(IBAction)currentPinButtonPressed:(id)sender
{	
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if(self.mapAnnotations.count ==0) return;
	
	//轮转
	NSUInteger annotationIndex = [self.mapAnnotations indexOfObject:self.annotationAlarmEditing];
	annotationIndex++;
	if (annotationIndex >= self.mapAnnotations.count)
		annotationIndex = 0;
	self.annotationAlarmEditing = [self.mapAnnotations objectAtIndex:annotationIndex];
	
	if ([self isValidCoordinate:self.annotationAlarmEditing.coordinate])
	{
		//仅仅设置中心
		[self.mapView setCenterCoordinate:self.annotationAlarmEditing.coordinate animated:YES];
		//选中
		[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:annotationIndex] afterDelay:0.2];

	}
}

-(IBAction)resetPinButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	[self.mapView removeAnnotation:self.annotationAlarmEditing];
	self.annotationAlarmEditing.coordinate = self.mapView.region.center;
	[self.mapView addAnnotation:self.annotationAlarmEditing];
	//反转坐标－地址
	self.annotationManipulating = self.annotationAlarmEditing;
	((YCAnnotation*) self.annotationAlarmEditing).subtitle = @"";
	reverseGeocoder = [self reverseGeocoder:self.annotationAlarmEditing.coordinate]; 
	[reverseGeocoder start];
	//[reverseGeocoder performSelector:@selector(start) withObject:nil afterDelay:0.2];
}


-(IBAction)searchButtonPressed:(id)sender
{

	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	[self.searchController setActive:YES animated:YES];   //处理search状态

}

-(IBAction)pageCurlButtonPressed:(id)sender
{
	
	//创建CATransition对象
	CATransition *animation = [CATransition animation];
	//相关参数设置
	[animation setDelegate:self];
	[animation setDuration:0.4f];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	//向上卷的参数
	if(!isCurl)
	{
		//设置动画类型为pageCurl，并只卷一半
		[animation setType:@"pageCurl"];
		animation.endProgress=0.70;
		
		self.pageCurlBarItem.style = UIBarButtonItemStyleDone;
	}
	//向下卷的参数
	else
	{
		//设置动画类型为pageUnCurl，并从一半开始向下卷
		[animation setType:@"pageUnCurl"];
		animation.startProgress=0.30;
		
		self.pageCurlBarItem.style = UIBarButtonItemStyleBordered;
	}
	//卷的过程完成后停止，并且不从层中移除动画
	//[animation setFillMode: @"extended"];
	[animation setFillMode:kCAFillModeForwards];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setRemovedOnCompletion:NO];
	
	[self.curlbackgroundView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
	[[self.curlbackgroundView layer] addAnimation:animation forKey:@"pageCurlAnimation"];

	isCurl=!isCurl;

}

-(IBAction)mapTypeSegmentedChanged:(id)sender;
{
	switch ([sender selectedSegmentIndex]) 
	{
		case 0:
			self.mapView.mapType = MKMapTypeStandard;
			break;
		case 1:
			self.mapView.mapType = MKMapTypeSatellite;
			break;
		case 2:
			self.mapView.mapType = MKMapTypeHybrid;
			break;
		default:
			break;
	}
    [self pageCurlButtonPressed:nil];
}


#pragma mark -
#pragma mark View lifecycle

- (void) registerNotifications 
{
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self
						   selector: @selector (handle_Locationed:)
							   name: kLocationedNotification
							 object: nil];
	[notificationCenter addObserver: self
						   selector: @selector (handle_TimeOutForLocation:)
							   name: kTimeOutForLocationNotification
							 object: nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	mapView.delegate = self;
	self->isFirstShow = YES;
	self.navigationItem.rightBarButtonItem.enabled = NO;//Done按钮
	
	//Map type segmented
	[self.mapTypeSegmented setTitle:kMapTypeNameStandard forSegmentAtIndex:0];
	[self.mapTypeSegmented setTitle:KMapTypeNameSatellite forSegmentAtIndex:1];
	[self.mapTypeSegmented setTitle:KMapTypeNameHybrid forSegmentAtIndex:2];
	
	//search bar,toolbar
	if (!regionCenterWithCurrentLocation) 
	{
		self.searchBar.hidden = YES;
		self.toolBar.hidden = NO;
	} else { //在tab上的地图，一直有searchbar
		self.searchBar.hidden = NO;
		self.toolBar.hidden = NO;
		self.toolBar.alpha = 0.75f;
		self.resetPinBarItem.customView.hidden = YES;
	}
	[self setToolBarItemsEnabled:NO];
	
	self.searchController = [[YCSearchController alloc] initWithDelegate:self
												 searchDisplayController:self.searchDisplayController];
	

	
	//判断闹钟坐标是否有效
	if (![self isValidCoordinate:self.alarm.coordinate]) 
		self.alarm.coordinate = [YCParam paramSingleInstance].lastLoadMapRegion.center;
	
	self.alarmTemp = [self.alarm copy];
	
	//注册消息
	[self registerNotifications];

	[self showMaskView];
	[self addAnnotation];
	//[self performSelector:@selector(showMapView) withObject:nil afterDelay:0.5];

	
	if (self.regionCenterWithCurrentLocation) 
	{
		[self startCheckLocationTimer];
	}else {
		
		if ([self isValidCoordinate:self.alarmTemp.coordinate]) 
		{
			self->defaultMapRegion = MKCoordinateRegionMakeWithDistance(self.alarmTemp.coordinate,1500.0,1500.0);
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter postNotificationName:kLocationedNotification object:self];
		}else { //alarmTemp中的坐标无效，按当前位置显示
			[self startCheckLocationTimer];
		}

	}

}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.title = NSLocalizedString(@"位置",@"视图标题");
	//[self performSelector:@selector(setDoneStyleToBarButtonItem:) withObject:self.currentPinBarItem afterDelay:0.5];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	//保存最后加载的区域
	[YCParam paramSingleInstance].lastLoadMapRegion = self.mapView.region;
}


#pragma mark - 
#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	self.annotationManipulating = userLocation;
	reverseGeocoder = [self reverseGeocoder:userLocation.coordinate]; 
	[reverseGeocoder start];
	
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	for (NSUInteger i=0; i<views.count; i++) 
	{
		MKAnnotationView *annotationView = [views objectAtIndex:i];
		
		//当前位置
		if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) 
		{
			UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			annotationView.leftCalloutAccessoryView = sfIconView;
			[sfIconView release];
		}
		
		
		if ([annotationView isKindOfClass:[MKPinAnnotationView class]]) 
		{
			YCAnnotation *annotation = annotationView.annotation;
			//if (annotation.annotationType == YCMapAnnotationTypeLocating) //注意:如果有多个图钉iew,能不能都选中能？
			//选中
			NSInteger index = [self.mapAnnotations indexOfObject:annotation];
			[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:0.5];

		}
	}

}



- (void)showDetails:(id)sender
{
	//back按钮
	self.title = nil;
	
	//取得当前操作的Annotation
	MKAnnotationView *annotationView = (MKAnnotationView *)((UIView*)sender).superview.superview;
	self.annotationAlarmEditing = annotationView.annotation;
	
	AlarmNameViewController *nameViewCtl = [[AlarmNameViewController alloc] initWithNibName:@"AlarmNameViewController" bundle:nil];
	nameViewCtl.alarm = self.alarmTemp;
	nameViewCtl.parentController = self;
	[self.navigationController pushViewController:nameViewCtl animated:YES];
	[nameViewCtl release];
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]])
	{
		return nil;
	}
	
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
			pinView.draggable = NO;
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeStandardEnabledDrag:
			pinView.draggable = YES;
			pinView.pinColor = MKPinAnnotationColorPurple;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeLocating:
			pinView.draggable = YES;
			pinView.pinColor = MKPinAnnotationColorPurple;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeMovingToTarget:
			pinView.pinColor = MKPinAnnotationColorGreen;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		default:
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
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
			((YCAnnotation *)annotationView.annotation).annotationType = YCMapAnnotationTypeLocating;
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
	//self.currentLocationBarItem.style =  UIBarButtonItemStyleBordered;
	//self.currentPinBarItem.style =  UIBarButtonItemStyleBordered;
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate


-(void) setAnnotationAlarmEditingWithCoordinate:(CLLocationCoordinate2D)coordinate 
										  title:(NSString*)title subtitle:(NSString*)subtitle
									   animated:(BOOL)animated;
{
	if (!self.alarmTemp.nameChanged) {
		if (title == nil || [title length] == 0) 
			title = kDefaultLocationAlarmName;
		self.alarmTemp.alarmName = title;
	}
	self.alarmTemp.coordinate = coordinate;
	self.alarmTemp.position = subtitle;
	
	self.annotationAlarmEditing.coordinate = self.alarmTemp.coordinate;
	self.annotationAlarmEditing.title = self.alarmTemp.alarmName;
	
	if (animated)
	{
		self.annotationAlarmEditing.subtitle = @"";
		[self.annotationAlarmEditing performSelector:@selector(setSubtitle:) withObject:self.alarmTemp.position afterDelay:0.5];//延时生成，获得动画效果
	}
	else 
		self.annotationAlarmEditing.subtitle = self.alarmTemp.position;
	
	//激活Done按钮
	self.navigationItem.rightBarButtonItem.enabled = YES;
		
	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{   
	NSString *title = [UIUtility titleStringFromPlacemark:placemark];
	NSString *subtitle = [UIUtility positionStringFromPlacemark:placemark];
	CLLocationCoordinate2D coordinate = placemark.coordinate;
	
	if (self.annotationManipulating != self.annotationAlarmEditing)
	{
		if ([self.annotationManipulating isKindOfClass:[MKUserLocation class]])
		{
			//((MKUserLocation*)self.annotationManipulating).title = title;          
			((MKUserLocation*)self.annotationManipulating).subtitle = subtitle;
			self.annotationManipulating.coordinate = coordinate;
		}
	}
	else 
		[self setAnnotationAlarmEditingWithCoordinate:coordinate title:title subtitle:subtitle animated:YES];
	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	double lat = geocoder.coordinate.latitude;
	double lon = geocoder.coordinate.longitude;
	NSString *latstr = [UIUtility convertLatitude:lat decimal:0];
	NSString *lonstr = [UIUtility convertLongitude:lon decimal:0];
	
	NSString *title = nil;
	NSString *subtitle = [[[NSString alloc] initWithFormat:@"%@ %@",latstr,lonstr] autorelease];
	CLLocationCoordinate2D coordinate = geocoder.coordinate;
	
	if (self.annotationManipulating != self.annotationAlarmEditing)
	{
		if ([self.annotationManipulating isKindOfClass:[MKUserLocation class]])
		{
			//((MKUserLocation*)self.annotationManipulating).title = title;          
			((MKUserLocation*)self.annotationManipulating).subtitle = subtitle;
			self.annotationManipulating.coordinate = coordinate;
		}
	}
	else 
		[self setAnnotationAlarmEditingWithCoordinate:coordinate title:title subtitle:subtitle animated:YES];
	
}

#pragma mark -
#pragma mark YCNavSuperControllerProtocol
-(void)reflashView
{
	self.annotationAlarmEditing.title = self.alarmTemp.alarmName;
	//激活Done按钮
	self.navigationItem.rightBarButtonItem.enabled = YES;
}


#pragma mark -
#pragma mark BSForwardGeocoderDelegate

-(void)forwardGeocoderFoundLocation
{
	
	NSUInteger searchResults = [forwardGeocoder.results count];
	
	if(forwardGeocoder.status == G_GEO_SUCCESS && searchResults > 0)
	{
		//加到最近查询list中
		[self.searchController addListContentWithString:forwardGeocoder.searchQuery];
		
		//离当前位置最近的元素
		CLLocationDistance distanceOfNearest = 900000000000.0;
		NSUInteger indexOfNearest =0;
		
		for(NSUInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *placeTmp = [forwardGeocoder.results objectAtIndex:i];
			
			//找出个离当前位置最近的
			CLLocation *currentLocation = self.mapView.userLocation.location;
			if (currentLocation) 
			{
				CLLocation *locTmp = [[CLLocation alloc] initWithLatitude:placeTmp.coordinate.latitude longitude:placeTmp.coordinate.longitude];
				CLLocationDistance distanceTmp = [currentLocation distanceFromLocation:locTmp];
				if (distanceTmp  < distanceOfNearest) 
				{
					distanceOfNearest = distanceTmp;
					indexOfNearest = i;
				}
			}
			
		}
		

		BSKmlResult *place = [forwardGeocoder.results objectAtIndex:indexOfNearest];  /////用最近的
	
		
		//先删除原来的annotation
		if (self.annotationAlarmEditing)
			[self.mapView removeAnnotation:self.annotationAlarmEditing];
		
		//改变annotation内容
		NSString *title = forwardGeocoder.searchQuery;
		NSString *subtitle = place.address!=nil ? place.address: @" " ;
		[self setAnnotationAlarmEditingWithCoordinate:place.coordinate title:title subtitle:subtitle animated:NO];
		
		////////////////////////
		//Zoom into the location
		self->defaultMapRegion = place.coordinateRegion;
		self->defaultMapRegion.center = place.coordinate;
		double delay = [self setMapRegion:self->defaultMapRegion FromWorld:YES animatedToWorld:YES animatedToPlace:YES];
		//Zoom into the location
		////////////////////////
		
			
		//再加上
		//[self.mapView addAnnotation:self.annotationAlarmEditing];
		[self.mapView performSelector:@selector(addAnnotation:) withObject:self.annotationAlarmEditing afterDelay:delay+0.1];
			

	}else {
		
		switch (forwardGeocoder.status) {
			case G_GEO_BAD_KEY:
				[UIUtility simpleAlertBody:kAlertMsgErrorWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
			case G_GEO_UNKNOWN_ADDRESS:
				[UIUtility simpleAlertBody:kAlertMsgNoResultsWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
			case G_GEO_TOO_MANY_QUERIES:
				[UIUtility simpleAlertBody:kAlertMsgTooManyQueriesWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
			case G_GEO_SERVER_ERROR:
				[UIUtility simpleAlertBody:kAlertMsgErrorWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
				
			default:
				break;
		}
		
	}
}


-(void)forwardGeocoderError:(NSString *)errorMessage
{
	
	[UIUtility simpleAlertBody:kAlertMsgErrorWhenSearchMap 
					alertTitle:kAlertTitleWhenSearchMap 
			 cancelButtonTitle:kAlertBtnOK 
					  delegate:self];
}
 

/*
-(void)forwardGeocoder:(BSForwardGeocoder*)theForwardGeocoder searchString:(NSString*)searchString results:(NSArray*)results
{
	NSUInteger searchResults = [results count];
	
	if(theForwardGeocoder.status == G_GEO_SUCCESS && searchResults > 0)
	{
		//加到最近查询list中
		[self.searchController addListContentWithString:searchString];
		
		//离当前位置最近的元素
		CLLocationDistance distanceOfNearest = 900000000000.0;
		NSUInteger indexOfNearest =0;
		
		for(NSUInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *placeTmp = [results objectAtIndex:i];
			
			//找出个离当前位置最近的
			CLLocation *currentLocation = self.mapView.userLocation.location;
			if (currentLocation) 
			{
				CLLocation *locTmp = [[CLLocation alloc] initWithLatitude:placeTmp.coordinate.latitude longitude:placeTmp.coordinate.longitude];
				CLLocationDistance distanceTmp = [currentLocation distanceFromLocation:locTmp];
				if (distanceTmp  < distanceOfNearest) 
				{
					distanceOfNearest = distanceTmp;
					indexOfNearest = i;
				}
			}
			
		}
		
		
		BSKmlResult *place = [results objectAtIndex:indexOfNearest];  /////用最近的
		
		
		//先删除原来的annotation
		if (self.annotationAlarmEditing)
			[self.mapView removeAnnotation:self.annotationAlarmEditing];
		
		//改变annotation内容
		NSString *title = searchString;
		NSString *subtitle = place.address!=nil ? place.address: @" " ;
		[self setAnnotationAlarmEditingWithCoordinate:place.coordinate title:title subtitle:subtitle animated:NO];
		
		////////////////////////
		//Zoom into the location
		self->defaultMapRegion = place.coordinateRegion;
		self->defaultMapRegion.center = place.coordinate;
		double delay = [self setMapRegion:self->defaultMapRegion FromWorld:YES animatedToWorld:YES animatedToPlace:YES];
		//Zoom into the location
		////////////////////////
		
		
		//再加上
		//[self.mapView addAnnotation:self.annotationAlarmEditing];
		[self.mapView performSelector:@selector(addAnnotation:) withObject:self.annotationAlarmEditing afterDelay:delay+0.1];
		
		
	}else {
		
		switch (theForwardGeocoder.status) {
			case G_GEO_BAD_KEY:
				[UIUtility simpleAlertBody:kAlertMsgErrorWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
			case G_GEO_UNKNOWN_ADDRESS:
				[UIUtility simpleAlertBody:kAlertMsgNoResultsWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
			case G_GEO_TOO_MANY_QUERIES:
				[UIUtility simpleAlertBody:kAlertMsgTooManyQueriesWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
			case G_GEO_SERVER_ERROR:
				[UIUtility simpleAlertBody:kAlertMsgErrorWhenSearchMap 
								alertTitle:kAlertTitleWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:self];
				break;
				
				
			default:
				break;
		}
		
	}
}


-(void)forwardGeocoder:(BSForwardGeocoder*)forwardGeocoder error:(NSString *)error
{
	
	[UIUtility simpleAlertBody:kAlertMsgErrorWhenSearchMap 
					alertTitle:kAlertTitleWhenSearchMap 
			 cancelButtonTitle:kAlertBtnOK 
					  delegate:self];
}
 */

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.searchController setActive:YES animated:YES];   //处理search状态
}

/*
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
}
 */

#pragma mark -
#pragma mark YCSearchControllerDelegete methods

- (NSArray*)searchController:(YCSearchController *)controller searchString:(NSString *)searchString
{
	
	if(forwardGeocoder == nil)
	{
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
	// Forward geocode!
	[forwardGeocoder findLocation:searchString];
	
	return nil;
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.mapView = nil;            
	self.maskView = nil;                           
	self.curlView;                           
	self.curlbackgroundView = nil;                    
	self.activityIndicator = nil;         
	self.searchBar = nil;
	self.toolBar = nil;
	self.mapTypeSegmented = nil;          
	self.currentLocationBarItem = nil;       
	self.currentPinBarItem = nil;            
	self.searchBarItem = nil;                
	self.resetPinBarItem = nil;              
	self.pageCurlBarItem = nil;

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:kLocationedNotification object:nil];
	[notificationCenter removeObserver:self name:kTimeOutForLocationNotification object:nil];

}


- (void)dealloc 
{
	[self->myTimer release];
	[self->reverseGeocoder release];
	[self.forwardGeocoder release];
	[self.searchController release];
	[self.alarms release];                       
	[self.mapAnnotations release];        
	[self.alarmTemp release];
	[self.annotationAlarmEditing release];
	[self.locationingBarItem release];
	
	[super dealloc];
}




@end
