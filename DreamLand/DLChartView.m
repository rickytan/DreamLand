//
//  DLChartView.m
//  DreamLand
//
//  Created by ricky on 14-3-4.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLChartView.h"

@implementation DLChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setChartImage:(UIImage *)chartImage
{
    if (_chartImage != chartImage) {
        [_chartImage release];
        _chartImage = [chartImage retain];

        UIImageView *image = (UIImageView *)[self viewWithTag:222];
        if (!image) {
            image = [[[UIImageView alloc] init] autorelease];
            image.tag = 222;
            [self addSubview:image];
        }
        image.image = _chartImage;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [[self viewWithTag:222] sizeToFit];
}

- (CGRect)rectForRowLabels:(CGRect)rect
{
    return CGRectMake(0, 0, 80, self.frame.size.height);
}

- (CGRect)rectForColLabels:(CGRect)rect
{
    return CGRectMake(0, self.frame.size.height - 36, self.frame.size.width, 36);
}

- (CGRect)rectForChart:(CGRect)rect
{
    return CGRectMake(80, 0, self.frame.size.width - 80, self.frame.size.height - 36);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
}


@end
