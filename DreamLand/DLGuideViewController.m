//
//  DLGuideViewController.m
//  DreamLand
//
//  Created by ricky on 13-12-20.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLGuideViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DLGuideViewController () <UIScrollViewDelegate>
@property (nonatomic, assign) IBOutlet UIPageControl * pageControl;
@property (nonatomic, assign) IBOutlet UIImageView * logoImage;
@end

@implementation DLGuideViewController

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
    
    CABasicAnimation *show = [CABasicAnimation animationWithKeyPath:@"opacity"];
    show.fromValue = [NSNumber numberWithFloat:0];
    show.duration = 1.5;
    [self.logoImage.layer addAnimation:show
                                forKey:@"Show"];
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    move.fromValue = [NSNumber numberWithFloat:-30];
    move.duration = 2.5;
    move.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.logoImage.layer addAnimation:move
                                forKey:@"Move"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.pageControl.currentPage != 2 ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - UIScroll Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self setNeedsStatusBarAppearanceUpdate];
}


@end
