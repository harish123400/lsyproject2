//
//  YCAnnotation.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


enum {
    YCMapAnnotationTypeStandard = 0,        //已经定位的普通类型
	YCMapAnnotationTypeStandardEnabledDrag, //已经定位的普通类型，但可以拖动
    YCMapAnnotationTypeLocating,            //正在定位的
    YCMapAnnotationTypeMovingToTarget         //接近的目标位置
};
typedef NSUInteger YCMapAnnotationType;

@interface YCAnnotation : MKPlacemark {
	BOOL isCurrent; //当前
	
	YCMapAnnotationType annotationType;
}
@property (nonatomic, readwrite,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic,retain) NSString *title;

@property (nonatomic) BOOL isCurrent;
@property (nonatomic) YCMapAnnotationType annotationType;


@end
