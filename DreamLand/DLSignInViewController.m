//
//  DLSignInViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-25.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSignInViewController.h"

@interface DLSignInViewController ()

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

@end
