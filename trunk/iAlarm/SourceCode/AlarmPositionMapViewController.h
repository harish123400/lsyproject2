//
//  AlarmPositionMapViewController.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlarmModifyViewController.h"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



@interface AlarmPositionMapViewController : AlarmModifyViewController 
<MKMapViewDelegate,CLLocationManagerDelegate>
{
	MKMapView* mapView;
}

@property (nonatomic,retain) IBOutlet MKMapView* mapView;

@end
