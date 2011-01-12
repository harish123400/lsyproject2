//
//  YCSoundPlayer.h
//  iAlarm
//
//  Created by li shiyong on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>


@interface YCSoundPlayer : NSObject {
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
	
	BOOL playing;
}

@property(nonatomic,assign) BOOL playing;

-(id)initWithSoundName:(CFStringRef)soundName soundType:(CFStringRef)soundType;
-(void)play;
-(void)stop;

@end

//声音播放完成后的回调函数
void callback_playSystemSoundCompletion(SystemSoundID  ssID,void*clientData);