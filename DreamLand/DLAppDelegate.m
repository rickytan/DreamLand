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

@implementation DLAppDelegate
{
    LEDController               * _controller;
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //    [[CBCentralManager alloc] initWithDelegate:self
    //                                         queue:dispatch_get_main_queue()];
    [application setIdleTimerDisabled:YES];
    
    /*
     _controller = [[LEDController alloc] initWithDevice:[LEDDevice deviceWithIP:@"192.168.10.1"]];
     if ([_controller connect]) {
     if ([_controller updateDeviceInfo]) {
     BOOL isOn = _controller.isOn;
     BOOL isPuased = _controller.isPaused;
     UIColor *color = _controller.color;
     BOOL isConnected = _controller.isConnected;
     }
     _controller.on = NO;
     _controller.color = [UIColor yellowColor];
     }
     */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([UIDevice currentDevice].isMultitaskingSupported) {
        __block UIApplication *weakApp = application;
        self.taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            if (self.taskIdentifier != UIBackgroundTaskInvalid)
                [weakApp endBackgroundTask:self.taskIdentifier];
        }];
        NSLog(@"Time remaining: %f", application.backgroundTimeRemaining);
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (self.taskIdentifier != UIBackgroundTaskInvalid)
        [application endBackgroundTask:self.taskIdentifier];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
