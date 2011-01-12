//
//  YCSoundPlayer.m
//  iAlarm
//
//  Created by li shiyong on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "YCSoundPlayer.h"


@implementation YCSoundPlayer
@synthesize playing;


-(id)initWithSoundName:(CFStringRef)soundName soundType:(CFStringRef)soundType{
	
	if (self= [super init]) {
		// Get the main bundle for the app
		CFBundleRef mainBundle;
		mainBundle = CFBundleGetMainBundle ();
		
		// Get the URL to the sound file to play
		soundFileURLRef  =	CFBundleCopyResourceURL (mainBundle,
													 soundName,
													 soundType,
													 NULL
													 );
		//注册回调函数
		AudioServicesAddSystemSoundCompletion(soundFileObject,NULL,NULL,&callback_playSystemSoundCompletion,self);

	}
	
	return self;
	
}

-(void)play{
	if (!self.playing) {
		self.playing = YES;
		// Create a system sound object representing the sound file
		AudioServicesCreateSystemSoundID (soundFileURLRef,&soundFileObject);
		//to play
		AudioServicesPlayAlertSound (soundFileObject);
	}
	
}
-(void)stop{
	if (self.playing) {
		AudioServicesDisposeSystemSoundID(soundFileObject);
	}
}

- (void)dealloc {
	AudioServicesDisposeSystemSoundID (soundFileObject);
	CFRelease (soundFileURLRef);
    [super dealloc];
}

@end

//声音播放完成后的回调函数
void callback_playSystemSoundCompletion(SystemSoundID  ssID,void*clientData){
	AudioServicesDisposeSystemSoundID(ssID);//删除声音对象
	[(YCSoundPlayer*)clientData setPlaying:NO];
}
