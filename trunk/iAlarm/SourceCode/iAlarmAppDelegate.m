//
//  iAlarmAppDelegate.m
//  iAlarm
//
//  Created by li shiyong on 10-11-1.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iAlarmAppDelegate.h"
#import "YCAlarmEntity.h"
#import "DataUtility.h"
#import "YCLocationManager.h"


@implementation iAlarmAppDelegate

@synthesize window;
@synthesize tabBarController;

-(void)resetMonitoredRegions
{
	
	YCLocationManager * ycLocationManager = [YCLocationManager locationManagerSigleInstance];
	[ycLocationManager removeAllRegionMonitored];
	NSArray *alarms = [DataUtility alarmArray];
	for (NSUInteger i =0; i<alarms.count; i++) {
		YCAlarmEntity *alarm = [alarms objectAtIndex:i];
		if (alarm.enabling) {
			CLRegion *region = [[[CLRegion alloc] initCircularRegionWithCenter:alarm.coordinate radius:alarm.radius identifier:alarm.alarmId] autorelease];
			[ycLocationManager startMonitoringForRegion:region desiredAccuracy:0.0];
		}
		
	}
	
	//重启一次
	[ycLocationManager restart];

}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	NSString *notificationName = [notification.userInfo objectForKey:@"name"];
	if (([notificationName isEqualToString:@"updateAlarm"]) ||
		([notificationName isEqualToString:@"updateParam"])) 
	{
		[self resetMonitoredRegions];
	}else if (notificationName !=nil){ //notificationName != nil 就一定是自定义的通知
		NSString *alertTitle = NSLocalizedString(@"时空闹钟",@"");
		NSString *alertMsg = notification.alertBody;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
														message:alertMsg 
													   delegate:self
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
	}
	
	/*
	 if([notificationName isEqualToString:@"didEnterRegion"])
	 {
	 NSString *alertTitle = NSLocalizedString(@"时空闹钟",@"");
	 NSString *alertMsg = notification.alertBody;
	 
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
	 message:alertMsg 
	 delegate:self
	 cancelButtonTitle:@"OK" 
	 otherButtonTitles:nil];
	 
	 [alert show];
	 [alert release];
	 }else if (([notificationName isEqualToString:@"didExitRegion"])) {
	 NSString *alertTitle = NSLocalizedString(@"时空闹钟",@"");
	 NSString *alertMsg = notification.alertBody;
	 
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
	 message:alertMsg 
	 delegate:self
	 cancelButtonTitle:@"OK" 
	 otherButtonTitles:nil];
	 
	 [alert show];
	 [alert release];
	 
	 }else if (([notificationName isEqualToString:@"updateAlarm"])) {
	 [self resetMonitoredRegions];
	 }
	 */
	
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the tab bar controller's view to the window and display.
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	YCLocationManager * ycLocationManager = [YCLocationManager locationManagerSigleInstance];
	[ycLocationManager start];
	[self resetMonitoredRegions];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

