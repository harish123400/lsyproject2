//
//  UISearchUtility.m
//  TestSearchBar
//
//  Created by li shiyong on 10-11-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YCSearchController.h"
#import <QuartzCore/QuartzCore.h>


@implementation YCSearchController

@synthesize delegate;
@synthesize searchDisplayController;
@synthesize listContent;
@synthesize filteredListContent;
@synthesize searchMaskView;
@synthesize searchTableView;
@synthesize lastSearchString;
@synthesize originalPlaceholderString;

- (id) initWithDelegate:(id<YCSearchControllerDelegete>)theDelegate 
searchDisplayController:(UISearchDisplayController*) theSearchDisplayController
{
	if (self = [super init]) 
	{
		self.delegate = theDelegate;
		self.searchDisplayController = theSearchDisplayController;
		theSearchDisplayController.searchBar.delegate = self;
		theSearchDisplayController.delegate = self;
		theSearchDisplayController.searchResultsDataSource = self;
		theSearchDisplayController.searchResultsDelegate = self;
		
		self.originalPlaceholderString = theSearchDisplayController.searchBar.placeholder;
		self->originalSearchBarHidden = theSearchDisplayController.searchBar.hidden;
		
		self.listContent = [[NSMutableArray alloc] init];
		self.filteredListContent = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	[self.filteredListContent removeAllObjects];
    [self.listContent removeAllObjects];
}

- (void)dealloc
{

	[listContent release];
	[filteredListContent release];
	[searchMaskView release];
	[searchTableView release];
	
	[lastSearchString release];
	[originalPlaceholderString release];
	
	[super dealloc];
}

-(void)setSearchBar:(UISearchBar*)searchBar visible:(BOOL)visible animated:(BOOL)animated
{
	
	if (animated) 
	{
		CATransition *animation = [CATransition animation];  
		[animation setDelegate:self];  
		[animation setDuration:0.3f];
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; 
		[animation setType:kCATransitionPush];
		[animation setFillMode:kCAFillModeForwards];
		[animation setRemovedOnCompletion:YES]; 
		NSString *subtype = visible ? kCATransitionFromBottom:kCATransitionFromTop;
		[animation setSubtype:subtype];
		
		searchBar.hidden = !visible;  
		[[searchBar layer] addAnimation:animation forKey:@"showOrHideSearchBar"];
	}else {
		searchBar.hidden = !visible; 
	}

}


- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
	
	
	[self.searchDisplayController setActive:visible animated:animated];

	if (visible) 
	{
		[self.searchDisplayController.searchBar becomeFirstResponder];
		if (self->originalSearchBarHidden) //显示或隐藏searchBar
		{
			[self setSearchBar:self.searchDisplayController.searchBar visible:visible animated:NO]; 
			                                                   //animated:NO 
			                                                   //显示时候不用动画，maskView遮盖不了searchBar的背后区域
		}
	}else {
		[self.searchDisplayController.searchBar resignFirstResponder];
		if (self->originalSearchBarHidden) //显示或隐藏searchBar
		{
			[self setSearchBar:self.searchDisplayController.searchBar visible:visible animated:animated]; 
		}
	}

}


#pragma mark -
#pragma mark UITableView data source and delegate methods

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView canBecomeFirstResponder]
	return 40.0;
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	NSInteger n = 0;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        n = [self.filteredListContent count];
    }
	else
	{
        n = [self.listContent count];
    }
	
	
	if (n == 0) 
	{
		self.searchTableView.hidden = YES;
		if (self.searchDisplayController.searchContentsController.view != self.searchMaskView.superview)
			[self.searchDisplayController.searchContentsController.view addSubview:self.searchMaskView];

	}
	 

	
	return n;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:15];
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */

	NSString *product = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        product = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        product = [self.listContent objectAtIndex:indexPath.row];
    }
	
	cell.textLabel.text = product;
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
	/*
	 If the requesting table view is the search display controller's table view, configure the next view controller using the filtered content, otherwise use the main list.
	 */
	NSString *searchString = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        searchString = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        searchString = [self.listContent objectAtIndex:indexPath.row];
    }
	
	//结束搜索状态
	[self.searchDisplayController setActive:NO animated:YES];
	
	//执行搜索
	[self.delegate searchController:self searchString:searchString];

}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSString *product in listContent)
	{
		NSComparisonResult result = [product compare:searchText 
											 options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) 
											   range:NSMakeRange(0, [searchText length])];
		if (result == NSOrderedSame)
		{
			[self.filteredListContent addObject:product];
		}
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate Delegate Methods

- (void)addListContentWithString:(NSString*)string
{
	
	BOOL result = NO;
	for (NSString *product in listContent)
	{
		if (result = [product isEqualToString:string])
		{
			break;
		}
	}
	if (!result) 
	{
		[self.listContent addObject:string];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *searchString = [self.searchDisplayController.searchBar.text copy]; 
	                                 //结束搜索状态,改变searchBar.text,所以copy

	//结束搜索状态
	[self.searchDisplayController setActive:NO animated:YES];
	

	//加数据到
	[self addListContentWithString:searchString];
	//[self performSelector:@selector(addListContentWithString:) withObject:searchString afterDelay:0.5];

	
	//执行搜索
	[self.delegate searchController:self searchString:searchString];
	[searchString release];
	
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/////////////////////////////////////
//退出搜索时候，保持最后搜索字符串在 bar上
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
	self.lastSearchString = controller.searchBar.text;
	if (self.lastSearchString !=nil && [self.lastSearchString length] >0) 
	{
		controller.searchBar.placeholder = lastSearchString;
	}
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
	controller.searchBar.text = self.lastSearchString;
	controller.searchBar.placeholder = self.originalPlaceholderString;
	
	if (self->originalSearchBarHidden) //显示或隐藏searchBar
	{
		[self setSearchBar:self.searchDisplayController.searchBar visible:NO animated:YES];
	}
}
//退出搜索时候，保持最后搜索字符串在 bar上
/////////////////////////////////////


/////////////////////////////////////
//没有提示数据时候，隐藏搜索结果tableview
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
	NSArray *array= self.searchDisplayController.searchContentsController.view.subviews;
	self.searchMaskView = [array objectAtIndex:array.count-1];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
	self.searchTableView = tableView;
	if (!self.searchDisplayController.active)
	{
		tableView.hidden = YES ;
		//[self.searbarMaskView removeFromSuperview];
		NSLog(@"11");
	}else {
		if (self.filteredListContent.count !=0 ) 
		{
			tableView.hidden = NO ;
			//[self.searchMaskView removeFromSuperview];
			NSLog(@"22");
		}else {
			tableView.hidden = YES;
			if (self.searchDisplayController.searchContentsController.view != self.searchMaskView.superview)
				[self.searchDisplayController.searchContentsController.view addSubview:self.searchMaskView];
			NSLog(@"33");
		}
	}

}
//没有提示数据时候，隐藏搜索结果view
/////////////////////////////////////




@end
