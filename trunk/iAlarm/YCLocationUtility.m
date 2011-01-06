//
//  YCLocationUtility.m
//  iAlarm
//
//  Created by li shiyong on 11-1-6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "YCDouble.h"
#import "YCLocationUtility.h"


@implementation YCLocationUtility

@end



//比较2个 CLLocationCoordinate2D；
//返回值:
//0：相等；非0值，不相等
int compareCLLocationCoordinate2D(CLLocationCoordinate2D src1,CLLocationCoordinate2D src2){
	int retVal = 1;
	if (0 == compareDouble(src1.latitude,src2.latitude)) {
		if (0 == compareDouble(src1.longitude,src2.longitude)) {
			retVal = 0;
		}
	}
	return retVal;
}