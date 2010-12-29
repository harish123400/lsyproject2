//
//  DicManager.m
//  iArrived
//
//  Created by li shiyong on 10-10-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LocalizedString.h"
#import "DicManager.h"
#import "YCSound.h"
#import "YCRepeatType.h"
#import "YCVehicleType.h"
#import "YCPositionType.h"


@implementation DicManager

#define ksoundCount 2
+(NSDictionary*) soundDictionary
{

	static NSMutableDictionary* soundDic;

	if (!soundDic) 
	{
		NSString* names[ksoundCount] = 
		{
			KSoundName001,
			KSoundName002
		};
		
		NSString* fileNames[ksoundCount] = 
		{
			@"001.mid",
			@"002.mid"
		};
		
		NSString* ids[ksoundCount] = 
		{
			@"s001",
			@"s002"
		};
		
		NSUInteger sortIds[ksoundCount] = 
		{
			0,
			1
		};
		
		soundDic = [[NSMutableDictionary alloc] init];
		for (int i=0; i<ksoundCount; i++) 
		{
			YCSound *obj = [[YCSound alloc] init];
			obj.soundId = ids[i];
			obj.soundName = names[i];
			obj.soundFileName = fileNames[i];
			obj.sortId = sortIds[i];
			[soundDic setObject:obj forKey:ids[i]];
			[obj release];
		}
		
	}
	
	return soundDic;
	
}

#define krepeatTypeCount 2
+(NSDictionary*) repeatTypeDictionary
{
	static NSMutableDictionary* repeatTypeDic;
	if (!repeatTypeDic) 
	{
		NSString* names[ksoundCount] = 
		{
			KRepeateTypeName001,
			KRepeateTypeName002
		};
		
		NSString* ids[ksoundCount] = 
		{
			@"r001",
			@"r002"
		};
		
		NSUInteger sortIds[ksoundCount] = 
		{
			0,
			1
		};
		
		repeatTypeDic = [[NSMutableDictionary alloc] init];
		for (int i=0; i<ksoundCount; i++) 
		{
			YCRepeatType *obj = [[YCRepeatType alloc] init];
			obj.repeatTypeId = ids[i];
			obj.repeatTypeName = names[i];
			obj.sortId = sortIds[i];
			[repeatTypeDic setObject:obj forKey:ids[i]];
			[obj release];
		}
		
	}
	
	return repeatTypeDic;
}

#define kvehicleTypeCount 2
+(NSDictionary*) vehicleTypeDictionary
{
	static NSMutableDictionary* vehicleTypeDic;
	if (!vehicleTypeDic) 
	{
		NSString* names[ksoundCount] = 
		{
			NSLocalizedString(@"公交",@""),
			NSLocalizedString(@"火车",@"")
		};
		
		NSString* ids[ksoundCount] = 
		{
			@"v001",
			@"v002"
		};
		
		vehicleTypeDic = [[NSMutableDictionary alloc] init];
		for (int i=0; i<ksoundCount; i++) 
		{
			YCVehicleType *obj = [[YCVehicleType alloc] init];
			obj.vehicleTypeId = ids[i];
			obj.vehicleTypeName = names[i];
			[vehicleTypeDic setObject:obj forKey:ids[i]];
			[obj release];
		}
		
	}
	
	return vehicleTypeDic;
}

#define kpositionTypeCount 2
+(NSDictionary*) positionTypeDictionary
{
	static NSMutableDictionary* dic;
	if (!dic) 
	{
		NSString* names[ksoundCount] = 
		{
			NSLocalizedString(@"当前位置",@"指示地理位置方式的标签"),
			NSLocalizedString(@"地图指定位置",@"指示地理位置方式的标签")
		};
		
		NSString* ids[ksoundCount] = 
		{
			@"p001",
			@"p002"
		};
		
		NSUInteger sortIds[ksoundCount] = 
		{
			0,
			1
		};
		
		dic = [[NSMutableDictionary alloc] init];
		for (int i=0; i<ksoundCount; i++) 
		{
			YCPositionType *obj = [[YCPositionType alloc] init];
			obj.positionTypeId = ids[i];
			obj.positionTypeName = names[i];
			obj.sortId = sortIds[i];
			[dic setObject:obj forKey:ids[i]];
			[obj release];
		}
		
	}
	
	return dic;
}

+(YCRepeatType*) repeatTypeForSortId:(NSUInteger)sortId
{
	NSArray *repArray = [[DicManager repeatTypeDictionary] allValues];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sortId == %d",sortId];
	NSArray* results = [repArray filteredArrayUsingPredicate:predicate];
	YCRepeatType *obj;
	if (results.count > 0) {
		obj = [results objectAtIndex:0]; //有，且有一个
	}
	return obj;
}

+(YCSound*) soundForSortId:(NSUInteger)sortId
{
	NSArray *repArray = [[DicManager soundDictionary] allValues];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sortId == %d",sortId];
	NSArray* results = [repArray filteredArrayUsingPredicate:predicate];
	YCSound *obj;
	if (results.count > 0) {
		obj = [results objectAtIndex:0]; //有，且有一个
	}
	return obj;
}

+(YCPositionType*) positionTypeForSortId:(NSUInteger)sortId
{
	NSArray *repArray = [[DicManager positionTypeDictionary] allValues];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sortId == %d",sortId];
	NSArray* results = [repArray filteredArrayUsingPredicate:predicate];
	YCPositionType *obj;
	if (results.count > 0) {
		obj = [results objectAtIndex:0]; //有，且有一个
	}
	return obj;
}

@end
