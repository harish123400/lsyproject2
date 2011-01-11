//
//  AlarmPositionMapViewController.m
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "DataUtility.h"
#import "YCDeviceStatus.h"
#import "YCLocationUtility.h"
#import "AlarmModifyNotification.h"
#import "YCSearchBar.h"
#import "AlarmPositionMapViewController.h"
#import "YCAnnotation.h"
#import "YCAlarmEntity.h"
#import "UIUtility.h"
#import "YCParam.h"
#import "YCLog.h"
#import "AnnotationInfoViewController.h"
#import "YCTapView.h"
#import "MapBookmarksListController.h"
#import "MapBookmark.h"

//默认显示地图的范围
const  CLLocationDistance kDefaultLatitudinalMeters  = 1500.0;
const  CLLocationDistance kDefaultLongitudinalMeters = 1500.0;

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

/////////////////////////////////////
//地址反转
@synthesize placemarkForReverse;
/////////////////////////////////////

@synthesize searchController;
@synthesize regionCenterWithCurrentLocation;
@synthesize alarms;
@synthesize newAlarm; 
@synthesize alarmTemp;
@synthesize alarmsTemp;
@synthesize mapAnnotations;
@synthesize annotationAlarmEditing;
@synthesize annotationManipulating;

-(id)forwardGeocoder{
	if (forwardGeocoder == nil) {
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	return forwardGeocoder;
}

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
	for (NSUInteger i =0; i<self.alarmsTemp.count; i++) 
	{
		YCAlarmEntity *temp = [self.alarmsTemp objectAtIndex:i];
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
			annotation.subtitle = nil;
		}else {
			if(self.newAlarm)  //AlarmNew
			{
				annotation.annotationType = YCMapAnnotationTypeLocating;
			}else {
				annotation.annotationType = YCMapAnnotationTypeStandardEnabledDrag;
			}
			annotation.title = KMapNewAnnotationTitle;
			annotation.subtitle = temp.position;
			
			if([temp.alarmId isEqualToString:self.alarmTemp.alarmId])
				self.annotationAlarmEditing = annotation;
		}
		
		
		[array addObject:annotation];
		[annotation release];
	}
	
	self.mapAnnotations = array;
	[array release];

}

- (MapBookmarksListController *)mapBookmarksListController
{
    if (mapBookmarksListController == nil)
    {
        mapBookmarksListController = [[MapBookmarksListController alloc] initWithStyle:UITableViewStylePlain];
        mapBookmarksListController.delegate = self;
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
#pragma mark - Utility


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
	/*
	BOOL retVal = NO;
	int la = (int)coordinate.latitude;
	int lo = (int)coordinate.longitude;
	if (la == 0 && lo == 0 ) 
		retVal = NO;
	else 
		retVal = YES;
	
	return retVal;
	 */
	
	int la = (int)coordinate.latitude;
	int lo = (int)coordinate.longitude;
	if (la == 0 && lo == 0 ) 
		return NO;
	
	return CLLocationCoordinate2DIsValid(coordinate);
}

-(BOOL) isValidSpan:(MKCoordinateSpan)span
{	/*
	double lad = span.latitudeDelta;
	double lod = span.longitudeDelta;
	if (lad > 180.0 || lad < 0.0) return NO;
	if (lod > 180.0 || lod < 0.0) return NO;
	 */
	
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

//关掉MaskView,加入Annotations
-(void)addAnnotationsAfterCloseMask{
	
	[self updateMapAnnotations];  //生成Annotation
	
	//闹钟地址无效情况，用于addAlarm时候
	if(self.annotationAlarmEditing){
		if (![self isValidCoordinate:self.annotationAlarmEditing.coordinate] ) {
			self.annotationAlarmEditing.coordinate = self.mapView.region.center;
			/////////////////
			//改变了闹钟地址
			//self.alarmTemp.coordinate = self.mapView.region.center;
			//self.navigationItem.rightBarButtonItem.enabled = YES;	//激活Done按钮
			/////////////////
		}
	}
	
	[self.mapView addAnnotations:self.mapAnnotations];	//加入Annotation

	
	//选中
	if (self->annotationSelecting!=nil){
		[self performSelector:@selector(selectAnnotation:) withObject:annotationSelecting afterDelay:0.5]; //适当延长时间
	}
}

//关掉覆盖视图
-(void)closeMaskViewWithAnimated:(BOOL)animated
{
	//显示toolbar
	if (regionCenterWithCurrentLocation)  
	{
		[UIUtility setBar:self.toolbar topBar:NO visible:YES animated:YES animateDuration:1.0 animateName:@"showOrHideToolbar"];
		[self.curlbackgroundView startHideToolbarAfterTimeInterval:5.0];
	}else{//显示SearchBar -animated:NO 
		[UIUtility setBar:self.searchBar topBar:YES visible:YES animated:NO animateDuration:1.0 animateName:@"showOrHideSearchBar"];
		[self.curlbackgroundView startHideSearchBarAfterTimeInterval:15.0];
	}
	
	
	[self performSelector:@selector(addAnnotationsAfterCloseMask) withObject:nil afterDelay:1.1];
	
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
	self->isFirstShow = NO;
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

///////////////////////////////////////////////////////
//选中Annotation,该元素在mapView.annotations中。 －显示标题
-(void)selectAnnotationAtIndex:(NSNumber*)index
{
	NSInteger nIndex = [index intValue];
	if(nIndex >=0 && nIndex < self.mapView.annotations.count)
		[self.mapView selectAnnotation:[self.mapView.annotations objectAtIndex:nIndex] animated:YES];
}


-(void)selectAnnotation:(id<MKAnnotation>)annotation
{
	[self.mapView selectAnnotation:annotation animated:YES];
}


-(void)addMapAnnotations
{	[self updateMapAnnotations];
	[self.mapView addAnnotations:self.mapAnnotations];	
}

////设置"正在定位"barItem处于定位状态
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

////设置“回到当前位置按钮”的可用状态。
-(void)setLocationBarItem{
	
	CLLocationCoordinate2D currentMapCenter = self.mapView.region.center;
	CGPoint currentMapCenterPoint = [self.mapView convertCoordinate:currentMapCenter toPointToView:nil];
	
	//比较的坐标转换后到屏幕上的点；相等：BarItem不可用
	CLLocationCoordinate2D userCurrentLocation = {-10000.0,-10000.0};
	if (self.mapView.userLocation.location) userCurrentLocation = self.mapView.userLocation.location.coordinate;
	if (![self isValidCoordinate:userCurrentLocation]) return; //无效坐标
	
	CGPoint userCurrentLocationPoint = [self.mapView convertCoordinate:userCurrentLocation toPointToView:nil];
	int isA = compareCGPoint(currentMapCenterPoint, userCurrentLocationPoint);
	if (0 == isA) {
		self.currentLocationBarItem.enabled = NO;
	}else {
		self.currentLocationBarItem.enabled = YES;
	}
	
}

////设置“回到正在编辑按钮”的可用状态。
-(void)setCurrentPinBarItem{
	
	//取消由点击按钮CurrentPin引发的调用
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setCurrentPinBarItem) object:nil];
	
	CLLocationCoordinate2D currentMapCenter = self.mapView.region.center;
	CGPoint currentMapCenterPoint = [self.mapView convertCoordinate:currentMapCenter toPointToView:nil];
	
	//比较的坐标转换后到屏幕上的点；相等：BarItem不可用
	CLLocationCoordinate2D alarmEditing = self.annotationAlarmEditing.coordinate;
	if (![self isValidCoordinate:alarmEditing]) return; //无效坐标
	
	CGPoint alarmEditingPoint = [self.mapView convertCoordinate:alarmEditing toPointToView:nil];
	int isA = compareCGPoint(currentMapCenterPoint, alarmEditingPoint);
	if (0 == isA) {
		self.currentPinBarItem.enabled = NO;
	}else {
		self.currentPinBarItem.enabled = YES;
	}
	
}

-(void)copyAlarm{
	self.alarmTemp = [self.alarm copy];
	self.alarmsTemp = [self.alarms mutableCopy];
	//判断闹钟坐标是否有效
	if (self.alarmTemp) 
	{
		//替换临时列表中的alarmTemp
		NSInteger row = [self.alarms indexOfObject:self.alarm];
		if (row < self.alarmsTemp.count) {
			[self.alarmsTemp replaceObjectAtIndex:row withObject:self.alarmTemp];
		}
			
		//if (![self isValidCoordinate:self.alarmTemp.coordinate]) 
		//	self.alarmTemp.coordinate = [YCParam paramSingleInstance].lastLoadMapRegion.center;
		
	}
}


#pragma mark -
#pragma mark alarms Notification
- (void) handle_AlarmsChanged: (id) notification 
{
	if (regionCenterWithCurrentLocation){
		self.alarms = [DataUtility alarmArray];
		
		[self copyAlarm]; 
		
		//先移除
		[self.mapView removeAnnotations:self.mapAnnotations];
		//加入Annotation
		[self addMapAnnotations];
	}
}



#pragma mark -
#pragma mark Event

-(void)setDoneStyleToBarButtonItem:(UIBarButtonItem*)buttonItem
{
	buttonItem.style =  UIBarButtonItemStyleDone;
}

//覆盖父类
-(IBAction)doneButtonPressed:(id)sender
{	
	self.alarm.coordinate = self.alarmTemp.coordinate;
	self.alarm.alarmName = self.alarmTemp.alarmName;
	self.alarm.position = self.alarmTemp.position;
	self.alarm.positionShort = self.alarmTemp.positionShort;
	self.alarm.nameChanged = self.alarmTemp.nameChanged;
	[self.navigationController popViewControllerAnimated:YES];
	
	[super doneButtonPressed:sender];
}


-(IBAction)currentLocationButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetTimeIntervalForHideToolbar:3.0];
	}
	
	//显示 打开定位服务的提示框
	BOOL enabledLocation = [[YCDeviceStatus deviceStatusSingleInstance] enabledLocation];
	if (!enabledLocation) {

		[[YCDeviceStatus deviceStatusSingleInstance].locationManager startUpdatingLocation];
		
		[UIUtility simpleAlertBody:nil 
						alertTitle:@"定位服务已经关闭" 
				 cancelButtonTitle:kAlertBtnCancel
					 OKButtonTitle:kAlertBtnSettings
						  delegate:nil];
	}
	
	
	//选中当前位置
	if (self.mapView.userLocation.location)
	{
		[self setLocationBarItem:YES];    //把barItem改成正在定位的状态
		[self performSelector:@selector(setLocationBarItem:) withObject:nil afterDelay:0.5];//0.5秒后，把barItem改回正常状态
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate,kDefaultLatitudinalMeters,kDefaultLongitudinalMeters);
		[self setMapRegion:region FromWorld:NO animatedToWorld:NO animatedToPlace:YES];
		[self performSelector:@selector(selectAnnotation:) withObject:self.mapView.userLocation afterDelay:0.5]; //适当延长时间
	}
	 

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
	}
	
	//选中
	if (cyclingAnnotation)
		[self performSelector:@selector(selectAnnotation:) withObject:cyclingAnnotation afterDelay:0.2];
	
	
	return retVal;
	
}

-(IBAction)previousPinButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetTimeIntervalForHideToolbar:3.0];
	}
	
	[self cycleAnnotationsWithForward:NO];

	[self setPreviousNextButtonEnableStatus];
}
-(IBAction)nextPinButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetTimeIntervalForHideToolbar:3.0];
	}

	[self cycleAnnotationsWithForward:YES];

	[self setPreviousNextButtonEnableStatus];
}

-(IBAction)currentPinButtonPressed:(id)sender
{	
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	[self cycleAnnotationsWithForward:YES];
	
	//解决：由resetPinButtonPressed引起的大头针位置变化
	[self performSelector:@selector(setCurrentPinBarItem) withObject:nil afterDelay:1.5];
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
	[self beginReverseWithCoordinate:self.annotationAlarmEditing.coordinate];

}


-(IBAction)searchButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetTimeIntervalForHideToolbar:3.0];
	}
	
	[self.searchController setActive:YES animated:YES];   //处理search状态
}

-(IBAction)pageCurlButtonPressed:(id)sender
{
	if (regionCenterWithCurrentLocation) //reset Toolbar的隐藏倒计时
	{
		[self.curlbackgroundView resetTimeIntervalForHideToolbar:3.0];
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

- (void) registerLocationedNotifications 
{
	
	//定位完成
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	//alarms改变
	[notificationCenter addObserver: self
						   selector: @selector (handle_AlarmsChanged:)
							   name: kAlarmsDidChangeNotification
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
	
	//searchBar,toolbar
	self.searchBar.hidden = NO;
	[(YCSearchBar*)self.searchBar setCanResignFirstResponder:YES];
	if (!regionCenterWithCurrentLocation) 
	{  
		self.curlbackgroundView.canHideSearchBar = YES;
		
		self.curlbackgroundView.canHideToolBar = NO;
		self.toolbar.hidden = NO;
	} else { //在tab上的地图，一直有searchbar,toolbar可以隐藏
		self.curlbackgroundView.canHideSearchBar = NO;
		self.searchBar.showsBookmarkButton = YES;
		
		self.curlbackgroundView.canHideToolBar = YES;
		self.toolbar.hidden = YES;
		self.toolbar.alpha = 0.80f;
	}
	//[self setToolBarItemsEnabled:NO];
	
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
		
	}
	//else {
	//	viewautoresizingMask = UIViewAutoresizingFlexibleLeftMargin
	//						 | UIViewAutoresizingFlexibleTopMargin;
	//}
	


		
	//注册定位成功消息
	[self registerLocationedNotifications];
	
	//覆盖
	[self showMaskView];
	
	

}

#define kTimeSpanForUserLocation   15.0

////先用上一次加载的region；无效，使用设备当前位置
-(void)setRegionWithLastLoadOrUserLocation{ 
	
	MKCoordinateRegion region = [YCParam paramSingleInstance].lastLoadMapRegion;
	if (![self isValidRegion:region]) {//上一次打开地图的region
		if (!self.mapView.userLocation.location) { //设备当前位置
			self->isRegionWithUserLocation = YES;
			[self performSelector:@selector(endUpdateUserLocation) withObject:nil afterDelay:kTimeSpanForUserLocation];
		}else {
			region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate,kDefaultLatitudinalMeters,kDefaultLongitudinalMeters);
		}
		
	}
	
	if ([self isValidRegion:region]) {
		//关掉覆盖视图
		[self closeMaskViewWithAnimated:YES];
		//先到世界地图，在下来
		[self setMapRegion:region FromWorld:YES animatedToWorld:NO animatedToPlace:YES];
	}
}

//为了延时执行。否则有上个bar的痕迹
-(void)performShowBar:(UIView*)theBar{
	[UIUtility setBar:theBar topBar:NO visible:YES animated:YES animateDuration:1.0 animateName:@"showOrHideToolbar"];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.regionCenterWithCurrentLocation) 
	{
		//设置上一个下一个按钮的可用状态
		[self setPreviousNextButtonEnableStatus];
		
		//除了第一次外，每次WillAppear都显示Toolbar。第一次在定位结束后显示
		if (!isFirstShow) { 
			if (self.toolbar.hidden == YES) {
				[self performSelector:@selector(performShowBar:) withObject:self.toolbar afterDelay:0.1];
			}
			
			[self.curlbackgroundView resetTimeIntervalForHideToolbar:3.0];
		}
		
		self.title = KMapsTabBarItemTitle;
		self.navigationController.navigationBarHidden = YES;   //在tab上隐藏navigationBar
	}else {
		self.title = KAlarmPostionLabel;
		
		//除了第一次外，每次WillAppear都显示Searchbar。-animated:NO 
		if (!isFirstShow) {
			if (self.searchBar.hidden == YES) {
				[self performSelector:@selector(performShowBar:) withObject:self.searchBar afterDelay:0.1];
			}
			
			[self.curlbackgroundView resetTimeIntervalForHideSearchBar:10.0];
		}
	}
	

	
	[self copyAlarm];
	
	if (self->isFirstShow) {
		
		if(self.alarmTemp)  //编辑闹钟、或有闹钟到达
		{
			if ([self isValidCoordinate:self.alarmTemp.coordinate]) {
				self->annotationSelecting = self.annotationAlarmEditing;
				[self closeMaskViewWithAnimated:YES];//关掉覆盖视图
				
				MKCoordinateRegion alarmRegion = MKCoordinateRegionMakeWithDistance(self.alarmTemp.coordinate,kDefaultLatitudinalMeters,kDefaultLongitudinalMeters);
				[self setMapRegion:alarmRegion FromWorld:YES animatedToWorld:NO animatedToPlace:YES];
			}else //alarmTemp中的坐标无效
				[self setRegionWithLastLoadOrUserLocation];
			
		}else { //tab上显示
			[self setRegionWithLastLoadOrUserLocation];
		}
		

	}
	 
}

/*
-(void) viewDidAppear:(BOOL)animated{
	
	[super viewDidAppear:animated];
	
	/////////////////////////
	//不是当前视图，自动隐藏后，需要再设置一下
	if (self.toolbar.hidden == YES) {
		self.toolbar.hidden = YES;  
	}
	
	if (self.searchBar.hidden == YES) {
		self.searchBar.hidden =YES;
	}
	
}
 */


-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if (!self.regionCenterWithCurrentLocation) {
		self.title = nil;
	}
	
	//保存最后加载的区域
	[YCParam paramSingleInstance].lastLoadMapRegion = self.mapView.region;
	[[YCParam paramSingleInstance] saveParam];
	
	/*
	//toolbar消失
	if (self.regionCenterWithCurrentLocation) 
	{
		self.toolbar.hidden = YES;
	}else {
		self.searchBar.hidden = YES;
	}
	 */

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

-(void) endUpdateUserLocation{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endUpdateUserLocation) object:nil];
	
	//反转地址	
	self.annotationManipulating = self.mapView.userLocation;
	[self beginReverseWithCoordinate:self.mapView.userLocation.coordinate];
	
	//设置地图region
	if (self->isRegionWithUserLocation) {
		self->isRegionWithUserLocation = NO; 
		
		//关掉覆盖视图
		[self closeMaskViewWithAnimated:YES];
		
		if (self.mapView.userLocation.location) {
			self->annotationSelecting = self.mapView.userLocation; //将要选中当前位置
			MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.location.coordinate,kDefaultLatitudinalMeters,kDefaultLongitudinalMeters);
			[self setMapRegion:region FromWorld:YES animatedToWorld:YES animatedToPlace:YES];
		}
	}
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	[self performSelector:@selector(endUpdateUserLocation) withObject:nil afterDelay:0.1];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	id annotationSelectingTemp = nil;

	for (NSUInteger i=0; i<views.count; i++) 
	{
		MKAnnotationView *annotationView = [views objectAtIndex:i];
		
		//当前位置
		if ([annotationView.annotation isKindOfClass:[MKUserLocation class]]) 
		{
			UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flagAsAnnotation.png"]];
			annotationView.leftCalloutAccessoryView = sfIconView;
			[sfIconView release];
			
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[rightButton addTarget:self
							action:@selector(showDetails:)
				  forControlEvents:UIControlEventTouchUpInside];
			annotationView.rightCalloutAccessoryView = rightButton;
		}
		
		//处理选中，下面的几种情况不会同时出现
		id annotation = annotationView.annotation;
		if ([annotation isKindOfClass:[YCAnnotation class]])
		{
			switch (((YCAnnotation*)annotation).annotationType) {
				case YCMapAnnotationTypeMovingToTarget:
					annotationSelectingTemp = annotation;
					break;
				case YCMapAnnotationTypeSearch:
					annotationSelectingTemp = annotation;
					break;
				case YCMapAnnotationTypeLocating:
				case YCMapAnnotationTypeStandardEnabledDrag:
					annotationSelectingTemp = annotation;
					break;
				default:
					break;
			}
		}

	}
	
	if (annotationSelectingTemp) 
		[self performSelector:@selector(selectAnnotation:) withObject:annotationSelectingTemp afterDelay:0.5];
	
}



- (void)showDetails:(id)sender
{
	//back按钮
	if (!self.regionCenterWithCurrentLocation) 
		self.title = nil;
	
	
	//取得当前操作的Annotation
	MKAnnotationView *annotationView = (MKAnnotationView *)((UIView*)sender).superview.superview;
	//self.annotationAlarmEditing = annotationView.annotation;
	
	AnnotationInfoViewController *annotationInfoViewCtl = [[AnnotationInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    annotationInfoViewCtl.annotation = annotationView.annotation;
	annotationInfoViewCtl.annotationTitle = annotationView.annotation.title;
	if (annotationView.annotation.subtitle !=nil) 
	{
		annotationInfoViewCtl.annotationSubtitle = annotationView.annotation.subtitle;
	}else { //annotation.subtitle 没有被赋值
		NSUInteger index = [self.mapAnnotations indexOfObject:annotationView.annotation];
		if (index != NSNotFound && index < self.alarmsTemp.count)
		{
			YCAlarmEntity *alarmObj = [self.alarmsTemp objectAtIndex:index];
			annotationInfoViewCtl.annotationSubtitle = alarmObj.position;
		}else 
		   annotationInfoViewCtl.annotationSubtitle = @"";
	}


	self.navigationController.navigationBarHidden = NO;//在闹钟标签页面上显示navbar
	[self.navigationController pushViewController:annotationInfoViewCtl animated:YES];
	[annotationInfoViewCtl release];
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
			//pinView.animatesDrop = NO;
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
			//pinView.animatesDrop = NO;
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
	
	switch (newState) 
	{
		case MKAnnotationViewDragStateStarting:  //开始拖拽的－紫色
			((MKPinAnnotationView *)annotationView).pinColor = MKPinAnnotationColorPurple;
			((YCAnnotation *)annotationView.annotation).annotationType = YCMapAnnotationTypeLocating;
			break;
		case MKAnnotationViewDragStateEnding:   //停止拖拽
			//激活Done按钮
			self.navigationItem.rightBarButtonItem.enabled = YES;
			break;
		case MKAnnotationViewDragStateNone:   //结束拖拽－大头针落下
			//为闹钟坐标赋值
			self.alarmTemp.coordinate = annotationView.annotation.coordinate;
		
			self.annotationManipulating = annotationView.annotation;
			//反转坐标－地址
			((YCAnnotation*) annotationView.annotation).subtitle = @"";
			[self beginReverseWithCoordinate:annotationView.annotation.coordinate];
		default:
			break;

	}
	 

}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated{
	//设置“回到正在编辑按钮”的可用状态。
	[self setCurrentPinBarItem];
	//设置“回到当前位置按钮”的可用状态。
	[self setLocationBarItem];
}



#pragma mark -
#pragma mark Utility - ReverseGeocoder

-(void) setAnnotationAlarmEditingWithCoordinate:(CLLocationCoordinate2D)coordinate 
										  title:(NSString*)title subtitle:(NSString*)subtitle subtitleShort:(NSString*)subtitleShort
									   animated:(BOOL)animated;
{
	if (!self.alarmTemp.nameChanged) {
		if (title == nil || [title length] == 0) 
			title = kDefaultLocationAlarmName;
		self.alarmTemp.alarmName = title;
	}
	
	self.alarmTemp.coordinate = coordinate;
	self.alarmTemp.position = subtitle;
	self.alarmTemp.positionShort = subtitleShort!=nil ? subtitleShort:subtitle; //短地址空，使用长地址
	
	//self.annotationAlarmEditing.coordinate = self.alarmTemp.coordinate;  //不能在这里设置，会引起拖动的大头针小跳的。
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

#define kTimeOutForReverse 8.0

-(void)beginReverseWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	@try {
		//初始化，reverseGeocoder对象必须根据特定坐标init。
		reverseGeocoder = [self reverseGeocoder:coordinate];
		reverseGeocoder.delegate = self;
		
		//反转坐标
		self.placemarkForReverse = nil; //先赋空相关数据
		[reverseGeocoder start];
		[self performSelector:@selector(endReverse) withObject:nil afterDelay:kTimeOutForReverse];
	}
	@catch (NSException * e) {
		[UIUtility sendSimpleNotifyForAlart:@"beginReverseWithCoordinate NSException"];
		[[YCLog logSingleInstance] addlog:@"beginReverseWithCoordinate NSException"];
		[[YCLog logSingleInstance] addlog:[e description]];
	}
	

}

-(void)endReverse
{
	@try {
		
		//如果超时了，反转还没结束，结束它
		[reverseGeocoder cancel];
		//取消掉另一个调用
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endReverse) object:nil];
		
		//
		CLLocationCoordinate2D coordinate = reverseGeocoder.coordinate;
		NSString *title = nil;
		NSString *subtitle = nil;
		NSString *subtitleShort = nil;
		if (self.placemarkForReverse == nil) {
			//反转坐标 失败，使用坐标
			title = nil;
			subtitle = [UIUtility convertCoordinate:coordinate];
		}else {
			title = [UIUtility titleStringFromPlacemark:self.placemarkForReverse];
			subtitle = [UIUtility positionStringFromPlacemark:self.placemarkForReverse];
			subtitleShort = [UIUtility positionShortStringFromPlacemark:self.placemarkForReverse];
		}
		
		if (self.annotationManipulating != self.annotationAlarmEditing)
		{
			if ([self.annotationManipulating isKindOfClass:[MKUserLocation class]])
			{          
				((MKUserLocation*)self.annotationManipulating).subtitle = subtitle;
			}
		}
		else 
			[self setAnnotationAlarmEditingWithCoordinate:coordinate title:title subtitle:subtitle subtitleShort:subtitleShort animated:YES];
		
	}
	@catch (NSException * e) {
		[UIUtility sendSimpleNotifyForAlart:@"beginReverseWithCoordinate NSException"];
		[[YCLog logSingleInstance] addlog:@"beginReverseWithCoordinate NSException"];
		[[YCLog logSingleInstance] addlog:[e description]];
	}
	
		
}


#pragma mark -
#pragma mark MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	self.placemarkForReverse = placemark;
	[self performSelector:@selector(endReverse) withObject:nil afterDelay:0.1];  //数据更新后，等待x秒
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	self.placemarkForReverse = nil;
	[self performSelector:@selector(endReverse) withObject:nil afterDelay:0.1];  //等待x秒，结束
}


#pragma mark -
#pragma mark Utility - ForwardGeocoder

#define kTimeOutForForwardGeocoder    10.0
-(void)beginForwardGeocoderWithSearchString:(NSString *)searchString{
	// Forward geocode!
	[self.forwardGeocoder findLocation:searchString];
	[self performSelector:@selector(endForwardGeocoder) withObject:nil afterDelay:kTimeOutForForwardGeocoder];
}

-(void)endForwardGeocoder{
	//如果超时了，还没结束，结束它
	[self.forwardGeocoder cancel]; 
	//取消掉另一个调用
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endForwardGeocoder) object:nil];
	
	//结束搜索状态
	[self.searchController setActive:NO animated:YES];   //处理search状态
	
	NSUInteger searchResults = [self.forwardGeocoder.results count];
	if(self.forwardGeocoder.status == G_GEO_SUCCESS && searchResults > 0)
	{
		//加到最近查询list中
		[self.searchController addListContentWithString:self.forwardGeocoder.searchQuery];
		
		//离当前位置最近的元素
		CLLocationDistance distanceOfNearest = 900000000000.0;
		NSUInteger indexOfNearest =0;
		
		for(NSUInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *placeTmp = [self.forwardGeocoder.results objectAtIndex:i];
			
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
		
		
		BSKmlResult *place = [self.forwardGeocoder.results objectAtIndex:indexOfNearest];  /////用最近的

		
		YCAnnotation *annotationTemp = nil;
		NSString *title = nil;
		NSString *subtitle = nil;
		if(!self.regionCenterWithCurrentLocation) 
		{
			annotationTemp = self.annotationAlarmEditing;
			title = self.forwardGeocoder.searchQuery;
			subtitle = place.address!=nil ? place.address: @" " ;
			[self setAnnotationAlarmEditingWithCoordinate:place.coordinate title:title subtitle:subtitle subtitleShort:subtitle animated:NO];
			annotationTemp.coordinate = place.coordinate;
		}else { //在tab页面上的搜索结果大头针
			annotationTemp = self.annotationSearched;
			title = self.forwardGeocoder.searchQuery ;
			subtitle = place.address!=nil ? place.address: @" " ;
			annotationTemp.title = title;
			annotationTemp.subtitle = subtitle;
			annotationTemp.coordinate = place.coordinate;
		}
		
		//先删除原来的annotation
		if (annotationTemp)
			[self.mapView removeAnnotation:annotationTemp];
		
		////////////////////////
		//Zoom into the location
		MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotationTemp.coordinate,kDefaultLatitudinalMeters,kDefaultLongitudinalMeters);
		double delay = [self setMapRegion:region FromWorld:YES animatedToWorld:YES animatedToPlace:YES];
		//Zoom into the location
		////////////////////////
		//NSLog(@"annotationTemp.coordinate:%f,%f",annotationTemp.coordinate.latitude,annotationTemp.coordinate.longitude);
		
		
		//再加上
		//[self.mapView addAnnotation:self.annotationAlarmEditing];
		[self.mapView performSelector:@selector(addAnnotation:) withObject:annotationTemp afterDelay:delay+0.1];
		
	}else {
		
		switch (self.forwardGeocoder.status) {
			case G_GEO_BAD_KEY:
				[UIUtility simpleAlertBody:kAlertMsgError1WhenSearchMap 
								alertTitle:kAlertTitleDefaultErrorWhenSearchMap
						 cancelButtonTitle:kAlertBtnCancel
						     OKButtonTitle:kAlertBtnRetry
								  delegate:self];
				break;
				
			case G_GEO_UNKNOWN_ADDRESS:
				[UIUtility simpleAlertBody:kAlertMsgError1WhenSearchMap 
								alertTitle:kAlertTitleNoResultsWhenSearchMap 
						 cancelButtonTitle:kAlertBtnCancel
						     OKButtonTitle:kAlertBtnRetry 
								  delegate:self];
				
				break;
				
			case G_GEO_TOO_MANY_QUERIES:
				[UIUtility simpleAlertBody:kAlertMsgError2WhenSearchMap 
								alertTitle:kAlertTitleTooManyQueriesWhenSearchMap 
						 cancelButtonTitle:kAlertBtnOK 
								  delegate:nil];  //只用1个按钮，而且不用retry
				break;
				
			case G_GEO_SERVER_ERROR:
				[UIUtility simpleAlertBody:kAlertMsgError1WhenSearchMap 
								alertTitle:kAlertTitleDefaultErrorWhenSearchMap 
						 cancelButtonTitle:kAlertBtnCancel
						     OKButtonTitle:kAlertBtnRetry
								  delegate:self];
				break;
				
				
			default:
				[UIUtility simpleAlertBody:kAlertMsgError1WhenSearchMap 
								alertTitle:kAlertTitleDefaultErrorWhenSearchMap 
						 cancelButtonTitle:kAlertBtnCancel
						     OKButtonTitle:kAlertBtnRetry
								  delegate:self];
				break;
		}
		
	}
	
}

#pragma mark -
#pragma mark BSForwardGeocoderDelegate


-(void)forwardGeocoderFoundLocation
{
	[self performSelector:@selector(endForwardGeocoder) withObject:nil afterDelay:0.1];  //数据更新后，等待x秒
}


-(void)forwardGeocoderError:(NSString *)errorMessage
{
	[self performSelector:@selector(endForwardGeocoder) withObject:nil afterDelay:0.1];  //数据更新后，等待x秒
}
 


#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)  
		[self.searchController setActive:YES animated:YES];   //search状态
}


#pragma mark -
#pragma mark YCSearchControllerDelegete methods

- (NSArray*)searchController:(YCSearchController *)controller searchString:(NSString *)searchString
{
	//结束其他的搜索
	[self.forwardGeocoder cancel]; 
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endForwardGeocoder) object:nil];
	
	
	[self beginForwardGeocoderWithSearchString:searchString];
	return nil;
}

-(void)searchBarbookmarkButtonPressed:(id)sender
{
	if (self->isCurl) [self pageCurlButtonPressed:nil]; //处理卷页
	
	[self.mapBookmarksListController.bookmarksList removeAllObjects];
	
	//当前位置
	if (self.mapView.userLocation.location) 
	{
		MapBookmark *bmCurrentLocation = [[MapBookmark alloc] init];
		bmCurrentLocation.bookmarkName = self.mapView.userLocation.title;
		bmCurrentLocation.annotation = self.mapView.userLocation;
		[self.mapBookmarksListController.bookmarksList addObject:bmCurrentLocation];
	}
	
	NSUInteger i, count = [self.mapAnnotations count];
	for (i = 0; i < count; i++) 
	{
		YCAnnotation *obj = [self.mapAnnotations objectAtIndex:i];
		MapBookmark *bm = [[MapBookmark alloc] init];
		bm.bookmarkName = obj.title;
		bm.annotation = obj;
		[self.mapBookmarksListController.bookmarksList addObject:bm];
	}

	[self.navigationController presentModalViewController:self.mapBookmarksListNavigationController animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
	//取消了，还没结束，结束它
	[self.forwardGeocoder cancel]; 
	//取消掉另一个调用
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(endForwardGeocoder) object:nil];	
}

#pragma mark -
#pragma mark MapBookmarksListControllerDelegete methods
- (void)mapBookmarksListController:(MapBookmarksListController *)controller didChooseMapBookmark:(MapBookmark *)aBookmark;
{

	[self.navigationController dismissModalViewControllerAnimated:YES];	
	
	if (aBookmark !=nil) 
	{
		[self.searchController setActive:NO animated:NO]; //如果是搜索状态，取消
		
		//仅仅设置中心
		[self.mapView setCenterCoordinate:aBookmark.annotation.coordinate animated:YES];
		
		//选中
		id annotationSelectingTemp = aBookmark.annotation;
		[self performSelector:@selector(selectAnnotation:) withObject:annotationSelectingTemp afterDelay:0.2];

	}
	
	
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) outletRelease{
	
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
	[notificationCenter removeObserver:self	name: kAlarmsDidChangeNotification object: nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[self outletRelease];
}


- (void)dealloc 
{
	//[mapView release];
	//mapView = nil;
	[self outletRelease];
	[self->locationTimer release];
	[self.forwardGeocoder release];
	[self.searchController release];
	[alarms release];   alarms = nil;                    
	[self.mapAnnotations release];        
	[alarmTemp release]; alarmTemp = nil;
	[alarmsTemp release];alarmsTemp = nil;
	[self.annotationAlarmEditing release];
	[self.locationingBarItem release];
	[self.annotationSearched release];
	[self.mapBookmarksListController release];
    [self.mapBookmarksListNavigationController release];
	
	/////////////////////////////////////
	//地址反转
	[self->reverseGeocoder release];
	[placemarkForReverse release];
	/////////////////////////////////////
	
	[super dealloc];
}




@end
 