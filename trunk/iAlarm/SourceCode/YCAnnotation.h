//
//  YCAnnotation.h
//  iArrived
//
//  Created by li shiyong on 10-10-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface YCAnnotation : MKPlacemark {
	BOOL isCurrentLocation; //当前位置
}

@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic,retain) NSString *title;
@property (nonatomic) BOOL isCurrentLocation;


@end
