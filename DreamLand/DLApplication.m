//
//  DLApplication.m
//  DreamLand
//
//  Created by ricky on 14-3-1.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLApplication.h"
#import "LEDKit.h"

@interface DLApplication () <LEDControllerDelegate, LEDFinderDelegate>

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
    if (self.lightConnected) {
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

- (void)findLEDLight
{
    if (_finder.isScanning)
        return;

    _finder = [[LEDFinder alloc] init];
    [_finder startScanWithDelegate:self];
}

- (void)playMusic
{

}

- (void)setLightColor:(UIColor *)color
{
    if (self.isLightConnected)
        _controller.color = color;
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

@end
