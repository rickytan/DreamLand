//
//  DLDataViewController.m
//  DreamLand
//
//  Created by ricky on 14-1-7.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLDataViewController.h"
#import "DLSiderViewController.h"

@interface DLDataViewController () <UIActionSheetDelegate>
@property (nonatomic, assign) IBOutlet UIButton *emotionButton;
@property (nonatomic, assign) NSInteger currentEmotion;

- (IBAction)onLeft:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onShare:(id)sender;
- (IBAction)onEmotion:(id)sender;
@end

@implementation DLDataViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [self.view addSubview:label];
    }
}

#pragma mark - Actions

- (void)onRotate:(NSNotification *)notification
{
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        
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

@end
