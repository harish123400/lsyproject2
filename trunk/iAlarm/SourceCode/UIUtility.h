//
//  UIUtility.h
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface UIUtility : NSObject {
	
}

//UINavigationController 的动画转换效果
+(void) navigationController:(UINavigationController*) navigationController 
			  viewController:(UIViewController*) viewController
					  isPush:(BOOL) isPush
		durationForAnimation:(CFTimeInterval)duration
		   TransitionForType:(NSString*)type
		TransitionForSubtype:(NSString*)subtype;

//把图片切成圆角
+ (UIImage *) roundCorners: (UIImage*) img;
//默认cell的text颜色
+(UIColor*)defaultCellDetailTextColor;
//默认cell的detailtext颜色
+(UIColor*)defaultCellTextColor;
//选中的cell的text颜色
+(UIColor*)checkedCellTextColor;
//发送闹钟已经更新消息
+(void)sendAlarmUpdateNotification;

//转换经纬度
+(NSString*)convertLatitude:(double)latitude   decimal:(NSUInteger)decimal;
+(NSString*)convertLongitude:(double)longitude decimal:(NSUInteger)decimal;

//发送个简单的通知 －－debug
+(void)sendSimpleNotifyForAlart:(NSString*)alartBody;
+(void)sendNotifyForAlart:(NSString*)alartBody alartName:(NSString*)alartName;
@end


CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);
CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);