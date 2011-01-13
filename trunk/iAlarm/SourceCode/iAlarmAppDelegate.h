//
//  iAlarmAppDelegate.h
//  iAlarm
//
//  Created by li shiyong on 10-11-1.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iAlarmAppDelegate : NSObject 
<UIApplicationDelegate, UITabBarControllerDelegate> 
{
    UIWindow *window;
    UITabBarController *tabBarController;
	UIBackgroundTaskIdentifier	bgTask;
	
	//////////////////////////////////
	//tabBarItem title
	IBOutlet UITabBarItem *iAlarmTabBarItem;
	IBOutlet UITabBarItem *mapsTabBarItem;
	IBOutlet UITabBarItem *settingTabBarItem;
	IBOutlet UITabBarItem *aboutTabBarItem;
	//////////////////////////////////
}

@property (nonatomic,retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) IBOutlet UITabBarController *tabBarController;

//////////////////////////////////
//tabBarItem title
@property (nonatomic,retain) IBOutlet UITabBarItem *iAlarmTabBarItem;
@property (nonatomic,retain) IBOutlet UITabBarItem *mapsTabBarItem;
@property (nonatomic,retain) IBOutlet UITabBarItem *settingTabBarItem;
@property (nonatomic,retain) IBOutlet UITabBarItem *aboutTabBarItem;
//////////////////////////////////


@end
