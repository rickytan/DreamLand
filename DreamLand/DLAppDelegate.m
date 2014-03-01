//
//  DLAppDelegate.m
//  DreamLand
//
//  Created by ricky on 13-5-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLAppDelegate.h"
#import "LEDDevice.h"
#import "LEDController.h"
#import "DLDataRecorder.h"
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import "LEDKit.h"
#import "YHWeather.h"

@interface DLAppDelegate () <LEDFinderDelegate, LEDControllerDelegate>

@end

@implementation DLAppDelegate
{
    LEDController               * _controller;
    LEDDevice                   * _device;
    LEDFinder                   * _finder;
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (void)setupAppkey
{
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo
                     withAppKey:@"1710935034"
                   andAppSecret:@"088b209b48f2b6c352a6bbc4b29d3c9e"
                 andRedirectURI:@"https://api.weibo.com/oauth2/default.html"];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ
                     withAppKey:@"101028817"
                   andAppSecret:@"cccc95c3ba0cc6b5f589c937a2b3241a"
                 andRedirectURI:nil];

}

- (void)searchAndConnectLight
{
    
}

- (void)findLEDLight
{
    if (_finder.isScanning)
        return;

    _finder = [[LEDFinder alloc] init];
    [_finder startScanWithDelegate:self];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setupAppkey];

    //    [[CBCentralManager alloc] initWithDelegate:self
    //                                         queue:dispatch_get_main_queue()];
    [application setIdleTimerDisabled:YES];

    _controller = [[LEDController alloc] initWithDevice:[LEDDevice deviceWithIP:@"192.168.10.1"]];
    _controller.delegate = self;
    [_controller connect];

    return YES;
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [AVOSCloudSNS handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [AVOSCloudSNS handleOpenURL:url];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([UIDevice currentDevice].isMultitaskingSupported) {
        __block UIApplication *weakApp = application;
        self.taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            if (self.taskIdentifier != UIBackgroundTaskInvalid)
                [weakApp endBackgroundTask:self.taskIdentifier];
        }];
        NSLog(@"Time remaining: %f", application.backgroundTimeRemaining);

    }
    /*
     [application setKeepAliveTimeout:10*60
     handler:^{
     NSLog(@"handler");
     self.taskIdentifier = UIBackgroundTaskInvalid;
     }];
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (self.taskIdentifier != UIBackgroundTaskInvalid)
        [application endBackgroundTask:self.taskIdentifier];
    [application clearKeepAliveTimeout];
}

#pragma mark - LEDFinder

- (void)LEDControllerDeviceInfoDidUpdated:(LEDController *)controller
{

}

- (void)LEDControllerStateDidChanged:(LEDController *)controller
{
    switch (controller.state) {
        case LEDControllerStateConnected:
            _lightConnected = YES;
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
