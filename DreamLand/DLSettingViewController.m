//
//  DLSettingViewController.m
//  DreamLand
//
//  Created by ricky on 14-2-17.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLSettingViewController.h"
#import "RTSiderViewController.h"
#import "NSUserDefaults+Settings.h"

@interface DLSettingViewController ()
- (IBAction)onLeft:(id)sender;
- (IBAction)onSound:(UISwitch *)switcher;
- (IBAction)onLight:(UISwitch *)switcher;
@end

@implementation DLSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"none.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UISwitch *s = (UISwitch *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                       inSection:0]].accessoryView;
    s.on = [NSUserDefaults standardUserDefaults].isLightOn;

    ((UISwitch *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                          inSection:0]].accessoryView).on = [NSUserDefaults standardUserDefaults].isSoundOn;
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2
                                                             inSection:0]].detailTextLabel.text = [NSString stringWithFormat:@"%d mins", (int)[NSUserDefaults standardUserDefaults].wakeUpPhase];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)onLeft:(id)sender
{
    [self.siderViewController slideToRightAnimated:YES];
}

- (IBAction)onSound:(UISwitch *)switcher
{
    [NSUserDefaults standardUserDefaults].soundOn = switcher.isOn;
}

- (IBAction)onLight:(UISwitch *)switcher
{
    [NSUserDefaults standardUserDefaults].lightOn = switcher.isOn;
}


@end
