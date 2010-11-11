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
@synthesize centerWithcurrent;
@synthesize alarms;
@synthesize centerCoord;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	mapView.delegate = self;
	
	//不使用当前坐标作为中心
	if (!self.centerWithcurrent)
	{
		[self performSelector:@selector(showMapByDefaultSpanAndCenter) withObject:nil afterDelay:0.5];
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
	
	//关掉覆盖视图
	[UIView beginAnimations:@"Unmask" context:NULL];
	[UIView setAnimationDuration:1.25];
	self.maskView.alpha = 0.0f;
	[UIView commitAnimations];
	[self.activityIndicator stopAnimating];
	
	//设置当前位置为屏幕中心
	[self.mapView setCenterCoordinate:self->centerCoord animated:YES];

}

-(void)viewWillAppear:(BOOL)animated
{
	//打开覆盖视图
	self.maskView.alpha = 1.0f;
	[self.activityIndicator startAnimating];
	
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

//设置地图的显示比例及中心点
- (void) setMapRegionWithSpan:(MKCoordinateSpan)span 
				   coordinate:(CLLocationCoordinate2D)coordinate 
					 animated:(BOOL)animated
{
	MKCoordinateRegion region;
	region.span = span;
	region.center = coordinate;
	[self.mapView setRegion:region animated:animated];
}

//使用默认的span和中心坐标，来显示地图
- (void) showMapByDefaultSpanAndCenter
{
	[[YCLog logSingleInstance] addlog:@"showMapByDefaultSpanAndCurLocation"];
	
	//先缩小取得地图数据
	[self setMapRegionWithSpan:[YCParam paramSingleInstance].defaultMapSpan 
					coordinate:self->centerCoord
					  animated:NO];
	
	//放大
	MKCoordinateSpan tmp = {10.0,10.0};
	[self setMapRegionWithSpan:tmp 
					coordinate:self->centerCoord
					  animated:NO];
	
	//关掉覆盖视图
	[UIView beginAnimations:@"Unmask" context:NULL];
	[UIView setAnimationDuration:1.25];
	self.maskView.alpha = 0.0f;
	[UIView commitAnimations];
	[self.activityIndicator stopAnimating];
	
	
	//动画缩小到当前位置
	[self setMapRegionWithSpan:[YCParam paramSingleInstance].defaultMapSpan 
					coordinate:self->centerCoord
					  animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	[[YCLog logSingleInstance] addlog:@"mapView:viewForAnnotation"];
	
	if ([annotation isKindOfClass: [MKUserLocation class]]) 
	{
		//使用当前坐标作为中心
		if (self.centerWithcurrent) 
		{
			self->centerCoord = self.mapView.userLocation.location.coordinate;
			[self showMapByDefaultSpanAndCenter];
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
