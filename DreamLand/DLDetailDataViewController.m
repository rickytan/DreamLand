//
//  DLDetailDataViewController.m
//  DreamLand
//
//  Created by ricky on 14-3-3.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLDetailDataViewController.h"

@interface DLDetailDataViewController ()
- (IBAction)onDismiss:(id)sender;
@end

@implementation DLDetailDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{

                             }];
}

@end
