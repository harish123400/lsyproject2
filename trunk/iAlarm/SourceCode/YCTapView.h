//
//  YCMapView.h
//  TestSearchBar
//
//  Created by li shiyong on 10-12-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKMapView;
@interface YCTapView :UIView <UIGestureRecognizerDelegate>
{
	NSTimer *toolbarTimer;
	
	IBOutlet MKMapView *mapView;
	IBOutlet UIToolbar *toolbar;
	
	BOOL canHideToolBar;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, assign) BOOL canHideToolBar;

//开始隐藏倒计时
-(void)startToolbarTimeInterval:(NSTimeInterval)TimeInterval;

@end

