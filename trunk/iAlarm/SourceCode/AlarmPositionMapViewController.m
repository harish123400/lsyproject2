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


@implementation AlarmPositionMapViewController

@synthesize mapView;

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
	

	
}

-(void)viewDidAppear:(BOOL)animated
{

	mapView.delegate = self;
	
	//CLLocationCoordinate2D tmp = {41.7723,123.3865};
	//CLLocationCoordinate2D tmp = {41.774689,123.392563};
	//alarm.coordinate = tmp;
	YCAnnotation *lastAnnotation = [[[YCAnnotation alloc] initWithCoordinate:alarm.coordinate addressDictionary:nil] autorelease];
	lastAnnotation.title = alarm.alarmName;
	lastAnnotation.subtitle = alarm.position;
	lastAnnotation.isCurrentLocation = FALSE;
	[mapView addAnnotation:lastAnnotation];
	[self.mapView addAnnotation:lastAnnotation];
	
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	for (NSUInteger i=0; i<views.count; i++) {
		id viewo = [views objectAtIndex:i];
		if ([viewo isKindOfClass: [MKUserLocation class]]) {
			//设置比例尺
			MKCoordinateSpan span = {0.02,0.02};
			MKCoordinateRegion region;
			region.span = span;
			
			
			
			region.center = self.mapView.userLocation.coordinate;
			[self.mapView setRegion:region animated:YES];
			
			//设置当前位置为屏幕中心
			CLLocation *location1 = self.mapView.userLocation.location;
			[self.mapView setCenterCoordinate:location1.coordinate animated:YES];
			NSLog(@"map1 : latitude %+.6f, longitude %+.6f horizontalAccuracy %+.6f\n",
				  location1.coordinate.latitude,
				  location1.coordinate.longitude,
				  location1.horizontalAccuracy);
		}
		
	}
	
}
 

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	//static NSString * kMyFirstId = @"kMyFirstId";
	//MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	//[mapView dequeueReusableAnnotationViewWithIdentifier:kMyFirstId];
	//[mapView dequeueReusableAnnotationViewWithIdentifier:kMyFirstId];
	
	//MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	/*
	if ([annotation isKindOfClass:[MKUserLocation class]])
	{

		return nil;
        
	}
	 */
	
	if ([annotation isKindOfClass: [MKUserLocation class]]) {
		//设置比例尺
		MKCoordinateSpan span = {0.02,0.02};
		MKCoordinateRegion region;
		region.span = span;
		
		
		
		region.center = self.mapView.userLocation.coordinate;
		[self.mapView setRegion:region animated:YES];
		
		//设置当前位置为屏幕中心
		CLLocation *location1 = self.mapView.userLocation.location;
		[self.mapView setCenterCoordinate:location1.coordinate animated:YES];
		NSLog(@"map : latitude %+.6f, longitude %+.6f horizontalAccuracy %+.6f\n",
			  location1.coordinate.latitude,
			  location1.coordinate.longitude,
			  location1.horizontalAccuracy);
		NSLog(@"map1 : latitude %@, longitude %@ horizontalAccuracy %+.6f howRecent %f\n",
			  [UIUtility convertLatitude:location1.coordinate.latitude decimal:3],
			  [UIUtility convertLatitude:location1.coordinate.longitude decimal:3],
			  location1.horizontalAccuracy
			  );
	}
	
	return nil;
	
	
	
	/*
	MKPinAnnotationView* pinView;
	
	pinView =  (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kMyFirstId];
	
	
	if (!pinView) {
		pinView = (MKPinAnnotationView *)[[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMyFirstId];
		pinView.pinColor = MKPinAnnotationColorRed;
		
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
		pinView.draggable = TRUE;
		
	}else {
		pinView.annotation = annotation;
		
	}
	 
	
	
	return pinView;
	 */
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
