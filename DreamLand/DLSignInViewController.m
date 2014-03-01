//
//  DLSignInViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-25.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSignInViewController.h"
#import "DLUser.h"
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import "UIApplication+RExtension.h"

@interface DLSignInViewController ()
- (IBAction)onWeibo:(id)sender;
- (IBAction)onWeChat:(id)sender;
@end

@implementation DLSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:YES
                                             animated:YES];

    if ([UIApplication sharedApplication].isFirstLaunch) {
        double delayInSeconds = .1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController performSegueWithIdentifier:@"ShowGuide"
                                                           sender:self];
        });
    }

    if ([DLUser currentUser].isLogin) {
        [self performSegueWithIdentifier:@"ShowMain"
                                  sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onHideKeyborad:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)onWeChat:(id)sender
{
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (object) {
            DLUser *user = [[[DLUser alloc] init] autorelease];
            user.displayName = object[@"username"];
            user.headerURL = object[@"avatar"];
            [DLUser setCurrentUser:user];
            [self performSegueWithIdentifier:@"ShowMain"
                                      sender:self];
        }
        else {
            NSLog(@"%@", error);
        }

    }
                         toPlatform:AVOSCloudSNSQQ];
}

- (IBAction)onWeibo:(id)sender
{
    [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
        if (object) {
            DLUser *user = [[[DLUser alloc] init] autorelease];
            //if ([object integerForKey:@"platform"] == AVOSCloudSNSSinaWeibo) {
            user.displayName = object[@"username"];
            user.headerURL = object[@"avatar"];
            //}
            [DLUser setCurrentUser:user];

            [self performSegueWithIdentifier:@"ShowMain"
                                      sender:self];
        }
        else {
            NSLog(@"%@", error);
        }

    }
                         toPlatform:AVOSCloudSNSSinaWeibo];
    
}


@end
