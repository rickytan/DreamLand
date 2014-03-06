//
//  DLDataViewController.m
//  DreamLand
//
//  Created by ricky on 14-1-7.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLDataViewController.h"
#import "DLSiderViewController.h"
#import "DLDayDataView.h"
#import "RSlideView.h"

@interface DLDataViewController () <UIActionSheetDelegate, RSlideViewDataSource, RSlideViewDelegate>
@property (nonatomic, assign) IBOutlet UIButton *emotionButton;
@property (nonatomic, assign) NSInteger currentEmotion;
@property (nonatomic, assign) IBOutlet RSlideView *slideView;
@property (nonatomic, assign) IBOutlet UILabel *dateLabel, *durationLabel, *efficiencyLabel;

@property (nonatomic, retain) NSMutableArray * data;

- (IBAction)onLeft:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onShare:(id)sender;
- (IBAction)onEmotion:(id)sender;
@end

@implementation DLDataViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.data = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

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
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"none.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[[UIImage alloc] init] autorelease]];
    [self updateEmotion];

    [self.data removeAllObjects];
    for (int i=0; i < 6; ++i) {
        [self.data addObject:@{@"Duration": [NSNumber numberWithDouble:5 * 60 + random() % 300],
                               @"Efficiency": [NSNumber numberWithFloat:60 + random() % 40],
                               @"Date": [NSDate dateWithTimeIntervalSinceNow:(i - 6) * 24 * 3600],
                               @"Emotion": [NSNumber numberWithInt: random() % 3]}];
    }
    [self.slideView reloadData];
    [self.slideView scrollToPageAtIndex:self.data.count - 1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
                                                animated:YES];
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

- (UIImage *)currentEmotionImage
{
    NSArray *arr = @[@"emotion-normal.png", @"emotion-good.png", @"emotion-bad.png"];
    return [UIImage imageNamed:arr[self.currentEmotion]];
}

- (void)updateEmotion
{
    [self.emotionButton setImage:[self currentEmotionImage]
                        forState:UIControlStateNormal];
}

- (NSMutableArray *)data
{
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

#pragma mark - Actions

- (void)onRotate:(NSNotification *)notification
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        if (!self.presentedViewController)
            [self performSegueWithIdentifier:@"DetailData"
                                      sender:self];
    }
    else {
        if (self.presentedViewController)
            [self dismissViewControllerAnimated:YES
                                     completion:^{

                                     }];
    }
}

- (IBAction)onEmotion:(id)sender
{
    self.currentEmotion = (self.currentEmotion + 1) % 3;
    [self updateEmotion];
}

- (IBAction)onLeft:(id)sender
{
    [self.siderViewController slideToRightAnimated:YES];
}

- (IBAction)onDelete:(id)sender
{
    [[[[UIActionSheet alloc] initWithTitle:nil
                                  delegate:self
                         cancelButtonTitle:@"Cancel"
                    destructiveButtonTitle:@"Delete this day"
                         otherButtonTitles:nil] autorelease] showInView:self.view];
}

- (IBAction)onShare:(id)sender
{
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[@"Test Content", [UIImage imageNamed:@"Icon-120.png"], [NSURL URLWithString:@"http://www.google.com"], [[NSBundle mainBundle] URLForResource:@"start"
                                                                                                                                                                                                                                  withExtension:@"caf"]]
                                                                           applicationActivities:nil];
    activity.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    [self presentViewController:activity
                       animated:YES
                     completion:^{

                     }];
    [activity release];
}

#pragma mark - RSlide Datasource & Delegate

- (NSInteger)RSlideViewNumberOfPages
{
    return self.data.count;
}

- (UIView *)RSlideView:(RSlideView *)slideView
    viewForPageAtIndex:(NSInteger)index
{
    DLDayDataView * dataView = (DLDayDataView *)[self.slideView dequeueReusableView];
    if (!dataView) {
        // make a copy form Xib
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DLDayDataView"
                                                     owner:self
                                                   options:nil];
        dataView = [arr lastObject];
    }
    dataView.curveView.curveImage = [UIImage imageNamed:[NSString stringWithFormat:@"曲线%d.png", index + 1]];
    return dataView;
}

- (void)RSlideViewDidEndScrollAnimation:(RSlideView *)sliderView
{
    NSInteger emotion = [self.data[self.slideView.currentPage][@"Emotion"] intValue];
    self.currentEmotion = emotion;
    [self updateEmotion];

    NSMutableAttributedString *attString = nil;

    attString = [[self.efficiencyLabel.attributedText mutableCopy] autorelease];
    [attString replaceCharactersInRange:NSMakeRange(0, 2)
                             withString:[NSString stringWithFormat:@"%2d", [self.data[sliderView.currentPage][@"Efficiency"] intValue]]];
    self.efficiencyLabel.attributedText = attString;

    attString = [[self.durationLabel.attributedText mutableCopy] autorelease];
    NSRange r0 = [attString.string rangeOfString:@" hours "];
    NSRange r1 = [attString.string rangeOfString:@" minutes"];
    NSInteger h = (NSInteger)([self.data[sliderView.currentPage][@"Duration"] floatValue] / 60);
    NSInteger m = (NSInteger)(fmodf([self.data[sliderView.currentPage][@"Duration"] floatValue], 60));
    [attString replaceCharactersInRange:NSMakeRange(r0.location + r0.length, r1.location - r0.length - r0.location)
                             withString:[NSString stringWithFormat:@"%d", m]];
    [attString replaceCharactersInRange:NSMakeRange(0, r0.location)
                             withString:[NSString stringWithFormat:@"%d", h]];
    self.durationLabel.attributedText = attString;

    NSArray *months = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    NSArray *weeks = @[@"Sun.", @"Mon.", @"Tues.", @"Wed.", @"Thus.", @"Fri.", @"Sat."];
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSDayCalendarUnit
                                                             fromDate:self.data[sliderView.currentPage][@"Date"]];
    NSInteger today = comp.day;
    NSInteger yestoday = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                         fromDate:[NSDate dateWithTimeInterval:-24*3600
                                                                                     sinceDate:self.data[self.slideView.currentPage][@"Date"]]].day;
    self.dateLabel.text = [NSString stringWithFormat:@"%2d-%2d %@ / %@", yestoday, today, months[comp.month-1], weeks[comp.weekday-1]];

}

@end
