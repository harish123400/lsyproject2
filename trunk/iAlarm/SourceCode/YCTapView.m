//
//  YCMapView.m
//  TestSearchBar
//
//  Created by li shiyong on 10-12-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCTapView.h"
#import <MapKit/MapKit.h>


@implementation YCTapView

@synthesize mapView;


#pragma mark -
#pragma mark === Setting up and tearing down ===
#pragma mark

// adds a set of gesture recognizers to one of our piece subviews
- (void)addGestureRecognizersToPiece:(UIView *)piece
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [piece addGestureRecognizer:tapGesture];
    [tapGesture release];
    
}

- (void)awakeFromNib
{
    [self addGestureRecognizersToPiece:self.mapView];
}



#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)tapView:(UITapGestureRecognizer *)gestureRecognizer
{
	NSLog(@"tapPiece");
	
	UIView *view = [gestureRecognizer view];
	CGPoint tapLocation = [gestureRecognizer locationInView:view];
	CGRect viewFrame = view.frame;
	
	if ((viewFrame.size.height -tapLocation.y) *5 < viewFrame.size.height)
	{
		NSLog(@"tapPiece in target");
	}
	
}




@end
