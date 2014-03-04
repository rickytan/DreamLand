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

@interface DLApplication () <LEDControllerDelegate, LEDFinderDelegate, DLAlarmDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) AVAudioPlayer * player;
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
        _controller.speed = 31;
        _controller.luminance = 100;
        _controller.pause = NO;
        _controller.on = YES;
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _controller.on = NO;
            _controller.mode = 1;
        });
    }
}

- (void)lightUpLight
{
    if (self.isLightConnected) {
        _controller.speed = 10;
        _controller.mode = 1;
        _controller.luminance = 1;
        _controller.pause = NO;
        _controller.on = YES;
        [self increaseLuminance];
    }
}

- (void)increaseLuminance
{
    if (self.isLightConnected) {
        if (_controller.luminance < 100) {
            [self performSelector:@selector(increaseLuminance)
                       withObject:Nil
                       afterDelay:5.0];
        }
        _controller.luminance += 2;
    }
}

- (void)increaseVolume
{
    if (self.player.volume < 0.9)
        [self performSelector:@selector(increaseVolume)
                   withObject:self
                   afterDelay:10.0];
    self.player.volume += 0.2;
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
        self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:musicFile]
                                                       fileTypeHint:@"mp3"
                                                              error:NULL] autorelease];
        self.player.numberOfLoops = NSIntegerMax;
    }
    self.player.volume = 0.1;
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
    if (alertView.cancelButtonIndex == buttonIndex) {
        [self.player stop];
        _controller.on = NO;
    }
    else {
        
    }
}

@end
