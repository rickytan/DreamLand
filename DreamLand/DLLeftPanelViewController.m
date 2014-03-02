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
#import "DLApplication.h"
#import "LEDKit.h"
#import "YHWeather.h"

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
@property (nonatomic, assign) IBOutlet UILabel   * lightStateLabel;

@property (nonatomic, assign) BOOL                 shouldTestLight;
@property (nonatomic, assign) BOOL                 connectionTriggled;
@property (nonatomic, retain) NSString           * lightState;
@property (nonatomic, retain) NSIndexPath        * currentSelected;
@property (nonatomic, retain) YHWeather          * weather;
@property (nonatomic, retain) Weather            * weatherData;
- (void)onSignOut:(id)sender;
@end

@implementation DLLeftPanelViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.weather = nil;
    self.weatherData = nil;
    self.currentSelected = nil;

    [super dealloc];
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lightConnectionStateChanged:)
                                                 name:LEDControllerStateDidChangedNotification
                                               object:nil];
    self.shouldTestLight = YES;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self awakeFromNib];
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

    if (!self.weather) {
        self.weather = [[[YHWeather alloc] init] autorelease];
        [self updateWeather];
    }

    if (!self.lightState) {
        self.lightState = ((DLApplication *)[UIApplication sharedApplication]).isLightConnected ? @"Light Connected!" : @"Light Not Connected";
    }

    if (self.weatherData)
        [self showWeatherInfo:self.weatherData];
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

#pragma mark - Methods

- (void)setLightState:(NSString *)lightState
{
    if (_lightState != lightState) {
        [_lightState release];
        _lightState = [lightState retain];
        self.lightStateLabel.text = _lightState;
        if ([_lightState isEqualToString:@"Light Connected!"]) {
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            anim.duration = 1.5;
            anim.toValue = (id)[UIColor redColor].CGColor;
            anim.autoreverses = YES;
            anim.repeatCount = CGFLOAT_MAX;
            [self.lightStateLabel.layer addAnimation:anim
                                              forKey:@"Blink"];
        }
        else {
            [self.lightStateLabel.layer removeAnimationForKey:@"Blink"];
        }
    }
}

- (void)setConnectionTriggled:(BOOL)connectionTriggled
{
    if (_connectionTriggled != connectionTriggled) {
        _connectionTriggled = connectionTriggled;
        CGFloat inset = _connectionTriggled ? 32 : 0;
        [UIView animateWithDuration:0.35
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.tableView.contentInset = UIEdgeInsetsMake(inset, 0, 0, 0);
                             self.tableView.contentOffset = CGPointZero;
                         }
                         completion:NULL];
    }
}

- (void)lightConnectionStateChanged:(NSNotification *)notification
{
    LEDController *controller = (LEDController *)notification.object;
    switch (controller.state) {
        case LEDControllerStateConnected:
            self.connectionTriggled = NO;
            self.lightState = @"Light Connected!";
            if (self.shouldTestLight) {
                self.shouldTestLight = NO;
                [((DLApplication *)[UIApplication sharedApplication]) testLight];
            }
            break;
        case LEDControllerStateConnecting:
            self.lightState = @"Connecting...";
            break;
        case LEDControllerStateError:
        case LEDControllerStateNotConnected:
            self.connectionTriggled = NO;
            self.lightState = @"Light Not Connected";
            break;
        default:
            break;
    }
}

- (void)showWeatherInfo:(Weather *)info
{
    self.locationLabel.text = info.city;
    NSInteger temp = [info.currentCondition[@"temp"] integerValue];
    temp = (temp - 32) / 1.8;
    self.infoLabel.text = [NSString stringWithFormat:@"%@ %d˚C", info.currentCondition[@"text"], temp];
}

- (void)updateWeather
{
    self.locationLabel.text = @"updating...";
    self.infoLabel.text = nil;
    [self.weather weatherForCurrentLocationWithCompleteBlock:^(Weather *data, NSError *error) {
        if (error) {
            [self performSelector:@selector(updateWeather)
                       withObject:nil
                       afterDelay:5.0];
            self.locationLabel.text = @"Error!";
        }
        else {
            self.weatherData = data;
            [self showWeatherInfo:self.weatherData];
            [self performSelector:@selector(updateWeather)
                       withObject:nil
                       afterDelay:30 * 60];
        }
    }];
}

#pragma mark - Scroll Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!((DLApplication *)[UIApplication sharedApplication]).isLightConnected &&
        !self.connectionTriggled) {
        if (scrollView.contentOffset.y < -32.0) {
            self.lightStateLabel.text = @"Release to connect";
        }
        else if (scrollView.contentOffset.y < 0.0) {
            self.lightStateLabel.text = @"Pull to connect";
        }
        else {
            self.lightStateLabel.text = self.lightState;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!((DLApplication *)[UIApplication sharedApplication]).isLightConnected &&
        scrollView.contentOffset.y < -32) {
        self.connectionTriggled = YES;

        [((DLApplication *)[UIApplication sharedApplication]) searchAndConnectLight];
    }
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
        return 188;
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
            UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingNav"];
            [self.siderViewController setMiddleViewController:vc
                                                     animated:YES];
        }
            
            break;
        default:
            break;
    }
}

@end
