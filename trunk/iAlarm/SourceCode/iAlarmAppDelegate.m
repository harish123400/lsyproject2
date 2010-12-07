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
#import "YCLog.h"
#import "UIUtility.h"
#import "AlarmPositionMapViewController.h"


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
	[[YCLog logSingleInstance] addlog:@"here is didReceiveLocalNotification"];
	
	NSString *notificationName = [notification.userInfo objectForKey:@"name"];
	if (([notificationName isEqualToString:@"updateAlarm"]) ||
		([notificationName isEqualToString:@"updateParam"])) 
	{
		[self resetMonitoredRegions];
		
	}else if(([notificationName isEqualToString:@"didEnterRegion"]) ||
			 ([notificationName isEqualToString:@"didExitRegion"]))
	{
		if(application.applicationState == UIApplicationStateInactive)
		{
			//转到当前位置tab
			[[YCLog logSingleInstance] addlog:@"here is UIApplicationStateInactive"];
		}else {
			//提示框
			[[YCLog logSingleInstance] addlog:@"here is not"];
			[UIUtility simpleAlertBody:notification.alertBody alertTitle:nil cancelButtonTitle:nil delegate:self];
		}

		
	}else if (notificationName !=nil){ 
		//notificationName != nil 就一定是自定义的通知
		/*
		NSString *alertTitle = NSLocalizedString(@"时空闹钟",@"");
		NSString *alertMsg = notification.alertBody;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
														message:alertMsg 
													   delegate:self
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		
		
		[alert show];
		[alert release];
		 */
		[[YCLog logSingleInstance] addlog:notificationName];
		[UIUtility simpleAlertBody:notification.alertBody alertTitle:nil cancelButtonTitle:nil delegate:self];

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
    
	[[YCLog logSingleInstance] addlog:@"here is didFinishLaunchingWithOptions"];
	
    // Override point for customization after application launch.

    // Add the tab bar controller's view to the window and display.
	tabBarController.delegate = self;
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	//tabBarController.selectedIndex = 3;
	
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
/*
BOOL lo;
-(void) loop
{
	lo = YES;
	while (lo) {
		[[YCLog logSingleInstance] addlog:@"loop"];
		[NSThread sleepForTimeInterval:1];
	}
}
 */

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
	
	/*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	[[YCLog logSingleInstance] addlog:@"here is applicationDidEnterBackground"];
	
	UIApplication*    app = [UIApplication sharedApplication];
	
    // Request permission to run in the background. Provide an
    // expiration handler in case the task runs long.
    NSAssert(bgTask == UIBackgroundTaskInvalid, nil);
	
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        // Synchronize the cleanup call on the main thread in case
        // the task actually finishes at around the same time.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
	
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
        // Do the work associated with the task.
		
		YCLocationManager * ycLocationManager = [YCLocationManager locationManagerSigleInstance];
		[ycLocationManager startTimer];
		
        // Synchronize the cleanup call on the main thread in case
        // the expiration handler is fired at the same time.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
	 
	 
	
	//YCLocationManager * ycLocationManager = [YCLocationManager locationManagerSigleInstance];
	//[ycLocationManager startTimer];
	
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	
	[[YCLog logSingleInstance] addlog:@"here is applicationWillEnterForeground"];
	
	YCLocationManager * ycLocationManager = [YCLocationManager locationManagerSigleInstance];
	[ycLocationManager stopTimer];
	
	UIApplication* app = [UIApplication sharedApplication];
	[app endBackgroundTask:bgTask];
	bgTask = UIBackgroundTaskInvalid;
	 
	 

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[[YCLog logSingleInstance] addlog:@"here is applicationDidBecomeActive"];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[[YCLog logSingleInstance] addlog:@"here is applicationWillTerminate"];
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

#pragma mark -
#pragma mark UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	/*
	if ([viewController isKindOfClass:[AlarmPositionMapViewController class]]) 
	{
		((AlarmPositionMapViewController*)viewController).alarms = [DataUtility alarmArray];
		((AlarmPositionMapViewController*)viewController).alarm = [DataUtility createAlarm];
		((AlarmPositionMapViewController*)viewController).regionCenterWithCurrentLocation = YES;
	}
	return YES;
	 */
	
	//NSLog(@"alarms's count = %d",[DataUtility alarmArray].count);
	
	if ([viewController isKindOfClass:[UINavigationController class]]) 
	{
		UIViewController *rootViewContoller = [((UINavigationController*)viewController).viewControllers objectAtIndex:0];
		if ([rootViewContoller isKindOfClass:[AlarmPositionMapViewController class]]) 
		{
			((AlarmPositionMapViewController*)rootViewContoller).alarms = [DataUtility alarmArray];
			//((AlarmPositionMapViewController*)rootViewContoller).alarm = [DataUtility createAlarm];
			//((AlarmPositionMapViewController*)rootViewContoller).alarm = [[DataUtility alarmArray] objectAtIndex:0];
			((AlarmPositionMapViewController*)rootViewContoller).regionCenterWithCurrentLocation = YES;
		}
		
	}
	return YES;
}


@end

