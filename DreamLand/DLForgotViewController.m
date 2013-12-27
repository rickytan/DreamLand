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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
