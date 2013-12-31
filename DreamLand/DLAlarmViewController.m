//
//  DLAlarmViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLAlarmViewController.h"
#import "RTSiderViewController.h"

@interface DLAlarmViewController ()
- (IBAction)onMusic:(UIButton *)button;
- (IBAction)onLeft:(id)sender;
@end

@implementation DLAlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"none.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[[UIImage alloc] init] autorelease]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onLeft:(id)sender
{
    [self.siderViewController slideToRightAnimated:YES];
}

- (IBAction)onMusic:(UIButton *)button
{
    button.selected = !button.selected;
}

@end