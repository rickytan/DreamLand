//
//  DLStartViewController.m
//  DreamLand
//
//  Created by ricky on 14-2-23.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLStartViewController.h"
#import "UIView+DL.h"

@interface DLStartViewController ()
@property (nonatomic, assign) IBOutlet UILabel *slideLabel;
@end

@implementation DLStartViewController

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
    [self.slideLabel startShining];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
