//
//  DLApplication.m
//  DreamLand
//
//  Created by ricky on 14-3-1.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLApplication.h"
#import "LEDKit.h"
#import "DLAlarm.h"
#import "UIApplication+RExtension.h"
#import "NSUserDefaults+Settings.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DLApplication () <LEDControllerDelegate, LEDFinderDelegate, DLAlarmDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) AVAudioPlayer * player;
@property (nonatomic, retain) NSTimer * musicTimer, * lightTimer;
@end

@implementation DLApplication
{
    LEDController               * _controller;
    LEDDevice                   * _device;
    LEDFinder                   * _finder;
}

- (id)init
{
    self = [super init];
    if (self) {
        [DLAlarm sharedAlarm].delegate = self;
    }
    return self;
}

- (BOOL)isLightConnected
{
    return _controller.state == LEDControllerStateConnected;
}

- (void)searchAndConnectLight
{
    // Demo version, not try to search here, directly connect to 192.168.10.1
    if (!_controller) {
        _controller = [[LEDController alloc] initWithDevice:[LEDDevice deviceWithIP:@"192.168.10.1"]];
        _controller.delegate = self;
    }
    [_controller connect];
}

- (void)disconnectLight
{
    [_controller disconnect];
    [_controller release];
    _controller = nil;
}

- (void)testLight
{
    if (self.isLightConnected) {
        _controller.mode = 1;
        _controller.speed = 1;
        _controller.luminance = 100;
        _controller.color = [UIColor redColor];
        _controller.on = YES;
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _controller.mode = 2;
            _controller.color = [UIColor greenColor];

            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                _controller.mode = 2;
                _controller.color = [UIColor blueColor];

                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    _controller.mode = 12;
                    _controller.speed = 1;
                    _controller.pause = NO;

                    double delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        _controller.on = NO;
                    });
                });
            });
        });
    }
}

- (void)lightUpLight
{
    if (self.isLightConnected) {
        _controller.on = YES;
        _controller.color = THEME_COLOR;
        _controller.mode = 1;
        _controller.speed = 10;
        _controller.luminance = 10;
        [self increaseLuminance];
    }
}

- (void)increaseLuminance
{
    if (self.isLightConnected) {
        if (!self.lightTimer) {
            self.lightTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                               target:self
                                                             selector:@selector(increaseLuminance)
                                                             userInfo:nil
                                                              repeats:YES];
        }
        if (_controller.luminance < 100) {
            _controller.luminance += 5;
        }
        else {
            _controller.luminance = 100;
            [self.lightTimer invalidate];
            self.lightTimer = nil;
        }
    }
    else {
        [self.lightTimer invalidate];
        self.lightTimer = nil;
    }
}

- (void)increaseVolume
{
    if (!self.musicTimer) {
        self.musicTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                           target:self
                                                         selector:@selector(increaseVolume)
                                                         userInfo:nil
                                                          repeats:YES];
    }

    if (self.player.volume < 0.9) {
        self.player.volume += 0.2;
    }
    else {
        self.player.volume = 1.0;
        [self.musicTimer invalidate];
        self.musicTimer = nil;
    }
}

- (void)findLEDLight
{
    if (_finder.isScanning)
        return;

    _finder = [[LEDFinder alloc] init];
    [_finder startScanWithDelegate:self];
}

- (void)playMusic:(NSString *)musicFile
{
    if (!self.player) {
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory);

        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride);

        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [audioSession setCategory:AVAudioSessionCategoryPlayback
                            error:nil];
        [audioSession setActive:YES
                          error:nil];

        self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:musicFile]
                                                       fileTypeHint:@"mp3"
                                                              error:NULL] autorelease];
        self.player.numberOfLoops = NSIntegerMax;
    }
    [MPMusicPlayerController applicationMusicPlayer].volume = 0.8;
    self.player.volume = 0.05;
    [self.player play];
    [self increaseVolume];
}

- (void)setLightColor:(UIColor *)color
{
    if (self.isLightConnected)
        _controller.color = color;
}

- (void)timeUp
{
    [self playMusic:[NSUserDefaults standardUserDefaults].alarmMusic];
    [self lightUpLight];

    [[[[UIAlertView alloc] initWithTitle:@"Time to Wake up!"
                                 message:nil
                                delegate:self
                       cancelButtonTitle:@"Stop"
                       otherButtonTitles:@"Snooze", nil] autorelease] show];
    if (self.applicationState == UIApplicationStateBackground) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.alertBody = @"Time to Wake up!";
        notification.alertAction = @"Slide to Stop";
        notification.soundName = nil;
        [self scheduleLocalNotification:notification];
        [notification release];
    }
}

#pragma mark - LEDFinder

- (void)LEDControllerDeviceInfoDidUpdated:(LEDController *)controller
{

}

- (void)LEDControllerStateDidChanged:(LEDController *)controller
{
    switch (controller.state) {
        case LEDControllerStateConnected:

            break;
        case LEDControllerStateError:
        case LEDControllerStateNotConnected:
            //[_controller connect];
            break;
        default:
            break;
    }
}

#pragma mark - DLAlarm

- (void)alarmDidFired:(DLAlarm *)alarm
{
    [self timeUp];
}

- (void)alarmDidEnterAlarmRange:(DLAlarm *)alarm
{

}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //if (alertView.cancelButtonIndex == buttonIndex) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(increaseLuminance)
                                                   object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(increaseVolume)
                                                   object:nil];
        [self.player stop];
        _controller.pause = YES;
        _controller.mode = 1;
        _controller.on = NO;
    //}
}

@end
