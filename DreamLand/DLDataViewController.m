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
- (IBAction)onLeft:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)onShare:(id)sender;
@end

@implementation DLDataViewController

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

#pragma mark - Actions

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
