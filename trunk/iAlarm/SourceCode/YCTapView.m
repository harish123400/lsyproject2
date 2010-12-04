//
//  YCMapView.m
//  TestSearchBar
//
//  Created by li shiyong on 10-12-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCTapView.h"
#import "UIUtility.h"
#import <MapKit/MapKit.h>

#define kShowToolbar @"kShowToolbar"

@implementation YCTapView

@synthesize mapView;
@synthesize toolbar;
@synthesize canHideToolBar;

-(void)startToolbarTimeInterval:(NSTimeInterval)TimeInterval
{
	[toolbarTimer invalidate];
	[toolbarTimer release];
	toolbarTimer = nil;
	
	if (!self.toolbar.hidden)
	{
		toolbarTimer = [[NSTimer timerWithTimeInterval:TimeInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:NO] retain];
		[[NSRunLoop currentRunLoop] addTimer:toolbarTimer forMode:NSDefaultRunLoopMode];
	}
}


- (void)dealloc
{
	self.toolbar = nil;
	self.mapView = nil;
	[self->toolbarTimer release];

	//[[NSNotificationCenter defaultCenter] removeObserver:self name:kShowToolbar object:nil];
	[super dealloc];
}

- (void)setToolbarVisible:(BOOL)visible
{
	[toolbarTimer invalidate];
	[toolbarTimer release];
	toolbarTimer = nil;
	
	if (!self.canHideToolBar)
	{
		if (self.toolbar.hidden)
			[UIUtility setBar:self.toolbar topBar:NO visible:YES animated:YES animateDuration:0.5 animateName:@"showOrHideToolbar"];

		return;
	}
		
	[UIUtility setBar:self.toolbar topBar:NO visible:visible animated:YES animateDuration:0.5 animateName:@"showOrHideToolbar"];
	
	if (visible)
	{
		toolbarTimer = [[NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO] retain];
		[[NSRunLoop currentRunLoop] addTimer:toolbarTimer forMode:NSDefaultRunLoopMode];
	}
		
	
}

- (void)setToolbarNotif:(NSNotification *)aNotification
{
	[toolbarTimer invalidate];
	[toolbarTimer release];
	toolbarTimer = nil;
	[self setToolbarVisible: (!self.toolbar.hidden)];
}

- (void)timerFired:(NSTimer *)timer
{
	[toolbarTimer invalidate];
	[toolbarTimer release];
	toolbarTimer = nil;
	
	// time has passed, hide the HoverView
	[self setToolbarVisible: NO];
}

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
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setToolbarNotif:) name:kShowToolbar object:nil];
}



#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)tapView:(UITapGestureRecognizer *)gestureRecognizer
{

	UIView *view = [gestureRecognizer view];
	CGPoint tapLocation = [gestureRecognizer locationInView:view];
	CGRect viewFrame = view.frame;
	
	if ((viewFrame.size.height -tapLocation.y) *5 < viewFrame.size.height)
	{
		if (self.toolbar.hidden) 
		{
			[self setToolbarVisible:YES];
		}
		
	}else {
		//点其他位置隐藏
		if (!self.toolbar.hidden) 
		{
			[self setToolbarVisible:NO];
			return;
		}
	}

	

	
}




@end
