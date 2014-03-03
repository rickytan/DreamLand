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
#import "DLAlarm.h"
#import "DLWeeklyAlerm.h"
#import "NSUserDefaults+Settings.h"

@interface DLAlarmViewController ()
@property (nonatomic, assign) IBOutlet UILabel * wakeUpLabel;
@property (nonatomic, assign) IBOutlet UILabel * timeLabel;
@property (nonatomic, assign) IBOutlet UILabel * ampmLabel;
@property (nonatomic, assign) IBOutlet DLTimePlate * timePlate;
@property (nonatomic, assign) IBOutlet DLWeeklyAlerm * weekDay;
@property (nonatomic, assign) IBOutlet UIButton * musicButton;
- (IBAction)onMusic:(UIButton *)button;
- (IBAction)onLeft:(id)sender;
- (IBAction)onTimeChanged:(DLTimePlate *)timePlate;
- (IBAction)onWeekdayChanged:(DLWeeklyAlerm *)weekday;
@end

@implementation DLAlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.alarmPeriod = [DLAlarm sharedAlarm].alarmRange;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.alarmPeriod = [DLAlarm sharedAlarm].alarmRange;
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

    self.timePlate.hour = [DLAlarm sharedAlarm].hour;
    self.timePlate.minute = [DLAlarm sharedAlarm].minute;
    [self onTimeChanged:self.timePlate];
    
    self.weekDay.selectedWeekday = [DLAlarm sharedAlarm].selectedWeekdays;
    self.musicButton.selected = [NSUserDefaults standardUserDefaults].isAlarmMusicOn;
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
    [NSUserDefaults standardUserDefaults].alarmMusicOn = button.selected;
}

- (IBAction)onWeekdayChanged:(DLWeeklyAlerm *)weekday
{
    [DLAlarm sharedAlarm].selectedWeekdays = weekday.selectedWeekday;
}

- (IBAction)onTimeChanged:(DLTimePlate *)timePlate
{
    [DLAlarm sharedAlarm].hour = timePlate.hour + (timePlate.isAM ? 0 : 12);
    [DLAlarm sharedAlarm].minute = timePlate.minute;

    self.timeLabel.text = [NSString stringWithFormat:@"%d:%02d", timePlate.hour, timePlate.minute];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"HH:mm";
    NSDate *time = [formatter dateFromString:self.timeLabel.text];
    time = [time dateByAddingTimeInterval:-[DLAlarm sharedAlarm].alarmRange*60];
    NSDateComponents *component = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                    fromDate:time];
    NSInteger hour = component.hour;
    NSInteger minute = component.minute;
    self.wakeUpLabel.text = [NSString stringWithFormat:@"%d:%02d - %d:%02d %s", hour, minute, timePlate.hour, timePlate.minute, timePlate.isAM ? "AM" : "PM"];
}

@end
