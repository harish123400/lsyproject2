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

- (void)zoomToWorld:(CLLocationCoordinate2D)target animated:(BOOL)animated
{   
    MKCoordinateRegion current = mapView.region;
    MKCoordinateRegion zoomOut = { { (current.center.latitude + target.latitude)/2.0 , (current.center.longitude + target.longitude)/2.0 }, {90, 90} };
    [self.mapView setRegion:zoomOut animated:animated];
}


- (void)animateToWorldWithObj:(id/*CLLocationCoordinate2D*/)targetObj
{   
	CLLocationCoordinate2D target;
	[targetObj getValue:&target];
	
    /*
	MKCoordinateRegion current = mapView.region;
    MKCoordinateRegion zoomOut = { { (current.center.latitude + target.latitude)/2.0 , (current.center.longitude + target.longitude)/2.0 }, {90, 90} };
    [self.mapView setRegion:zoomOut animated:YES];
	 */
	[self zoomToWorld:target animated:YES];
	
}

- (void)animateToPlaceWithObj:(id/*MKCoordinateRegion*/)targetObj
{
	MKCoordinateRegion target;
	[targetObj getValue:&target];
    [self.mapView setRegion:target animated:YES];
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

-(BOOL) isValidRegion:(MKCoordinateRegion)region
{	
	if(![self isValidCoordinate:region.center]) return NO;
	if(![self isValidSpan:region.span]) return NO;
	return YES;
}




//选中Annotation －显示标题
-(void)selectAnnotationAtIndex:(NSNumber*)index
{
	NSInteger nIndex = [index intValue];
	if(nIndex >=0 && nIndex < self.mapAnnotations.count)
		[self.mapView selectAnnotation:[self.mapAnnotations objectAtIndex:nIndex] animated:YES];
}

-(BOOL)setMapRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{	
	[self zoomToWorld:region.center animated:animated]; //先世界地图
	[self.mapView setRegion:region animated:YES];
	return YES;
}

/*
//显示地图
-(void)showMapView
{
	//关掉覆盖视图
	[self closeMaskViewWithAnimated:YES];
	
	//第一次显示，按默认比例显示到当前位置
	if ([self isValidRegion:self->defaultMapRegion]) //对区域数据进行校验
	{
		[self setMapRegion:self->defaultMapRegion animated:NO];
	}else {
		//加载上一次的正确的区域
		[self setMapRegion:[YCParam paramSingleInstance].lastLoadMapRegion animated:NO];
	}

	
	NSInteger index = [self.mapAnnotations indexOfObject:self.annotationAlarmEditing];
	[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:1.5];
	
	//显示完成后，把maskview的触摸事件绑定
	[self.maskView addTarget:self action:@selector(hideSearchBar:) forControlEvents:UIControlEventTouchDown];
}
 */


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
			self.annotationAlarmEditing = annotation;
		
		
		[array addObject:annotation];
		[annotation release];
	}
	self.mapAnnotations = array;
	[array release];
	
	
	[self.mapView addAnnotations:mapAnnotations];
	
}

////设置正在定位barItem处于定位状态
-(void)setLocationBarItem:(BOOL)locationing
{
	NSMutableArray *baritems = [NSMutableArray array] ;
	[baritems addObjectsFromArray:self.toolBar.items];
	
	if(locationing)
		[baritems replaceObjectAtIndex:0 withObject:self.locationingBarItem];
	else 
		[baritems replaceObjectAtIndex:0 withObject:self.currentLocationBarItem];
	
	[self.toolBar setItems:baritems animated:YES];
}

#pragma mark -
#pragma mark Location Notification 

#define kLocationedNotification           @"kLocationedNotification"
#define kTimeOutForLocationNotification   @"kTimeOutForLocationNotification"

- (void) handle_Locationed: (id) notification 
{
	if(isFirstShow)
	{
		isFirstShow = NO;
		//关掉覆盖视图
		[self closeMaskViewWithAnimated:YES];
		
		//先到世界地图，在下来
		[self setMapRegion:self->defaultMapRegion animated:NO];
		
		//选中Annotation
		NSInteger index = [self.mapAnnotations indexOfObject:self.annotationAlarmEditing];
		[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:index] afterDelay:1.5];
		
		//显示完成后，把maskview的触摸事件绑定
		[self.maskView addTarget:self action:@selector(searchBarCancelButtonPressed:) forControlEvents:UIControlEventTouchDown];
	}else {
		[self.mapView setRegion:self->defaultMapRegion animated:YES];
	}
	
	[self setLocationBarItem:NO];
}


- (void) handle_TimeOutForLocation: (id) notification 
{
	 [self setLocationBarItem:NO];
	 if(isFirstShow)
	 {
		 isFirstShow = NO;
		 //关掉覆盖视图
		 [self closeMaskViewWithAnimated:YES];
		 
		 //显示完成后，把maskview的触摸事件绑定
		 [self.maskView addTarget:self action:@selector(searchBarCancelButtonPressed:) forControlEvents:UIControlEventTouchDown];

		 
		 MKCoordinateRegion last = [YCParam paramSingleInstance].lastLoadMapRegion;
		 if ([self isValidRegion:last]) 
		 {
			 self->defaultMapRegion = last;//加载上一次的正确的区域
			[self.mapView setRegion:self->defaultMapRegion animated:YES];
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
	NSTimeInterval ti = 0.5;
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
	
	/*
	if (self.mapView.userLocation.location)
	{
		self->isCurrentLocationAtCenterRegion = YES;
		//设置屏幕中心，与范围
		CLLocationCoordinate2D coordOfCurrent = self.mapView.userLocation.location.coordinate;
		self->defaultMapRegion.center = coordOfCurrent;
		[self.mapView setRegion:self->defaultMapRegion animated:YES];
		//[self performSelector:@selector(setDoneStyleToBarButtonItem:) withObject:self.currentLocationBarItem afterDelay:0.2];
	}
	 */
	[self setLocationBarItem:YES];
	[self startCheckLocationTimer];
}
-(IBAction)currentPinButtonPressed:(id)sender
{	
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if ([self isValidCoordinate:self.annotationAlarmEditing.coordinate])
	{
		//仅仅设置中心
		[self.mapView setCenterCoordinate:self.annotationAlarmEditing.coordinate animated:YES];
		//[self performSelector:@selector(setDoneStyleToBarButtonItem:) withObject:self.currentPinBarItem afterDelay:0.2];
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
}

-(void)ativeOrResignSearchBar
{
	
	if (self.searchBar.isFirstResponder ) 
	{
		[UIView beginAnimations:@"resigSsearchBar" context:NULL];
		[UIView setAnimationDuration:0.75];
		self.maskView.alpha = 0.0f;
		[UIView commitAnimations];
		[self.searchBar resignFirstResponder];  //search bar放弃键盘
	}else {
		self.maskView.backgroundColor = [UIColor blackColor];
		[UIView beginAnimations:@"ativeSearchBar" context:NULL];
		[UIView setAnimationDuration:0.75];
		self.maskView.alpha = 0.8f;
		[UIView commitAnimations];
		[self.searchBar becomeFirstResponder];  //search bar调用键盘
	}
	
}

-(void)showOrHideSearchBar
{
		
	CATransition *animation = [CATransition animation];  
    [animation setDelegate:self];  
    [animation setDuration:0.5f];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; 
    [animation setType:kCATransitionPush];
	[animation setFillMode:kCAFillModeForwards];
	[animation setRemovedOnCompletion:YES]; 
	NSString *subtype = self.searchBar.hidden ? kCATransitionFromBottom:kCATransitionFromTop;
    [animation setSubtype:subtype];
	
	self.searchBar.hidden = !self.searchBar.hidden;  
    [[self.searchBar layer] addAnimation:animation forKey:@"showOrHideSearchBar"];


}

////改变搜索时候的状态，searchbar，maskview，FirstResponder。
-(void)changeSearchStatus
{
	if (!regionCenterWithCurrentLocation) 
	{
		[self showOrHideSearchBar];
	} //在tab上的地图，一直有searchbar
	
	[self ativeOrResignSearchBar];
}

-(IBAction)searchButtonPressed:(id)sender
{

	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	[self changeSearchStatus];

}

-(IBAction)searchBarCancelButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	[self changeSearchStatus];
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
	self.searchBar.delegate = self;
	if (!regionCenterWithCurrentLocation) 
	{
		self.searchBar.hidden = YES;
		self.toolBar.hidden = NO;
	} else { //在tab上的地图，一直有searchbar
		self.searchBar.hidden = NO;
		self.toolBar.hidden = NO;
		self.toolBar.alpha = 0.60f;
	}
	
	

	
	//判断闹钟坐标是否有效
	if (![self isValidCoordinate:self.alarm.coordinate]) 
		self.alarm.coordinate = [YCParam paramSingleInstance].lastLoadMapRegion.center;
	
	self.alarmTemp = [self.alarm copy];
	
	//注册消息
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self
						   selector: @selector (handle_Locationed:)
							   name: kLocationedNotification
							 object: nil];
	[notificationCenter addObserver: self
						   selector: @selector (handle_TimeOutForLocation:)
							   name: kTimeOutForLocationNotification
							 object: nil];

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
	/*
	static NSString* curViewAnnotationIdentifier = @"curViewAnnotationIdentifier";
	if ([annotation isKindOfClass:[MKUserLocation class]])
	{
		NSLog(@"cur title = %@",annotation.title);
		NSLog(@"cur subtitle = %@",annotation.subtitle);
		annotation.subtitle = @"this is Current Location";
		MKAnnotationView *curView = [mapView dequeueReusableAnnotationViewWithIdentifier:curViewAnnotationIdentifier];
        if (!curView) 
		{
			curView = [[[MKAnnotationView alloc] 
						initWithAnnotation:annotation reuseIdentifier:curViewAnnotationIdentifier] autorelease];
			curView.draggable = NO;
		}
		//return curView;
		return nil;
	}
	 */
	
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
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeStandardEnabledDrag:
			pinView.draggable = YES;
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeLocating:
			pinView.draggable = YES;
			pinView.pinColor = MKPinAnnotationColorPurple;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeMovingTarget:
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
#pragma mark UISearchBarDelegate
- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar 
{

	[self changeSearchStatus];   //处理search状态
	
	
	if(forwardGeocoder == nil)
	{
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
	// Forward geocode!
	[forwardGeocoder findLocation:searchBar.text];
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar
{
	[self searchBarCancelButtonPressed:theSearchBar];
}

#pragma mark -
#pragma mark BSForwardGeocoderDelegate

-(void)forwardGeocoderFoundLocation
{
	
	NSUInteger searchResults = [forwardGeocoder.results count];
	
	if(forwardGeocoder.status == G_GEO_SUCCESS && searchResults > 0)
	{
		
		//离当前位置最近的元素
		CLLocationDistance distanceOfNearest = 900000000000.0;
		NSUInteger indexOfNearest =0;
		
		for(NSUInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *placeTmp = [forwardGeocoder.results objectAtIndex:i];
			//NSLog(@"address=%@",placeTmp.address);
			
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
		[self.mapView removeAnnotation:self.annotationAlarmEditing];
		
		//改变annotation内容
		NSString *title = self.searchBar.text;
		NSString *subtitle = place.address!=nil ? place.address: @" " ;
		[self setAnnotationAlarmEditingWithCoordinate:place.coordinate title:title subtitle:subtitle animated:NO];
		
		////////////////////////
		//Zoom into the location
		////简单类型->装箱
		CLLocationCoordinate2D coordinate = place.coordinate;
		NSValue *coordinateObj = [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
		MKCoordinateRegion region = place.coordinateRegion;
		NSValue *regionObj = [NSValue valueWithBytes:&region objCType:@encode(MKCoordinateRegion)];
		
		double delay =0;
		MKCoordinateRegion current = self.mapView.region;
		if (current.span.latitudeDelta < 10)
		{
			[self performSelector:@selector(animateToWorldWithObj:) withObject:coordinateObj afterDelay:0.3];
			[self performSelector:@selector(animateToPlaceWithObj:) withObject:regionObj afterDelay:1.7];
			delay = 1.7;
		}
		else
		{
			[self performSelector:@selector(animateToPlaceWithObj:) withObject:regionObj afterDelay:0.3];
			delay = 0.4;
		}
		//Zoom into the location
		////////////////////////
		
			
		//再加上
		//[self.mapView addAnnotation:self.annotationAlarmEditing];
		[self.mapView performSelector:@selector(addAnnotation:) withObject:self.annotationAlarmEditing afterDelay:delay];
			

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

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self changeSearchStatus];   //处理search状态
}

/*
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//[self changeSearchStatus];   //处理search状态
}
 */


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
	self.mapTypeSegmented = nil;          
	self.currentLocationBarItem = nil;       
	self.currentPinBarItem = nil;            
	self.searchBarItem = nil;                
	self.resetPinBarItem = nil;              
	self.pageCurlBarItem = nil;              

}


- (void)dealloc {
    [super dealloc];
	[self->myTimer release];
	[self->reverseGeocoder release];
	[self.forwardGeocoder release];
	[self.alarms release];                       
	[self.mapAnnotations release];        
	[self.alarmTemp release];
	[self.annotationAlarmEditing release];
	[self.locationingBarItem release];
}




@end
