//
//  DLSoundPlayer.m
//  DreamLand
//
//  Created by ricky on 13-12-17.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation DLSoundPlayer
{
    SystemSoundID           soundID;
}

- (void)dealloc
{
    AudioServicesRemoveSystemSoundCompletion(soundID);
    [super dealloc];
}

- (id)initWithURL:(NSURL *)fileURL
{
    self = [super init];
    if (self) {
        AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &soundID);
    }
    return self;
}

- (void)play
{
    AudioServicesPlaySystemSound(soundID);
}

@end
