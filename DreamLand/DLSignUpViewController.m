//
//  DLSignUpViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-24.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLSignUpViewController.h"

@interface DLSignUpViewController () <UIActionSheetDelegate>
@property (nonatomic, assign) IBOutlet UIButton *photoButton;
- (IBAction)onDismiss:(id)sender;
- (IBAction)onJoin:(id)sender;
@end

@implementation DLSignUpViewController

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
    self.photoButton.layer.borderColor = [UIColor colorWithRed:54.0/255
                                                         green:56.0/255
                                                          blue:67.0/255
                                                         alpha:1.0].CGColor;
    [self.photoButton setImage:[UIImage imageNamed:@"photo.png"]
                      forState:UIControlStateNormal];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (IBAction)onJoin:(id)sender
{
    
}

- (IBAction)onPhoto:(id)sender
{
    [[[UIActionSheet alloc] initWithTitle:@"How would you like to set your photo? "
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Take Photo", @"Choose From Library", nil] showInView:self.view];
}

@end
