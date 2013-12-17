//
//  DLSoundPlayer.h
//  DreamLand
//
//  Created by ricky on 13-12-17.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLSoundPlayer : NSObject
@property (nonatomic, readonly, getter = isPlaying) BOOL playing;
- (id)initWithURL:(NSURL*)fileURL;
- (void)play;
@end
