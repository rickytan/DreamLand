//
//  DLSignInViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-25.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSignInViewController.h"
#import "DLUser.h"
#import <ShareSDK/ShareSDK.h>

@interface DLSignInViewController () <ISSViewDelegate>
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
    double delayInSeconds = .1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController performSegueWithIdentifier:@"ShowGuide"
                                                       sender:self];
    });
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
    id<ISSAuthOptions> options = [ShareSDK authOptionsWithAutoAuth:YES
                                                     allowCallback:YES
                                                            scopes:nil
                                                     powerByHidden:YES
                                                    followAccounts:nil
                                                     authViewStyle:SSAuthViewStyleFullScreenPopup
                                                      viewDelegate:self
                                           authManagerViewDelegate:self];
    [ShareSDK getUserInfoWithType:ShareTypeWeixiSession
                      authOptions:options
                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                               if (result) {

                               }
                               else {
                                   NSLog(@"%d %@", [error errorCode], [error errorDescription]);
                               }
                           }];
}

- (IBAction)onWeibo:(id)sender
{
    id<ISSAuthOptions> options = [ShareSDK authOptionsWithAutoAuth:YES
                                                     allowCallback:YES
                                                            scopes:nil
                                                     powerByHidden:YES
                                                    followAccounts:nil
                                                     authViewStyle:SSAuthViewStyleFullScreenPopup
                                                      viewDelegate:self
                                           authManagerViewDelegate:self];
    [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
                      authOptions:options
                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                               if (result) {
                                   DLUser *user = [[[DLUser alloc] init] autorelease];
                                   user.displayName = [userInfo nickname];
                                   user.headerURL = [userInfo icon];
                                   [DLUser setCurrentUser:user];
                                   
                                   [self performSegueWithIdentifier:@"ShowMain"
                                                             sender:self];
                               }
                               else {
                                   NSLog(@"%@", error);
                               }
                           }];

}

#pragma mark - ISSView Delegate

- (void)viewOnWillDisplay:(UIViewController *)viewController
                shareType:(ShareType)shareType
{

}

- (void)viewOnWillDismiss:(UIViewController *)viewController
                shareType:(ShareType)shareType
{
    
}

- (void)view:(UIViewController *)viewController
autorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
   shareType:(ShareType)shareType
{
    
}


@end
