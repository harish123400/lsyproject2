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
    YCMapAnnotationTypeLocating,            //正在定位的
    YCMapAnnotationTypeMovingTarget         //接近的目标位置
};
typedef NSUInteger YCMapAnnotationType;

@interface YCAnnotation : MKPlacemark {
	BOOL isCurrentLocation; //当前位置
	
	YCMapAnnotationType annotationType;
}
@property (nonatomic, readwrite,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic,retain) NSString *title;

@property (nonatomic) BOOL isCurrentLocation;
@property (nonatomic) YCMapAnnotationType annotationType;


@end
