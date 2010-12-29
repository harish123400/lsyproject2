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
#define KInformationTitle                        NSLocalizedString(@"Info",@"指示详细信息的标签，多用于NavBar Title");
#define KAlarmsListViewTitle                     NSLocalizedString(@"iAlarm",@"闹钟列表视图标题");
#define KAddAlarmsViewTitle                      NSLocalizedString(@"Add iAlarm",@"闹钟列表视图标题");
#define KEditAlarmsViewTitle                     NSLocalizedString(@"Edit iAlarm",@"闹钟列表视图标题");
#define KRepeatViewTitle                         NSLocalizedString(@"Repeat",@"编辑闹钟重复类型视图标题");
#define KSoundViewTitle                          NSLocalizedString(@"Sound",@"编辑闹钟铃声视图标题");
#define KNameViewTitle                           NSLocalizedString(@"Label",@"编辑闹钟名称视图标题");



#define KAlarmNameLabel                          NSLocalizedString(@"Label",@"AlarmName的标签");
#define KAlarmSoundLabel                         NSLocalizedString(@"Sound",@"AlarmName的标签");
#define KAlarmVibrateLabel                       NSLocalizedString(@"Vibrate",@"AlarmName的标签");
#define KAlarmRepeatLabel                        NSLocalizedString(@"Repeat",@"AlarmName的标签");
#define KAlarmPostionLabel                       NSLocalizedString(@"Address",@"AlarmPosition的标签");
#define KAlarmMapInfoLabel                       NSLocalizedString(@"address",@"地图详细地址页面地址的标签（英文小写）");
#define KAlarmEnableLabel                        NSLocalizedString(@"Enable",@"Alarm是否启用的标签");
#define KAlarmCurrentLocationLabel               NSLocalizedString(@"by Current Location",@"当前位置的标签");
#define KAlarmLocationByMapLabel                 NSLocalizedString(@"by Maps",@"通过地图定位的标签");
#define KLocationingLabel                        NSLocalizedString(@"Locating",@"正在定位的标签");


#define kDefaultLocationAlarmName                NSLocalizedString(@"iAlarm",@"默认的位置闹钟名称")
#define kMapTypeNameStandard                     NSLocalizedString(@"Map",@"地图类型名称")
#define KMapTypeNameSatellite                    NSLocalizedString(@"Satellite",@"地图类型名称")
#define KMapTypeNameHybrid                       NSLocalizedString(@"Hybrid",@"地图类型名称")
#define KMapNewAnnotationTitle                   NSLocalizedString(@"Drag the Pin",@"一个新图钉的标题");
#define KMapBookmarksViewTitle                   NSLocalizedString(@"iAlarms",@"Bookmarkslist视图的标题");
#define KMapBookmarksViewPrompt                  NSLocalizedString(@"Choose a iAlarm to view on the map",@"Bookmarkslist视图的Prompt");

////重复类型的名称
#define KRepeateTypeName001                      NSLocalizedString(@"Forever",@"重复类型的名称-001")
#define KRepeateTypeName002                      NSLocalizedString(@"Once"   ,@"重复类型的名称-002")

////闹钟铃声名称
#define KSoundName001                            NSLocalizedString(@"Ring1",@"闹钟铃声名称-001")
#define KSoundName002                            NSLocalizedString(@"Ring2",@"闹钟铃声名称-002")


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


//经纬度转换
////41°46′21″N
#define kNorthLatitudeFormateString              NSLocalizedString(@"%d°%d′%d″N",   @"北纬格式化串")
////41°46′21.12″N
#define kNorthLatitudeFormateStringDecimal       NSLocalizedString(@"%d°%d′%d.%d″N",@"北纬格式化串(秒上带小数)")

#define kSouthLatitudeFormateString              NSLocalizedString(@"%d°%d′%d″S",   @"南纬格式化串")
#define kSouthLatitudeFormateStringDecimal       NSLocalizedString(@"%d°%d′%d.%d″S",@"南纬格式化串(秒上带小数)")

#define kEastLongitudeFormateString              NSLocalizedString(@"%d°%d′%d″E",   @"东经格式化串")
#define kEastLongitudeFormateStringDecimal       NSLocalizedString(@"%d°%d′%d.%d″E",@"东经格式化串(秒上带小数)")

#define kWestLongitudeFormateString              NSLocalizedString(@"%d°%d′%d″W",   @"西经格式化串")
#define kWestLongitudeFormateStringDecimal       NSLocalizedString(@"%d°%d′%d.%d″W",@"西经格式化串(秒上带小数)")


/////////////////////////////////////////////////////////////////////////////////////