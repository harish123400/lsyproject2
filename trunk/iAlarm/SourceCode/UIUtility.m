//
//  UIUtility.m
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIUtility.h"
#import <QuartzCore/QuartzCore.h>



@implementation UIUtility

+(void) navigationController:(UINavigationController*) navigationController 
			  viewController:(UIViewController*) viewController
					  isPush:(BOOL) isPush
		durationForAnimation:(CFTimeInterval)duration
		   TransitionForType:(NSString*)type
		TransitionForSubtype:(NSString*)subtype
{
	CATransition *transition = [CATransition animation];
	transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; 
	transition.type = type; 
    transition.subtype = subtype;
	

    [navigationController.view.layer addAnimation:transition forKey:nil];
	navigationController.navigationBarHidden = NO; 
	
	if (isPush) {
		[navigationController pushViewController:viewController animated:NO];
	}else{
		[navigationController popViewControllerAnimated:NO];
	}
	
}


static void addRoundedRectToPath(CGContextRef context, 
                                 CGRect rect, 
                                 float ovalWidth,
                                 float ovalHeight) {
    
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
#pragma mark change the corner size below...
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


+ (UIImage *) roundCorners: (UIImage*) img
{
    int w = img.size.width;
    int h = img.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    addRoundedRectToPath(context, rect, 5, 5);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    [img release];
    
    return [UIImage imageWithCGImage:imageMasked];
}


/* 
 static void addRoundedRectToPath(CGContextRef context, 
 CGRect rect, 
 float ovalWidth,
 float ovalHeight) {
 
 float fw, fh;
 if (ovalWidth == 0 || ovalHeight == 0) {
 CGContextAddRect(context, rect);
 return;
 }
 
 CGContextSaveGState(context);
 CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
 CGContextScaleCTM(context, ovalWidth, ovalHeight);
 fw = CGRectGetWidth(rect) / ovalWidth;
 fh = CGRectGetHeight(rect) / ovalHeight;
 
 CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
 #pragma mark change the corner size below...
 CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
 CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
 CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
 CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
 
 CGContextClosePath(context);
 CGContextRestoreGState(context);
 }
 
 
 + (id) createRoundedRectImage:(UIImage*)image size:(CGSize)size {
 // the size of CGContextRef
 int w = size.width;
 int h = size.height;
 
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
 CGRect rect = CGRectMake(0, 0, w, h);
 
 CGContextBeginPath(context);
 addRoundedRectToPath(context, rect, 10, 10);
 CGContextClosePath(context);
 CGContextClip(context);
 CGContextDrawImage(context, CGRectMake(0, 0, w, h), image.CGImage);
 CGImageRef imageMasked = CGBitmapContextCreateImage(context);
 CGContextRelease(context);
 CGColorSpaceRelease(colorSpace);
 return [UIImage imageWithCGImage:imageMasked];
 }
 */

void MyDrawWithShadows (CGContextRef myContext, // 1
						float wd, float ht)
{
    CGSize          myShadowOffset = CGSizeMake (-15,  20);// 2
    float           myColorValues[] = {1, 0, 0, .6};// 3
    CGColorRef      myColor;// 4
    CGColorSpaceRef myColorSpace;// 5
	
    CGContextSaveGState(myContext);// 6
	
    CGContextSetShadow (myContext, myShadowOffset, 5); // 7
    // Your drawing code here// 8
    CGContextSetRGBFillColor (myContext, 0, 1, 0, 1);
    CGContextFillRect (myContext, CGRectMake (wd/3 + 75, ht/2 , wd/4, ht/4));
	
    myColorSpace = CGColorSpaceCreateDeviceRGB ();// 9
    myColor = CGColorCreate (myColorSpace, myColorValues);// 10
    CGContextSetShadowWithColor (myContext, myShadowOffset, 5, myColor);// 11
    // Your drawing code here// 12
    CGContextSetRGBFillColor (myContext, 0, 0, 1, 1);
    CGContextFillRect (myContext, CGRectMake (wd/3-75,ht/2-100,wd/4,ht/4));
	
    CGColorRelease (myColor);// 13
    CGColorSpaceRelease (myColorSpace); // 14
	
    CGContextRestoreGState(myContext);// 15
}

+(UIColor*)defaultCellDetailTextColor
{
	UIColor* defaultDetailTextColor = nil;
	if (defaultDetailTextColor ==nil) {
		CGColorRef color = CreateDeviceRGBColor(0.22,0.33,0.53,1);
		defaultDetailTextColor = [[[UIColor alloc] initWithCGColor:color] autorelease];
	}
	return defaultDetailTextColor;
}

+(UIColor*)defaultCellTextColor
{
	UIColor* defaultTextColor = nil;
	if (defaultTextColor ==nil) {
		CGColorRef color = CreateDeviceGrayColor(0.0,1.0);
		defaultTextColor = [[[UIColor alloc] initWithCGColor:color] autorelease];
	}
	return defaultTextColor;
}

+(UIColor*)checkedCellTextColor
{
	UIColor* checkedTextColor = nil;
	if (checkedTextColor ==nil) {
		CGColorRef color = CreateDeviceRGBColor(0.22,0.33,0.53,1);
		checkedTextColor = [[[UIColor alloc] initWithCGColor:color] autorelease];
	}
	return checkedTextColor;
}
//发送闹钟已经更新消息
+(void)sendAlarmUpdateNotification
{
	UIApplication *app = [UIApplication sharedApplication];
	
	
	// Create a new notification
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.repeatInterval = 0;
	notification.soundName = @"ping.caf";//@"default";
	notification.alertBody = @"闹钟数据更新";
	notification.userInfo = [NSDictionary dictionaryWithObject:@"updateAlarm"forKey:@"name"];
	
	
	[app scheduleLocalNotification:notification];
	[notification release];
}



//转换经纬度
+(NSString*)convertgen:(double)latitude decimal:(NSUInteger)decimal name:(NSString*)name
{
	double lTemp =  fabs(latitude);
	
	NSInteger a= (NSInteger)lTemp;
	double af = lTemp - a;
	
	NSInteger b= (NSInteger)(af*60);
	double bf = af * 60 -b;
	
	NSInteger c= (NSInteger)(bf*60);
	NSInteger cf = (NSInteger)((bf*60 - c) * pow(10,decimal)) ;
	
	
	NSString *s = nil;
	NSString *f = nil;
	if (decimal >0) 
		f = [name stringByAppendingString:@" %d°%d′%d.%d″"];
	else 
		f = [name stringByAppendingString:@" %d°%d′%d″"];;
	
	s = [[[NSString alloc] initWithFormat:f,a,b,c,cf] autorelease];
	return s;
}

+(NSString*)convertLatitude:(double)latitude decimal:(NSUInteger)decimal
{
	NSString *name = nil;
	if (latitude>0) 
		name = NSLocalizedString(@"北纬",@"");
	else 
		name = NSLocalizedString(@"南纬",@"");
	
	return [UIUtility convertgen:latitude decimal:decimal name:name];
}
+(NSString*)convertLongitude:(double)longitude decimal:(NSUInteger)decimal
{
	NSString *name = nil;
	if (longitude>0) 
		name = NSLocalizedString(@"东经",@"");
	else 
		name = NSLocalizedString(@"西经",@"");
	return [UIUtility convertgen:longitude decimal:decimal name:name];
}

//发送个简单的通知 弹出警告筐－－debug
+(void)sendSimpleNotifyForAlart:(NSString*)alartBody
{
	// Create a new notification
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.repeatInterval = 0;
	//notification.soundName = @"ping.caf";//@"default";
	notification.alertBody = alartBody;
	notification.userInfo = [NSDictionary dictionaryWithObject:@"sendSimpleNotifyForAlart"forKey:@"name"];
	
	UIApplication *app = [UIApplication sharedApplication];
	[app scheduleLocalNotification:notification];
	[notification release];
}

+(void)sendNotifyForAlart:(NSString*)alartBody alartName:(NSString*)alartName
{
	// Create a new notification
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
	notification.timeZone = [NSTimeZone defaultTimeZone];
	notification.repeatInterval = 0;
	//notification.soundName = @"ping.caf";//@"default";
	notification.alertBody = alartBody;
	notification.userInfo = [NSDictionary dictionaryWithObject:alartName forKey:@"name"];
	
	UIApplication *app = [UIApplication sharedApplication];
	[app scheduleLocalNotification:notification];
	[notification release];
}

@end


CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a)
{
	CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
	CGFloat comps[] = {w, a};
	CGColorRef color = CGColorCreate(gray, comps);
	CGColorSpaceRelease(gray);
	return color;
}

CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat comps[] = {r, g, b, a};
	CGColorRef color = CGColorCreate(rgb, comps);
	CGColorSpaceRelease(rgb);
	return color;
}
