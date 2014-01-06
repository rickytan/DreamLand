//
//  DLAlarmViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLAlarmViewController.h"
#import "RTSiderViewController.h"
#import "DLTimePlate.h"

@interface DLAlarmViewController ()
@property (nonatomic, assign) IBOutlet UILabel * wakeUpLabel;
@property (nonatomic, assign) IBOutlet UILabel * timeLabel;
@property (nonatomic, assign) IBOutlet UILabel * ampmLabel;
- (IBAction)onMusic:(UIButton *)button;
- (IBAction)onLeft:(id)sender;
- (IBAction)onTimeChanged:(DLTimePlate *)timePlate;
@end

@implementation DLAlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.alarmPeriod = 30;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.alarmPeriod = 30;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:YES];
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

- (IBAction)onTimeChanged:(DLTimePlate *)timePlate
{
    self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", timePlate.hour, timePlate.minute];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"HH:mm";
    NSDate *time = [formatter dateFromString:self.timeLabel.text];
    time = [time dateByAddingTimeInterval:-30*60];
    NSDateComponents *component = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                    fromDate:time];
    NSInteger hour = component.hour;
    NSInteger minute = component.minute;
    self.wakeUpLabel.text = [NSString stringWithFormat:@"%d:%02d - - %d:%02d %s", hour, minute, timePlate.hour, timePlate.minute, timePlate.isAM ? "AM" : "PM"];
}

@end
