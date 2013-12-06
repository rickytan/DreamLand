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
#import <AVFoundation/AVFoundation.h>

static DLDataRecorder * theRecorder = nil;

@interface DLDataRecorder ()
{
    AVAudioRecorder             * _recorder;
}
@property (nonatomic, retain) CMMotionManager * motionManager;
@property (nonatomic, retain) NSTimer         * timer;
@property (nonatomic, retain) NSTimer         * updateTimer;
@property (nonatomic, assign) BOOL              shouldWrite;
@property (nonatomic, retain) DLRecord        * record;

- (void)writeRecord:(CGFloat)value;

- (void)doRecord;
- (void)setShouldntWrite;

@end

static const CGFloat smoothRatio      = 0.56f;
const CGFloat recordingStartThreshold = 0.28f;

@implementation DLDataRecorder
@synthesize currentZ = zValue, deltaZ = deltaZ;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_motionManager release];
    if (_recorder.isRecording)
        [_recorder stop];
    [_recorder deleteRecording];
    [_recorder release];
    
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
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord
                                               error: nil];
        
        NSURL *url = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"]];
        _recorder = [[AVAudioRecorder alloc] initWithURL:url
                                                settings:@{AVSampleRateKey: [NSNumber numberWithFloat:22050.0],
                                                           AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatAppleLossless],
                                                           AVNumberOfChannelsKey: [NSNumber numberWithInt:1]}
                                                   error:nil];
        [_recorder prepareToRecord];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
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

- (void)onEnterBackground:(NSNotification*)notification
{
    if (self.isRecording) {

        [_recorder record];
    }
}

- (void)doRecord
{
    if (self.shouldWrite)
        [self writeRecord:deltaZ];
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
        __block NSDate *date = [[NSDate alloc] init];
        dispatch_async(_queue, ^{
            [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
                [db executeUpdate:@"INSERT INTO Data (`value`,`time`,`rid`) VALUES (?, ?, ?)", [NSNumber numberWithFloat:v], [NSNumber numberWithDouble:[date autorelease].timeIntervalSince1970], [NSNumber numberWithUnsignedInteger:self.record.recordId]];
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
    [self writeRecord:0.0];
    self.shouldWrite = NO;
}

- (void)update:(NSTimer*)timer
{
#if !TARGET_IPHONE_SIMULATOR
    CMAcceleration acce = self.motionManager.deviceMotion.userAcceleration;
    zValue = smoothRatio * acce.z + (1.0 - smoothRatio) * zValue;
#else
    static NSTimeInterval t = 0.0;
    zValue = (0.8 * sin(20 * t) + 0.2 * cos(40 * t) + 0.1 * sin(50 * t)) * exp(cos(5 * t)) / M_E;
    t += timer.timeInterval;
#endif
    static CGFloat lastValue = 0.0;
    
    deltaZ        = (zValue - lastValue) / timer.timeInterval;
    deltaZ        = MIN(MAX(deltaZ, -1.5), 1.5);
    lastValue     = zValue;
    
    CGFloat absZ = fabsf(deltaZ);
    if (!self.shouldWrite && absZ > recordingStartThreshold) {
        [self writeRecord:0.0f];
        self.shouldWrite = YES;
        [self.timer invalidate];
        self.timer = nil;
    }
    else if (self.shouldWrite && absZ <= recordingStartThreshold) {
        if (!self.timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2
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
    deltaZ = zValue = 0.0f;
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
}

- (BOOL)isRecording
{
    return self.motionManager.isDeviceMotionActive;
}

- (void)stop
{
    if (_recorder.isRecording) {
        [_recorder stop];
    }
    
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    [self.motionManager stopDeviceMotionUpdates];
    
    // 补一个 0
    [self writeRecord:0.0];
    
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
