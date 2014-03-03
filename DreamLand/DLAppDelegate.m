//
//  DLAppDelegate.m
//  DreamLand
//
//  Created by ricky on 13-5-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLAppDelegate.h"
#import "DLDataRecorder.h"
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import "DLAlarm.h"

@implementation DLAppDelegate

+ (UIColor *)iOS7DefaultBlueTint
{
    return [UIColor colorWithRed:80.0/255
                           green:136.0/255
                            blue:253.0/255
                           alpha:1.0];
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (void)setupAppkey
{
    [AVOSCloud setApplicationId:@"w4f92crcf157iftzjn6zbuht27v7vrxqvhunsedhuxo96cee"
                      clientKey:@"60llr27v4wmg6li0ygw5imcuanm9l457wvpqrnrpyau51i77"];
    [AVOSCloud useAVCloudCN];

    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo
                     withAppKey:@"1710935034"
                   andAppSecret:@"088b209b48f2b6c352a6bbc4b29d3c9e"
                 andRedirectURI:@"https://api.weibo.com/oauth2/default.html"];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ
                     withAppKey:@"101028817"
                   andAppSecret:@"cccc95c3ba0cc6b5f589c937a2b3241a"
                 andRedirectURI:nil];

}

- (void)setupUI
{
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[[[UIImage alloc] init] autorelease]
                                                                                        forState:UIControlStateNormal
                                                                                      barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:[[[UIImage alloc] init] autorelease]
                                                                                        forState:UIControlStateNormal
                                                                                      barMetrics:UIBarMetricsLandscapePhone];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{UITextAttributeFont: [UIFont systemFontOfSize:16],
                                                                                                       UITextAttributeTextColor: [DLAppDelegate iOS7DefaultBlueTint],
                                                                                                       UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeZero]}
                                                                                            forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor grayColor],
                                                                                                       UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeZero]}
                                                                                            forState:UIControlStateHighlighted];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:CGSizeZero]}];
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self setupAppkey];
    [self setupUI];

    //    [[CBCentralManager alloc] initWithDelegate:self
    //                                         queue:dispatch_get_main_queue()];
    [application setIdleTimerDisabled:YES];

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

@end
