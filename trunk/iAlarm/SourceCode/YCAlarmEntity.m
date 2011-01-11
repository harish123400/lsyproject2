//
//  YCAlarmEntity.m
//  iArrived
//
//  Created by li shiyong on 10-10-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSCoder-YC.h"
#import "LocalizedString.h"
#import "YCAlarmEntity.h"
#import "DataUtility.h"
#import "YCSound.h"
#import "YCRepeatType.h"
#import "YCVehicleType.h"
#import "DicManager.h"
#import "YCParam.h"





@implementation YCAlarmEntity

@synthesize alarmId;
@synthesize alarmName;
@synthesize position;
@synthesize positionShort;
@synthesize description;
@synthesize sortId;
@synthesize enabling;
@synthesize coordinate;
@synthesize vibrate;
@synthesize ring;
@synthesize nameChanged;
@synthesize positionType;
@synthesize sound;
@synthesize repeatType;
@synthesize vehicleType;
@synthesize soundId;
@synthesize repeatTypeId;
@synthesize vehicleTypeId;
@synthesize radius;
@synthesize locationAccuracy;


-(id)init
{
	if (self = [super init]) 
	{
		

		self.alarmId = [DataUtility genSerialCode];
		self.alarmName = kDefaultLocationAlarmName;
		self.positionType = [[DicManager positionTypeDictionary] objectForKey:@"p001"];
		self.position = @"";
		self.positionShort = @""; 
	    self.description  = @"";              
		self.sortId = 0;       
		self.enabling = YES; 
		CLLocationCoordinate2D coor = {-10000.0,-10000.0};
		self.coordinate = coor;            
		self.vibrate = YES;
		self.ring = YES;
		
		self.sound = [[DicManager soundDictionary] objectForKey:@"s001"];
		self.repeatType = [[DicManager repeatTypeDictionary] objectForKey:@"r001"];
		self.vehicleType = [[DicManager vehicleTypeDictionary] objectForKey:@"v001"];
		
		self.radius = [[YCParam paramSingleInstance] radiusForAlarm];
		 
	}
	return self;
}



#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {

	[encoder encodeObject:alarmId forKey:kalarmId];
	[encoder encodeObject:alarmName forKey:kalarmName];
	[encoder encodeObject:position forKey:kposition];
	[encoder encodeObject:positionShort forKey:kpositionShort];
	[encoder encodeObject:description forKey:kdescription];
	[encoder encodeInteger:sortId  forKey:ksortId];
	[encoder encodeBool:enabling forKey:kenabling];
	[encoder encodeCLLocationCoordinate2D:coordinate forKey:kcoordinate];
	[encoder encodeDouble:locationAccuracy forKey:klocationAccuracy];
	[encoder encodeBool:vibrate forKey:kvibration];
	[encoder encodeBool:ring forKey:kring];
	[encoder encodeBool:nameChanged forKey:knameChanged];
	[encoder encodeObject:sound.soundId forKey:kasoundId];
	[encoder encodeObject:repeatType.repeatTypeId forKey:karepeatTypeId];
	[encoder encodeObject:vehicleType.vehicleTypeId forKey:kavehicleTypeId];
	[encoder encodeDouble:radius forKey:kradius];
	
}

- (id)initWithCoder:(NSCoder *)decoder {
	
    if (self = [super init]) {		
		self.alarmId = [decoder decodeObjectForKey:kalarmId];
		self.alarmName = [decoder decodeObjectForKey:kalarmName];
		self.position = [decoder decodeObjectForKey:kposition];
		self.positionShort = [decoder decodeObjectForKey:kpositionShort];
		self.description = [decoder decodeObjectForKey:kdescription];
		self.sortId = [decoder decodeIntegerForKey:ksortId];
		self.enabling = [decoder decodeBoolForKey:kenabling];
		self.coordinate = [decoder decodeCLLocationCoordinate2DForKey:kcoordinate];
		self.locationAccuracy = [decoder decodeDoubleForKey:klocationAccuracy];
		self.vibrate =[decoder decodeBoolForKey:kvibration];
		self.ring =[decoder decodeBoolForKey:kring];
		self.nameChanged =[decoder decodeBoolForKey:knameChanged];
		self.soundId =[decoder decodeObjectForKey:kasoundId];
		self.repeatTypeId =[decoder decodeObjectForKey:karepeatTypeId];
		self.vehicleTypeId =[decoder decodeObjectForKey:kavehicleTypeId];
		self.radius = [decoder decodeDoubleForKey:kradius];
    }
    return self;
}


#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	
	/*
    YCAlarmEntity *copy = [[[self class] allocWithZone: zone] init];
    copy.alarmId = [[self.alarmId copyWithZone:zone] autorelease];
    copy.alarmName = [[self.alarmName copyWithZone:zone] autorelease];
    copy.position = [[self.position copyWithZone:zone] autorelease];
    copy.description = [[self.description copyWithZone:zone] autorelease];
	copy.sortId = self.sortId ;
	copy.enabling = self.enabling;
	copy.vibrate = self.vibrate;
	copy.ring = self.ring;
	copy.sound = self.sound;
	copy.repeatType = self.repeatType;
	copy.vehicleType = self.vehicleType;
	
	copy.soundId = [[self.soundId copyWithZone:zone] autorelease];
	copy.repeatTypeId = [[self.repeatTypeId copyWithZone:zone] autorelease];
	copy.vehicleTypeId = [[self.vehicleTypeId copyWithZone:zone] autorelease];
	 */
	

	YCAlarmEntity *copy = [[[self class] allocWithZone: zone] init];
    copy.alarmId = self.alarmId;
    copy.alarmName = self.alarmName;
    copy.position = self.position;
	copy.positionShort = self.positionShort;
    copy.description = self.description;
	copy.sortId = self.sortId ;
	copy.enabling = self.enabling;
	copy.coordinate = self.coordinate;
	copy.locationAccuracy = self.locationAccuracy;
	copy.vibrate = self.vibrate;
	copy.ring = self.ring;
	copy.ring = self.ring;
	copy.nameChanged = self.nameChanged;
	copy.repeatType = self.repeatType;
	copy.vehicleType = self.vehicleType;
	
	copy.soundId = self.soundId;
	copy.repeatTypeId = self.repeatTypeId;
	copy.vehicleTypeId = self.vehicleTypeId;
	
	copy.radius = self.radius;
    
    return copy;
}

- (void)dealloc {
	[alarmId release];
	[alarmName release];
	[position release];
	[positionShort release];
	[description release];
	[sound release];
	[repeatType release];
	[vehicleType release];
	[soundId release];
	[repeatTypeId release];
	[vehicleTypeId release];
	
    [super dealloc];
}

@end
