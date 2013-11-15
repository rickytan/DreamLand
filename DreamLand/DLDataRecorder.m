//
//  DLDataRecorder.m
//  DreamLand
//
//  Created by ricky on 13-11-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDataRecorder.h"
#import <CoreMotion/CoreMotion.h>
#import "FMDatabase.h"

static DLDataRecorder * theRecorder = nil;

@interface DLDataRecorder ()
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) FMDatabase *database;
@property (nonatomic, assign) BOOL shouldWrite;
@property (nonatomic, assign) NSInteger trackID;

- (void)initDatabase;
- (void)writeRecord:(CGFloat)value;

- (void)doRecord;
- (void)setShouldntWrite;

@end

static const CGFloat smoothRatio                = 0.6f;
static const CGFloat recordingStartThreshold    = 2.8f;

@implementation DLDataRecorder
@synthesize currentX = xValue, currentY = yValue, currentZ = zValue;

+ (instancetype)sharedRecorder
{
    @synchronized(self) {
        if (!theRecorder) {
            theRecorder = [[DLDataRecorder alloc] init];
        }
        return theRecorder;
    }
    return nil;
}

- (void)dealloc
{
    [_motionManager release];
    self.database = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _motionManager = [[CMMotionManager alloc] init];
        self.database = [FMDatabase databaseWithPath:[[NSBundle mainBundle] bundlePath]];
        
        [self initDatabase];
    }
    return self;
}

- (void)initDatabase
{
    if (![self.database executeUpdate:
          @"CREATA TABLE IF NOT EXISTS data ("
          @"    value float NOT NULL DEFAULT 0,"
          @"    time timestamp NOT NULL DEFAULT NOW(),"
          @"    trackid int,"
          @"    INDEX(`trackid`),"
          @")"
          ]) {
        NSLog(@"%@", [self.database lastError]);
    }
    if (![self.database executeUpdate:
          @"CREATA TABLE IF NOT EXISTS record ("
          @"    id float NOT NULL DEFAULT 0,"
          @"    starttime timestamp NULL,"
          @"    endtime timestamp NULL,"
          @"    INDEX(`trackid`),"
          @")"
          ]) {
        NSLog(@"%@", [self.database lastError]);
    }
}

- (void)doRecord
{
    if (self.shouldWrite)
        [self writeRecord:zValue];
}

- (void)writeRecord:(CGFloat)value
{
    
}

- (void)reset
{
    xValue = yValue = zValue = 0.0f;
    self.shouldWrite = NO;
    [self.timer invalidate];
    self.timer = nil;
    
    if (self.isRecording)
        [self stop];
}

- (void)start
{
    FMResultSet *result = [self.database executeQuery:@"SELECT MAX(id) FROM record"];
    self.trackID = [result intForColumnIndex:0] + 1;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMDeviceMotion *d, NSError *e) {
                                                if (!e) {
                                                    CMAcceleration acce = d.userAcceleration;
                                                    xValue = smoothRatio * acce.x + (1.0 - smoothRatio) * xValue;
                                                    yValue = smoothRatio * acce.y + (1.0 - smoothRatio) * yValue;
                                                    zValue = smoothRatio * acce.z + (1.0 - smoothRatio) * zValue;
                                                    
                                                    CGFloat absZ = fabsf(zValue);
                                                    if (!self.shouldWrite && absZ > recordingStartThreshold) {
                                                        self.shouldWrite = YES;
                                                        [self.timer invalidate];
                                                        self.timer = nil;
                                                    }
                                                    else if (self.shouldWrite && absZ <= recordingStartThreshold) {
                                                        
                                                        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                                                      target:self
                                                                                                    selector:@selector(setShouldntWrite)
                                                                                                    userInfo:nil
                                                                                                     repeats:NO];
                                                    }
                                                    else if (absZ > recordingStartThreshold) {
                                                        [self.timer invalidate];
                                                        self.timer = nil;
                                                    }
                                                    
                                                    [self doRecord];
                                                }
                                            }];
}

- (BOOL)isRecording
{
    return self.motionManager.isDeviceMotionActive;
}

- (void)stop
{
    [self.database close];
    [self.motionManager stopDeviceMotionUpdates];
}

@end
