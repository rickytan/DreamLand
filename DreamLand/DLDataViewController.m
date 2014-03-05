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
@property (nonatomic, retain) IBOutlet DLDayDataView *dayData;

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
    self.dayData = nil;
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
    [self setupHourRangeLabels];
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

- (void)setupHourRangeLabels
{
    for (int i=0; i < 9; ++i) {
        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        label.text = [NSString stringWithFormat:@"%02d", i];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        label.center = CGPointMake(56 + i * 28, 507);
        [self.dayData addSubview:label];
    }
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
    dataView.hidden = NO;

    NSMutableAttributedString *attString = nil;

    attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%2d%%\nEfficiency", [self.data[index][@"Efficiency"] intValue]]];
    [attString addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold"
                                                                    size:23]}
                       range:NSMakeRange(0, 2)];
    [attString addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light"
                                                                    size:15]}
                       range:NSMakeRange(2, 1)];
    [attString addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin"
                                                                    size:11]}
                       range:NSMakeRange(3, 11)];
    dataView.efficiencyLabel.attributedText = attString;
    [attString release];

    dataView.curveView.curveImage = [UIImage imageNamed:[NSString stringWithFormat:@"曲线%d.png", index + 1]];
    return dataView;
}


@end
