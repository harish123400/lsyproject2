//
//  YCCellDescription.h
//  iArrived
//
//  Created by li shiyong on 10-10-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//////////TableCell的Type//////////
//默认 >
#define kDefaultCellType        0  
//switch
#define kBoolCellType           1
//√
#define kCheckCellType          2
//√ >
#define kCheckAndIndCellType    3
//none
#define kNoneCellType           4
//////////TableCell的Type//////////


//////////TableCell的tag//////////
#define kDebugCoorCellTag        99
#define kCurrentPositionCellTag  100
#define kPositionCellIndTag      101
#define kPositionCellTag         102
//////////TableCell的tag//////////

//////////TableCell的业务种类//////////
#define kDesCellEnabling           11       
#define kDesCellAlarmTypeL          1     
#define kDesCellAlarmTypeT          2 
#define kDesCellCurrentLoc          3
#define kDesCellMapLoc              4
#define kDesCellRepeat              5
#define kDesCellRing                6
#define kDesCellVibrate             7
#define kDesCellAlarmName           8
#define kDesCellDebugCoordinate     9
#define kDesCellPosition           10
#define kDesCellPositionEdit       12
//////////TableCell的业务种类//////////

@class YCAlarmEntity;
@interface YCCellDescription : NSObject {
	
	NSString *image;
	NSString *text;
	NSString *detailText;
	id navActionTarget;
	NSUInteger cellType;
	id typeData;//非默认类型的附加数据
	NSUInteger ctlTag; //附加控件的tag 或Cell的tag
	SEL ctlAction;     //附加控件的Action
	NSUInteger cellBusinessType; //TableCell的业务种类
	
	UIColor *textColor;      
	UIColor *detailTextColor;
	UIFont *textFont;
	UIFont *detailTextFont;
	
}

@property (nonatomic,retain)  NSString *image;
@property (nonatomic,retain)  NSString *text;
@property (nonatomic,retain)  NSString *detailText;
@property (nonatomic,retain)  id navActionTarget;
@property (nonatomic,assign)  NSUInteger cellType;
@property (nonatomic,assign)  id typeData;
@property (nonatomic,assign) NSUInteger ctlTag;
@property (nonatomic,assign) SEL ctlAction;
@property (nonatomic,assign) NSUInteger cellBusinessType;

@property (nonatomic,retain)  UIColor *textColor;
@property (nonatomic,retain)  UIColor *detailTextColor;
@property (nonatomic,retain)  UIFont *textFont;
@property (nonatomic,retain)  UIFont *detailTextFont;


//-(id)initWithData:(NSString *)image text:(NSString *) text detailText:(NSString *)detailText actionTarget:(id)actionTarget;



//产生cell描述数组
+(NSArray*) makeCellDescriptions:(NSArray *)desIds alarm:(YCAlarmEntity*)alarm;

@end
