//
//  YCLocationUtility.h
//  iAlarm
//
//  Created by li shiyong on 11-1-6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface YCLocationUtility : NSObject {

}

@end
 

//比较2个 CLLocationCoordinate2D；
//返回值:
//0：相等；非0值，不相等
int compareCLLocationCoordinate2D(CLLocationCoordinate2D src1,CLLocationCoordinate2D src2);

//比较2个 CGPoint；
//返回值:
//0：相等；非0值，不相等
int compareCGPoint(CGPoint src1,CGPoint src2);