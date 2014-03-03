//
//  DLStartViewController.m
//  DreamLand
//
//  Created by ricky on 14-2-23.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLStartViewController.h"
#import "UIView+DL.h"
#import "DLAlarm.h"
#import "NSUserDefaults+Settings.h"

@interface DLStartViewController ()
@property (nonatomic, assign) IBOutlet UILabel     * slideLabel;
@property (nonatomic, assign) IBOutlet UIImageView * pinImage;
@property (nonatomic, assign) IBOutlet UILabel     * chargerLabel;
@property (nonatomic, assign) IBOutlet UILabel     * wakeUpLabel;
@property (nonatomic, assign) IBOutlet UILabel     * timeLabel;
@property (nonatomic, retain) UIColor              * origColor;
@end

@implementation DLStartViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChargingStateChanged)
                                                 name:UIDeviceBatteryStateDidChangeNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self setupWakeUpLabel];
    [self.slideLabel startShining];

    [self onChargingStateChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.origColor = self.navigationController.navigationBar.backgroundColor;
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.navigationController.navigationBar.backgroundColor = [UIColor colorWithWhite:1
                                                                                                     alpha:0.5];
                     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.navigationController.navigationBar.backgroundColor = self.origColor;
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onChargingStateChanged
{
    if ([UIDevice currentDevice].batteryState != UIDeviceBatteryStateUnplugged) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
        anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.pinImage.center.x, self.pinImage.center.y + 32)];
        anim.duration = 1.5;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeIn.fromValue = [NSNumber numberWithFloat:0];
        fadeIn.toValue = [NSNumber numberWithFloat:1];
        fadeIn.duration = .5;

        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[anim, fadeIn];
        group.duration = 4.0;
        group.repeatCount = CGFLOAT_MAX;
        [self.pinImage.layer addAnimation:group
                                   forKey:@"PlugIn"];
        self.chargerLabel.hidden = NO;
    }
    else {
        [self.pinImage.layer removeAnimationForKey:@"PlugIn"];
        self.chargerLabel.hidden = YES;
    }
}

- (void)setupWakeUpLabel
{

    NSString *timeString = [NSString stringWithFormat:@"%d:%02d", [DLAlarm sharedAlarm].hour, [DLAlarm sharedAlarm].minute];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"HH:mm";
    NSDate *time = [formatter dateFromString:timeString];
    time = [time dateByAddingTimeInterval:-[NSUserDefaults standardUserDefaults].wakeUpPhase*60];
    NSDateComponents *component = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                                                  fromDate:time];
    NSInteger hour = component.hour;
    NSInteger minute = component.minute;
    self.wakeUpLabel.text = [NSString stringWithFormat:@"%d:%02d - %d:%02d %s", hour, minute, [DLAlarm sharedAlarm].hour, [DLAlarm sharedAlarm].minute, "AM"];
}

@end
