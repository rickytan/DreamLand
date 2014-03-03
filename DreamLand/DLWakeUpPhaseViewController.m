//
//  DLWakeUpPhaseViewController.m
//  DreamLand
//
//  Created by ricky on 14-2-18.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLWakeUpPhaseViewController.h"
#import "NSUserDefaults+Settings.h"

@interface DLWakeUpPhaseViewCell : UITableViewCell
@end

@implementation DLWakeUpPhaseViewCell

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.textLabel.highlighted = selected;
}

@end

@implementation DLWakeUpPhaseViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger indices[] = {(10), (15), (20), (30), (45)};
    NSInteger index = 0;
    for (; index < sizeof(indices) / sizeof(NSInteger); ++index) {
        if ((NSInteger)[NSUserDefaults standardUserDefaults].wakeUpPhase == indices[index])
            break;
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                            inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indices[] = {(10), (15), (20), (30), (45)};
    [NSUserDefaults standardUserDefaults].wakeUpPhase = indices[indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
