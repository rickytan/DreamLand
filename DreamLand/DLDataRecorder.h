//
//  DLDataRecorder.h
//  DreamLand
//
//  Created by ricky on 13-11-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat recordingStartDeltaThreshold;
extern CGFloat recordingStartValueThreshold;

@interface DLDataRecorder : NSObject
@property (nonatomic, readonly) CGFloat currentZ, deltaZ;
@property (nonatomic, readonly, getter = isRecording) BOOL recording;

+ (instancetype)sharedRecorder;

- (void)reset;
- (void)start;
- (void)stop;

- (NSUInteger)lastestRecordID;

@end
