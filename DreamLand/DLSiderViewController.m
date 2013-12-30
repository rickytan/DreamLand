//
//  DLSiderViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSiderViewController.h"

@interface DLSiderViewController () <RTSiderViewControllerDatasource>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.dataSource = self;
    [self setMiddleViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AlarmNav"]];
    [self setLeftViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Settings"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
