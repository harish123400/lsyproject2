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


@implementation AlarmPositionMapViewController

@synthesize mapView;
@synthesize maskView;
@synthesize activityIndicator;
@synthesize isCenterWithcurrent;
@synthesize alarms;


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
	[[YCLog logSingleInstance] addlog:@"showMapView"];
	
	if (self->isAlreadyCenterCoord) 
	{
		
		[myTimer invalidate];
		[myTimer release];
		myTimer = nil;
		
		//关掉覆盖视图
		[self closeMaskViewWithAnimated:YES];
		//[NSThread sleepForTimeInterval:0.5];
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
		
	}

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	mapView.delegate = self;
	self->isFirstShow = YES;
	self->defaultMapRegion.span = [YCParam paramSingleInstance].defaultMapSpan;
	
	
	//不使用当前坐标作为中心
	if (!self.isCenterWithcurrent)
	{
		self->defaultMapRegion.center = self.alarm.coordinate;
		[self performSelector:@selector(cacheMapData) withObject:nil afterDelay:0.5];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
/*
	YCAnnotation *lastAnnotation = [[[YCAnnotation alloc] initWithCoordinate:alarm.coordinate addressDictionary:nil] autorelease];
	lastAnnotation.title = alarm.alarmName;
	lastAnnotation.subtitle = alarm.position;
	lastAnnotation.isCurrentLocation = FALSE;
	[mapView addAnnotation:lastAnnotation];
	[self.mapView addAnnotation:lastAnnotation];
 */
	
	NSTimeInterval ti = 0.2;
	myTimer = [[NSTimer timerWithTimeInterval:ti target:self selector:@selector(showMapView) userInfo:nil repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
	
}

-(void)viewWillAppear:(BOOL)animated
{
	if (!self.isCenterWithcurrent)
	{
		self->isAlreadyCenterCoord = YES;
	}else {
		if (self.mapView.userLocation.location)
		{
			//self->centerCoord = self.mapView.userLocation.location.coordinate;
			self->defaultMapRegion.center = self.mapView.userLocation.location.coordinate;
		}else {
			[[YCLog logSingleInstance] addlog:@"地图当前位置＝＝nil"];
		}

	}

	[self showMaskView];
}

-(void)viewDidDisappear:(BOOL)animated
{
	//self->currentMapRegion = self.mapView.region;
	//NSString *s = [NSString stringWithFormat:@"span:%.4f %.4f",self->currentSpan.latitudeDelta,self->currentSpan.longitudeDelta];
	//[[YCLog logSingleInstance] addlog:s];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/





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





- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	[[YCLog logSingleInstance] addlog:@"mapView:viewForAnnotation"];
	
	if ([annotation isKindOfClass: [MKUserLocation class]]) 
	{
		//使用当前坐标作为中心
		if (self.isCenterWithcurrent) 
		{
			self->defaultMapRegion.center = self.mapView.userLocation.location.coordinate;
			self->isAlreadyCenterCoord = YES;
			if (self->isFirstShow) [self cacheMapData];	//仅第一显示需要		
		}

		return nil;
	}
	 
	return nil;
	

		
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
