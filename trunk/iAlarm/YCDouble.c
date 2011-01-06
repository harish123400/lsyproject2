/*
 *  YCDouble.c
 *  iAlarm
 *
 *  Created by li shiyong on 11-1-6.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "YCDouble.h"

#define kLittleDouble  0.00000000001
//比较2个浮点数；
//返回值:
//0：相等；1：src1>src2; -1:src1<src2
int compareDouble(double src1,double src2){
	double d = src1 - src2;
	
	int retVal = 0;
	if (d < kLittleDouble) retVal = 0;
	if (d > kLittleDouble) retVal = 1;
	if (d < 0) retVal =  -1;
	
	return retVal;
	
}