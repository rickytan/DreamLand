//
//  DLForgotViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-27.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLForgotViewController.h"

@interface DLForgotViewController ()
@property (nonatomic, assign) IBOutlet UITextField *emailField;
- (IBAction)onBack:(id)sender;
- (IBAction)onSend:(id)sender;
@end

@implementation DLForgotViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emailField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)onSend:(id)sender
{
    
}

- (IBAction)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

#pragma mark - Table view data source

@end
