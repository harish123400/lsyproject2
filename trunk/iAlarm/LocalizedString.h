//
//  LocalizedString.h
//  iAlarm
//
//  Created by li shiyong on 10-11-25.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/////////////////////////////////////////////////////////////////////////////////////
//名称
////界面元素
#define KInformationLabel                        NSLocalizedString(@"Info",@"指示详细信息的标签，多用于NavBar Title");

#define KAlarmNameLabel                          NSLocalizedString(@"Label",@"指示AlarmName的标签");
#define KAlarmPostionLabel                       NSLocalizedString(@"Address",@"指示AlarmPosition的标签");
#define KAlarmMapInfoLabel                       NSLocalizedString(@"address",@"地图详细地址页面地址的标签（英文小写）");

#define kDefaultLocationAlarmName                NSLocalizedString(@"Location Alarm",@"默认的位置闹钟名称")
#define kMapTypeNameStandard                     NSLocalizedString(@"Map",@"地图类型名称")
#define KMapTypeNameSatellite                    NSLocalizedString(@"Satellite",@"地图类型名称")
#define KMapTypeNameHybrid                       NSLocalizedString(@"Hybrid",@"地图类型名称")
#define KMapNewAnnotationTitle                   NSLocalizedString(@"Drag the Pin",@"一个新图钉的标题");
#define KMapBookmarksViewTitle                   NSLocalizedString(@"Bookmarks",@"Bookmarkslist视图的标题");
#define KMapBookmarksViewPrompt                  NSLocalizedString(@"Choose a bookmark to view on the map",@"Bookmarkslist视图的Prompt");




/////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////
//alert提示

////通用
#define kAlertBtnOK                              NSLocalizedString(@"OK",@"alert提示的OK按钮")
#define kAlertBtnCancel                          NSLocalizedString(@"Cancel",@"alert提示的Cancel按钮")
#define kAlertBtnSettings                        NSLocalizedString(@"Settings",@"alert提示的Settings按钮")


////地图查询
#define kAlertTitleWhenSearchMap                 NSLocalizedString(@"Search",@"地图查询alert标题")
#define kAlertMsgNoResultsWhenSearchMap          NSLocalizedString(@"No results found.",@"地图查询时候，无结果")
#define kAlertMsgTooManyQueriesWhenSearchMap     NSLocalizedString(@"Too many queries has been made, please try at tomorrow",@"地图查询时候，一天内查询次数过多")
#define kAlertMsgErrorWhenSearchMap              NSLocalizedString(@"Network error, please try again.",@"地图查询时候，发生错误")


/////////////////////////////////////////////////////////////////////////////////////