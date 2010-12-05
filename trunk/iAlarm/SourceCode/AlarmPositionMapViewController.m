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
#import "YCTapView.h"
#import "MapBookmarksListController.h"


@implementation AlarmPositionMapViewController


#pragma mark -
#pragma mark 属性

@synthesize mapView;
@synthesize maskView;
@synthesize curlView;
@synthesize curlbackgroundView;
@synthesize curlImageView;
@synthesize activityIndicator;
@synthesize searchBar;
@synthesize toolbar;
@synthesize mapTypeSegmented;
@synthesize currentLocationBarItem;
@synthesize currentPinBarItem;
@synthesize searchBarItem;
@synthesize resetPinBarItem;
@synthesize pageCurlBarItem;
@synthesize previousBarItem;              
@synthesize nextBarItem;  

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

-(id) locationingBarItem
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

-(id) annotationSearched
{
	if (self->annotationSearched == nil) 
	{
		self->annotationSearched = [[YCAnnotation alloc] init];
		self->annotationSearched.annotationType = YCMapAnnotationTypeSearch;
	}
	return self->annotationSearched;
}


-(void)updateMapAnnotations
{
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
			annotation.title = temp.alarmName;
			annotation.subtitle = @"";
		}else {
			if(self.newAlarm)  //AlarmNew
			{
				annotation.annotationType = YCMapAnnotationTypeLocating;
			}else {
				annotation.annotationType = YCMapAnnotationTypeStandardEnabledDrag;
			}
			annotation.title = KMapNewAnnotationTitle;
			annotation.subtitle = @"";
		}
		
		
		
		if([temp.alarmId isEqualToString:self.alarmTemp.alarmId])
			self.annotationAlarmEditing = annotation;
		
		
		[array addObject:annotation];
		[annotation release];
	}
	
	//if(self.mapAnnotations && [self.mapAnnotations indexOfObject:self.annotationSearched] != NSNotFound)
	//	[array addObject:self.annotationSearched];
	
	self.mapAnnotations = array;

}

- (MapBookmarksListController *)mapBookmarksListController
{
    if (mapBookmarksListController == nil)
    {
        mapBookmarksListController = [[MapBookmarksListController alloc] initWithStyle:UITableViewStylePlain];
        mapBookmarksListController.delegate = self;
        //mapBookmarksListController.title = @"Choose a bookmark:";
    }
    return mapBookmarksListController;
}

- (UINavigationController *)mapBookmarksListNavigationController
{
    if (mapBookmarksListNavigationController == nil)
    {
        mapBookmarksListNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mapBookmarksListController];
    }
    return mapBookmarksListNavigationController;
}

#pragma mark - 
#pragma mark - UI元素操作

//根据Annotation的选中情况，更新CyclingIndex
-(void)updateCyclingIndex
{
	//是否已经有已经选中的了
	NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
	if (selectedAnnotations !=nil && selectedAnnotations.count >0) 
	{
		id selectedAnnotation = [selectedAnnotations objectAtIndex:0];
		if ([selectedAnnotation isKindOfClass:[YCAnnotation class]]) 
		{
			self->cyclingIndex = [self.mapAnnotations indexOfObject:selectedAnnotation];
			if (NSNotFound == self->cyclingIndex) 
				self->cyclingIndex = 0;
		}
	}
}

//设置上一个下一个按钮的可用状态
-(void)setPreviousNextButtonEnableStatus
{
	[self updateCyclingIndex];
	if (self.mapAnnotations.count > 1) 
	{
		[self.previousBarItem setEnabled:YES];
		[self.nextBarItem setEnabled:YES];
		
		if (self->cyclingIndex ==0) 
		{
			[self.previousBarItem setEnabled:NO];
			[self.nextBarItem setEnabled:YES];
		}
		
		if (self->cyclingIndex >= self.mapAnnotations.count-1) 
		{
			[self.previousBarItem setEnabled:YES];
			[self.nextBarItem setEnabled:NO];
		}
		
	}else {
		[self.previousBarItem setEnabled:NO];
		[self.nextBarItem setEnabled:NO];
	}
}

-(void)setToolBarItemsEnabled:(BOOL)enabled
{
	NSArray *baritems = self.toolbar.items ;
	for(NSUInteger i=0;i<baritems.count;i++)
	{
		[[baritems objectAtIndex:i] setEnabled:enabled];
	}
	if (enabled) //设置上一个下一个按钮的可用状态
	{
		[self setPreviousNextButtonEnableStatus];
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

-(void)addMapAnnotations
{	[self updateMapAnnotations];
	[self.mapView addAnnotations:self.mapAnnotations];	
}

////设置正在定位barItem处于定位状态
-(void)setLocationBarItem:(BOOL)locationing
{
	NSMutableArray *baritems = [NSMutableArray array];
	[baritems addObjectsFromArray:self.toolbar.items];
	
	if(locationing)
		[baritems replaceObjectAtIndex:0 withObject:self.locationingBarItem];
	else 
		[baritems replaceObjectAtIndex:0 withObject:self.currentLocationBarItem];

	[self.toolbar setItems:baritems animated:NO];
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
		
		//显示toolbar
		if (regionCenterWithCurrentLocation)  
		{
			[UIUtility setBar:self.toolbar topBar:NO visible:YES animated:YES animateDuration:1.0 animateName:@"showOrHideToolbar"];
			self.curlbackgroundView.canHideToolBar = YES;
			[self.curlbackgroundView startToolbarTimeInterval:5.0];
		}

		
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
		 
		 //显示toolbar
		 if (regionCenterWithCurrentLocation)  
		 {
			 [UIUtility setBar:self.toolbar topBar:NO visible:YES animated:YES animateDuration:1.0 animateName:@"showOrHideToolbar"];
			 self.curlbackgroundView.canHideToolBar = YES;
			 [self.curlbackgroundView startToolbarTimeInterval:5.0];
		 }
		 
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
		[locationTimer invalidate];
		[locationTimer release];
		locationTimer = nil;
		
		self->defaultMapRegion = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate,1500.0,1500.0);
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:kLocationedNotification object:self];
	}else {
		//Time out 
		timePassed +=0.5;
		if (timePassed > 20.0)  //10秒time out
		{
			timePassed = 0;
			
			[locationTimer invalidate];
			[locationTimer release];
			locationTimer = nil;
			
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			[notificationCenter postNotificationName:kTimeOutForLocationNotification object:self];

		}
	}
	
}

-(void)startCheckLocationTimer
{
	NSTimeInterval ti = 0.2;
	locationTimer = [[NSTimer timerWithTimeInterval:ti target:self selector:@selector(checkLocation) userInfo:nil repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:locationTimer forMode:NSRunLoopCommonModes];
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
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetToolbarTimeInterval:3.0];
	}

	[self setLocationBarItem:YES];
	[self setToolBarItemsEnabled:NO];
	[self startCheckLocationTimer];
}

//轮转Annotation 
//返回值 YES:已经到头
-(BOOL)cycleAnnotationsWithForward:(BOOL)forward
{
	BOOL retVal = NO;
	if(self.mapAnnotations.count ==0) return NO;
	
	[self updateCyclingIndex];

	if (forward) 
	{
		self->cyclingIndex++;
		if (self->cyclingIndex >= self.mapAnnotations.count)
		{
			self->cyclingIndex = 0;
			retVal = YES;
		}
		
	}else {
		self->cyclingIndex--;
		if (self->cyclingIndex < 0)
		{
			self->cyclingIndex = self.mapAnnotations.count -1;
			retVal = YES;
		}
	}


	
	YCAnnotation *cyclingAnnotation = [self.mapAnnotations objectAtIndex:cyclingIndex];
	
	if ([self isValidCoordinate:cyclingAnnotation.coordinate])
	{
		//仅仅设置中心
		[self.mapView setCenterCoordinate:cyclingAnnotation.coordinate animated:YES];
		//选中
		[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:cyclingIndex] afterDelay:0.2];
		
	}
	
	return retVal;
	
}

-(IBAction)previousPinButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetToolbarTimeInterval:3.0];
	}
	
	[self cycleAnnotationsWithForward:NO];

	[self setPreviousNextButtonEnableStatus];
}
-(IBAction)nextPinButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetToolbarTimeInterval:3.0];
	}

	[self cycleAnnotationsWithForward:YES];

	[self setPreviousNextButtonEnableStatus];
}

-(IBAction)currentPinButtonPressed:(id)sender
{	
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	[self cycleAnnotationsWithForward:YES];
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
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetToolbarTimeInterval:3.0];
	}
	
	[self.searchController setActive:YES animated:YES];   //处理search状态
}

-(IBAction)pageCurlButtonPressed:(id)sender
{
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetToolbarTimeInterval:3.0];
	}
	
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
		self.toolbar.hidden = NO;
	} else { //在tab上的地图，一直有searchbar
		self.searchBar.hidden = NO;
		self.searchBar.showsBookmarkButton = YES;
		self.toolbar.alpha = 0.80f;
		self.toolbar.hidden = YES;
	}
	[self setToolBarItemsEnabled:NO];
	
	self.searchController = [[YCSearchController alloc] initWithDelegate:self
												 searchDisplayController:self.searchDisplayController];
	
	
	//curView
	UIViewAutoresizing viewautoresizingMask = 0;
	if (!regionCenterWithCurrentLocation) 
	{
		viewautoresizingMask = UIViewAutoresizingFlexibleLeftMargin
							 | UIViewAutoresizingFlexibleWidth
							 | UIViewAutoresizingFlexibleRightMargin
							 | UIViewAutoresizingFlexibleTopMargin
							 | UIViewAutoresizingFlexibleHeight
							 | UIViewAutoresizingFlexibleBottomMargin;
		
		self.curlbackgroundView.autoresizingMask = viewautoresizingMask;
		self.curlView.autoresizingMask = viewautoresizingMask;
		self.mapView.autoresizingMask = viewautoresizingMask;
		self.mapTypeSegmented.autoresizingMask = viewautoresizingMask;
		self.curlImageView.autoresizingMask = viewautoresizingMask;
		
	}/*else {
		viewautoresizingMask = UIViewAutoresizingFlexibleLeftMargin
							 | UIViewAutoresizingFlexibleTopMargin;
	}*/


		
	

	//判断闹钟坐标是否有效
	if (![self isValidCoordinate:self.alarm.coordinate]) 
		self.alarm.coordinate = [YCParam paramSingleInstance].lastLoadMapRegion.center;
	
	self.alarmTemp = [self.alarm copy];
	
	//注册消息
	[self registerNotifications];

	[self showMaskView];
	[self addMapAnnotations];
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
	
	//设置上一个下一个按钮的可用状态
	if (self.regionCenterWithCurrentLocation) 
	{
		//[self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
		//[self addMapAnnotations];
		[self setPreviousNextButtonEnableStatus];
	}
	
}

-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	//保存最后加载的区域
	[YCParam paramSingleInstance].lastLoadMapRegion = self.mapView.region;
}


#pragma mark - 
#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if (self.regionCenterWithCurrentLocation) 
	{
		[self setPreviousNextButtonEnableStatus];
	}
	
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	self.annotationManipulating = userLocation;
	reverseGeocoder = [self reverseGeocoder:userLocation.coordinate]; 
	[reverseGeocoder start];
	
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	NSInteger selectedIndex = -1;
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
			//选中
			YCAnnotation *annotation = annotationView.annotation;
			YCMapAnnotationType type = annotation.annotationType;
			
			
			if (self.regionCenterWithCurrentLocation) 
			{
				if (YCMapAnnotationTypeMovingToTarget == type || YCMapAnnotationTypeSearch == type)
				{
					selectedIndex = [self.mapAnnotations indexOfObject:annotation];
				}

			}else {
				selectedIndex = [self.mapAnnotations indexOfObject:annotation];
			}
			
		}
	}
	
	//判断上次最后选中的坐标，是否在屏幕中
	if (-1 == selectedIndex) 
	if (self->cyclingIndex < self.mapAnnotations.count)
	{
		YCAnnotation *annotation = [self.mapAnnotations objectAtIndex:self->cyclingIndex];
		MKMapPoint point = MKMapPointForCoordinate(annotation.coordinate);
		MKMapRect rect = self.mapView.visibleMapRect;
		BOOL isContains = MKMapRectContainsPoint(rect, point);
		if (isContains) 
		{
			selectedIndex = self->cyclingIndex;
		}
		
	}
	
	if (selectedIndex !=-1) 
	{
		[self performSelector:@selector(selectAnnotationAtIndex:) withObject:[NSNumber numberWithInt:selectedIndex] afterDelay:0.5];
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
		
		pinView.canShowCallout = YES;
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		pinView.rightCalloutAccessoryView = rightButton;
		
	}
	
	pinView.animatesDrop = YES;
	pinView.draggable = YES;
	UIImageView *sfIconView = nil;
	switch (((YCAnnotation*)annotation).annotationType) 
	{
		case YCMapAnnotationTypeStandard:
			pinView.animatesDrop = NO;
			pinView.draggable = NO;
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeStandardEnabledDrag:
			pinView.pinColor = MKPinAnnotationColorPurple;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeLocating:
			pinView.pinColor = MKPinAnnotationColorPurple;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeMovingToTarget:
			pinView.animatesDrop = NO;
			pinView.draggable = NO;
			pinView.pinColor = MKPinAnnotationColorGreen;
			sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			break;
		case YCMapAnnotationTypeSearch:
			pinView.draggable = NO;
			pinView.pinColor = MKPinAnnotationColorRed;
			sfIconView = nil;
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
	//self.annotationAlarmEditing.title = self.alarmTemp.alarmName;
	
	
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
	
		YCAnnotation *annotationTemp = nil;
		NSString *title = nil;
		NSString *subtitle = nil;
		if(!self.regionCenterWithCurrentLocation) 
		{
			annotationTemp = self.annotationAlarmEditing;
			title = forwardGeocoder.searchQuery;
			subtitle = place.address!=nil ? place.address: @" " ;
			[self setAnnotationAlarmEditingWithCoordinate:place.coordinate title:title subtitle:subtitle animated:NO];
		}else { //在tab页面上的搜索结果大头针
			annotationTemp = self.annotationSearched;
			title = place.address!=nil ? place.address: @" " ;
			annotationTemp.title = title;
			annotationTemp.coordinate = place.coordinate;
			//[self.mapAnnotations addObject:annotationTemp]; //加入到Annotation列表中
		}
		
		//先删除原来的annotation
		if (annotationTemp)
			[self.mapView removeAnnotation:annotationTemp];
				
		////////////////////////
		//Zoom into the location
		self->defaultMapRegion = place.coordinateRegion;
		self->defaultMapRegion.center = place.coordinate;
		double delay = [self setMapRegion:self->defaultMapRegion FromWorld:YES animatedToWorld:YES animatedToPlace:YES];
		//Zoom into the location
		////////////////////////
		
		
		//再加上
		//[self.mapView addAnnotation:self.annotationAlarmEditing];
		[self.mapView performSelector:@selector(addAnnotation:) withObject:annotationTemp afterDelay:delay+0.1];
			
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
	[self.searchController setActive:YES animated:YES];   //处理search状态
}


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

-(void)searchBarbookmarkButtonPressed:(id)sender
{
	[self.navigationController presentModalViewController:self.mapBookmarksListNavigationController animated:YES];
}

#pragma mark -
#pragma mark MapBookmarksListControllerDelegete methods
- (void)mapBookmarksListController:(MapBookmarksListController *)controller didChooseMapBookmark:(MapBookmark *)aBookmark;
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
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
	self.curlView = nil;;                           
	self.curlbackgroundView = nil;
	self.curlImageView = nil;
	self.activityIndicator = nil;         
	self.searchBar = nil;
	self.toolbar = nil;
	self.mapTypeSegmented = nil;          
	self.currentLocationBarItem = nil;       
	self.currentPinBarItem = nil;            
	self.searchBarItem = nil;                
	self.resetPinBarItem = nil;              
	self.pageCurlBarItem = nil;
	self.nextBarItem = nil;
	self.previousBarItem = nil;

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:kLocationedNotification object:nil];
	[notificationCenter removeObserver:self name:kTimeOutForLocationNotification object:nil];

}


- (void)dealloc 
{
	[self->locationTimer release];
	[self->reverseGeocoder release];
	[self.forwardGeocoder release];
	[self.searchController release];
	[self.alarms release];                       
	[self.mapAnnotations release];        
	[self.alarmTemp release];
	[self.annotationAlarmEditing release];
	[self.locationingBarItem release];
	[self.annotationSearched release];
	[self.mapBookmarksListController release];
    [self.mapBookmarksListNavigationController release];
	
	[super dealloc];
}




@end
 