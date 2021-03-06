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
        OSStatus status = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
        if (status != kAudioServicesNoError) {
            NSLog(@"Create Error! %ld", status);
        }
    }
    return self;
}

- (void)play
{
    _playing = YES;
    AudioServicesPlayAlertSound(soundID);
}

@end
