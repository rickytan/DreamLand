//
//  DLSignInViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-25.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSignInViewController.h"
#import <ShareSDK/ShareSDK.h>

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
    [self performSegueWithIdentifier:@"ShowGuide"
                              sender:self];
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
    [ShareSDK authWithType:ShareTypeWeixiSession
                   options:nil
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {
                        if (state == SSAuthStateSuccess) {

                        }
                        else if (state == SSAuthStateFail) {

                        }
                    }];
}

- (IBAction)onWeibo:(id)sender
{
    [ShareSDK authWithType:ShareTypeSinaWeibo
                   options:nil
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {
                        if (state == SSAuthStateSuccess) {

                        }
                        else if (state == SSAuthStateFail) {

                        }
                    }];
}

@end
