//
//  DLLeftPanelViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLLeftPanelViewController.h"
#import "DLSiderViewController.h"
#import "DLUser.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface DLLeftPanelCell : UITableViewCell
@end

@implementation DLLeftPanelCell

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.textLabel.highlighted = selected;
}

- (void)setHighlighted:(BOOL)highlighted
              animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.textLabel.highlighted = highlighted;
}

@end

@interface DLLeftPanelViewController ()
@property (nonatomic, assign) IBOutlet UIButton  * headerButton;
@property (nonatomic, assign) IBOutlet UILabel   * nameLabel;
@property (nonatomic, assign) IBOutlet UILabel   * locationLabel;
@property (nonatomic, assign) IBOutlet UILabel   * infoLabel;
@property (nonatomic, retain) NSIndexPath        * currentSelected;
- (void)onSignOut:(id)sender;
@end

@implementation DLLeftPanelViewController

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
    self.clearsSelectionOnViewWillAppear = NO;
    self.currentSelected = [NSIndexPath indexPathForRow:0
                                              inSection:0];
    [self.tableView selectRowAtIndexPath:self.currentSelected
                                animated:NO
                          scrollPosition:UITableViewScrollPositionNone];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([DLUser currentUser].headerImage) {
        [self.headerButton setImage:[DLUser currentUser].headerImage
                           forState:UIControlStateNormal];
    }
    else {
        [self.headerButton setImageWithURL:[NSURL URLWithString:[DLUser currentUser].headerURL]
                                  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"photo.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                     [DLUser currentUser].headerImage = image;
                                 }];
    }

    if ([DLUser currentUser].displayName) {
        self.nameLabel.text = [DLUser currentUser].displayName;
    }
    else {
        self.nameLabel.text = @"Not Login";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)onSignOut:(id)sender
{
    [DLUser setCurrentUser:nil];
    [self.siderViewController.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3)
        return 198;
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 51;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row < 3) {
        NSArray *images = @[[UIImage imageNamed:@"alam.png"], [UIImage imageNamed:@"data"], [UIImage imageNamed:@"setting"]];
        NSArray *titles = @[@"ALARM", @"DATA", @"SETTING"];
        cell.imageView.image = images[indexPath.row];
        cell.textLabel.text = titles[indexPath.row];
    }
    else {
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView
viewForFooterInSection:(NSInteger)section
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    button.frame = CGRectMake(0, 0, 320, 51);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button setTitle:@"Sign Out"
            forState:UIControlStateNormal];
    [button setTitleColor:THEME_COLOR
                 forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(onSignOut:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.currentSelected isEqual:indexPath])
        return;
    
    self.currentSelected = indexPath;
    switch (indexPath.row) {
        case 0:
        {
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AlarmNav"];
            [self.siderViewController setMiddleViewController:vc
                                                     animated:YES];
        }
            break;
        case 1:
        {
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DataNav"];
            [self.siderViewController setMiddleViewController:vc
                                                     animated:YES];
        }

            break;
        case 2:
        {
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DataNav"];
            [self.siderViewController setMiddleViewController:vc
                                                     animated:YES];
        }

            break;
        default:
            break;
    }
}

@end
