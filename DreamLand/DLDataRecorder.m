//
//  DLDataRecorder.m
//  DreamLand
//
//  Created by ricky on 13-11-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDataRecorder.h"
#import "DLRecord.h"
#import "DLDatabase.h"
#import <CoreMotion/CoreMotion.h>

static DLDataRecorder * theRecorder = nil;

@interface DLDataRecorder ()
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, assign) BOOL shouldWrite;
@property (nonatomic, retain) DLRecord *record;

- (void)writeRecord:(CGFloat)value;

- (void)doRecord;
- (void)setShouldntWrite;

@end

const CGFloat smoothRatio                = 0.6f;
const CGFloat recordingStartThreshold    = 0.12f;

@implementation DLDataRecorder
@synthesize currentX = xValue, currentY = yValue, currentZ = zValue;
@synthesize shouldWrite = _shouldWrite;

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
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.deviceMotionUpdateInterval = 1.0 / 30;
        _motionManager.showsDeviceMovementDisplay = YES;
        
#if !TARGET_IPHONE_SIMULATOR
        if (!self.motionManager.isAccelerometerAvailable) {
            [[[[UIAlertView alloc] initWithTitle:@"错误"
                                         message:@"您的设备不支持加速度传感器！"
                                        delegate:nil
                               cancelButtonTitle:@"好"
                               otherButtonTitles:nil] autorelease] show];
            self.motionManager = nil;
        }
#endif
    }
    return self;
}

- (NSUInteger)lastestRecordID
{
    __block NSUInteger rtnval = 0;
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"SELECT MAX(id) FROM Record"];
        if ([result next])
            rtnval = [result intForColumnIndex:0];
        [result close];
    }];
    return rtnval;
}

- (void)doRecord
{
    if (self.shouldWrite)
        [self writeRecord:zValue];
}

- (void)writeRecord:(CGFloat)value
{
    
    static dispatch_queue_t _queue = NULL;
    @synchronized(self) {
        if (!_queue)
            _queue = dispatch_queue_create("SQLite Write Queue", DISPATCH_QUEUE_SERIAL);
    }
    
    __block CGFloat v = value;
    
    @synchronized(self) {
        dispatch_async(_queue, ^{
            [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
                [db executeUpdate:@"INSERT INTO Data (`value`,`time`,`rid`) VALUES (?, ?, ?)", [NSNumber numberWithFloat:v], [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970], [NSNumber numberWithUnsignedInteger:self.record.recordId]];
            }];
        });
    }
    
    /*
     [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
     [db executeUpdate:@"INSERT INTO Data (`value`,`time`,`rid`) VALUES (?, ?, ?)", [NSNumber numberWithFloat:v], [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970], [NSNumber numberWithUnsignedInteger:self.record.recordId]];
     }];
     */
}

- (void)setShouldWrite:(BOOL)shouldWrite
{
    if (_shouldWrite != shouldWrite) {
        _shouldWrite = shouldWrite;
        NSLog(@"%@", _shouldWrite ? @"开始记录" : @"停止记录");
    }
}

- (void)setShouldntWrite
{
    self.shouldWrite = NO;
}

- (void)update:(NSTimer*)timer
{
    CMAcceleration acce = self.motionManager.deviceMotion.userAcceleration;
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
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                          target:self
                                                        selector:@selector(setShouldntWrite)
                                                        userInfo:nil
                                                         repeats:NO];
        }
    }
    else if (absZ > recordingStartThreshold) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self doRecord];
}

- (void)reset
{
    xValue = yValue = zValue = 0.0f;
    self.shouldWrite = NO;
    [self.timer invalidate];
    self.timer = nil;
    self.record = nil;
    
    if (self.isRecording)
        [self stop];
}

- (void)start
{
    self.record = [DLRecord recordWithId:[self lastestRecordID] + 1];
    [self.record start];
    
    [self.motionManager startDeviceMotionUpdates];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 60
                                                        target:self
                                                      selector:@selector(update:)
                                                      userInfo:nil
                                                       repeats:YES];
    /*
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
     if (!self.timer) {
     self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0
     target:self
     selector:@selector(setShouldntWrite)
     userInfo:nil
     repeats:NO];
     }
     }
     else if (absZ > recordingStartThreshold) {
     [self.timer invalidate];
     self.timer = nil;
     }
     
     [self doRecord];
     }
     }];
     */
}

- (BOOL)isRecording
{
    return self.motionManager.isDeviceMotionActive;
}

- (void)stop
{
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    [self.motionManager stopDeviceMotionUpdates];
    [self.record end];
    [self.timer invalidate];
    self.timer = nil;
    self.shouldWrite = NO;
    
    @synchronized(self) {
        [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
            if (![db executeUpdate:@"INSERT INTO Record (`id`, `starttime`, `endtime`) VALUES (?,?,?)", [NSNumber numberWithUnsignedInteger:self.record.recordId], self.record.startTime, self.record.endTime])
                NSLog(@"%@, Thread: %@", db.lastError, [NSThread currentThread]);
            self.record = nil;
        }];
    }
}

@end