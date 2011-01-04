//
//  YCMapView.m
//  TestSearchBar
//
//  Created by li shiyong on 10-12-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapNotification.h"
#import "YCTapView.h"
#import "UIUtility.h"
#import <MapKit/MapKit.h>

#define kTimeIntervalForHideToolbar    5.0
#define kTimeIntervalForHideSearchBar 15.0

@implementation YCTapView

@synthesize mapView;
@synthesize toolbar;
@synthesize canHideToolBar;
@synthesize searchBar;
@synthesize canHideSearchBar;

-(void)hideToolbar{
	if (!self.toolbar.hidden)
	{
		if (self.canHideToolBar)
		{
			[UIUtility setBar:self.toolbar topBar:NO visible:NO animated:YES animateDuration:0.5 animateName:@"showOrHideToolbar"];
		}
	}
}

-(void)showToolbar{
	if (self.toolbar.hidden)
	{
		[UIUtility setBar:self.toolbar topBar:NO visible:YES animated:YES animateDuration:0.5 animateName:@"showOrHideToolbar"];
	}
}

-(void)startHideToolbarAfterTimeInterval:(NSTimeInterval)TimeInterval
{
	[self performSelector:@selector(hideToolbar) withObject:nil afterDelay:TimeInterval];
}

-(void)resetTimeIntervalForHideToolbar:(NSTimeInterval)TimeInterval
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolbar) object:nil];
	[self performSelector:@selector(hideToolbar) withObject:nil afterDelay:TimeInterval];
}


-(void)hideSearchBar{
	if (!self.searchBar.hidden)
	{
		if ([self.searchBar canResignFirstResponder] && self.canHideSearchBar) 
		{//canResignFirstResponder:搜索后；canHideSearchBar:不在tab上
			[UIUtility setBar:self.searchBar topBar:YES visible:NO animated:YES animateDuration:0.5 animateName:@"showOrHideToolbar"];
		}else { //递归
			[self performSelector:@selector(hideSearchBar) withObject:nil afterDelay:kTimeIntervalForHideSearchBar];
		}
	}
}

-(void)showSearchBar{
	if (self.searchBar.hidden)
	{
		[UIUtility setBar:self.searchBar topBar:YES visible:YES animated:YES animateDuration:0.5 animateName:@"showOrHideToolbar"];
	}
}


-(void)startHideSearchBarAfterTimeInterval:(NSTimeInterval)TimeInterval{

	[self performSelector:@selector(hideSearchBar) withObject:nil afterDelay:TimeInterval];
}

-(void)resetTimeIntervalForHideSearchBar:(NSTimeInterval)TimeInterval{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSearchBar) object:nil];
	[self performSelector:@selector(hideSearchBar) withObject:nil afterDelay:TimeInterval];
}




- (void)dealloc
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:kSearchBarBecomeFirstResponderNotification object:nil];

	[self.toolbar release];
	self.toolbar = nil;
	
	[self.searchBar release];
	self.searchBar = nil;
	
	[self.mapView release];
	self.mapView = nil;
		
	[super dealloc];
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

- (void) handle_SearchBarBecomeFirstResponder: (id) notification {
	if (self.searchBar.hidden) {
		self.searchBar.hidden = NO;
		[self startHideSearchBarAfterTimeInterval:kTimeIntervalForHideSearchBar];
	}
}

- (void)awakeFromNib
{
    [self addGestureRecognizersToPiece:self.mapView];
	
	//searchBar 获得焦点
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver: self
						   selector: @selector (handle_SearchBarBecomeFirstResponder:)
							   name: kSearchBarBecomeFirstResponderNotification
							 object: nil];
}



#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)tapView:(UITapGestureRecognizer *)gestureRecognizer
{

	UIView *view = [gestureRecognizer view];
	CGPoint tapLocation = [gestureRecognizer locationInView:view];
	CGRect viewFrame = view.frame;
	
	//下部tap，--toolbar
	if ((viewFrame.size.height -tapLocation.y) *5 < viewFrame.size.height)
	{
		if (self.toolbar.hidden) 
		{
			[self showToolbar];
			[self resetTimeIntervalForHideToolbar:kTimeIntervalForHideToolbar];
		}
		
	}else {
		//点其他位置隐藏
		if (!self.toolbar.hidden) 
		{
			[self hideToolbar];
		}
	}

	
	//上部tap，--searchBar
	if (tapLocation.y *5 < viewFrame.size.height)
	{
		if (self.searchBar.hidden) 
		{
			[self showSearchBar];
			[self resetTimeIntervalForHideSearchBar:kTimeIntervalForHideSearchBar];
		}
		
	} else {
		//点其他位置隐藏
		if (!self.searchBar.hidden) 
		{
			[self hideSearchBar];
		}
	}
	
}




@end
