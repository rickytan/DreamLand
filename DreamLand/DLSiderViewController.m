//
//  DLSiderViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSiderViewController.h"

@interface DLSiderViewController () <RTSiderViewControllerDatasource, RTSiderViewControllerDelegate>

@end

@implementation DLSiderViewController

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
    return [self->_currentMiddleViewController preferredStatusBarStyle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.dataSource = self;
    self.delegate = self;
    self.allowOverDrag = NO;
    self.translationStyle = SlideTranslationStyleDeeper;
    self.middleTranslationStyle = MiddleViewTranslationStyleStay;
    [self setMiddleViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AlarmNav"]];
    [self setLeftViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Settings"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.currentMiddleViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return [self.currentMiddleViewController shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.currentMiddleViewController preferredInterfaceOrientationForPresentation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [self.currentMiddleViewController supportedInterfaceOrientations];
}

#pragma mark - RTSider Datasource

- (BOOL)shouldAdjustWidthOfLeftViewController
{
    return YES;
}

- (CGFloat)siderViewControllerMarginForSlidingToRight:(RTSiderViewController *)controller
{
    return 156;
}

- (BOOL)siderViewController:(RTSiderViewController *)controller
        canSlideToDirection:(SlideState)state
{
    if (![controller.currentMiddleViewController isKindOfClass:[UINavigationController class]] || !(controller.currentMiddleViewController.childViewControllers.count == 1))
        return NO;
    return YES;
}

@end
