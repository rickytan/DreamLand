//
//  DLWeeklyAlerm.m
//  DreamLand
//
//  Created by ricky on 14-2-16.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLWeeklyAlerm.h"
#import <QuartzCore/QuartzCore.h>

static NSString *weekDay[] = {@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"};

@implementation DLWeeklyAlerm

- (void)commonInit
{
    for (int i=0; i < 7; ++i) {
        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.tag = i;
        label.text = weekDay[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightTextColor];
        label.backgroundColor = [UIColor clearColor];
        label.layer.borderWidth = .5;
        label.layer.borderColor = [UIColor colorWithRed:112.0/255
                                                  green:94.0/255
                                                   blue:117.0/255
                                                  alpha:1.0].CGColor;
        [self addSubview:label];
    }
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width / 7;
    CGFloat height = self.bounds.size.height;
    for (UIView *view in self.subviews) {
        view.frame = CGRectMake(width * view.tag, 0, width, height);
    }
}

- (void)setSelectedWeekday:(NSUInteger)selectedWeekday
{
    if (!_selectedWeekday != selectedWeekday) {
        _selectedWeekday = selectedWeekday;
        [self setNeedsDisplay];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat width = self.bounds.size.width / 7;

    [[UIColor colorWithRed:112.0/255
                     green:94.0/255
                      blue:117.0/255
                     alpha:1.0] set];
    for (int i=0; i < 7; ++i) {
        if (self.selectedWeekday & (0x1 << i))
            CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(i * width, 0, width, 6));
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch
                   withEvent:(UIEvent *)event
{
    CGPoint p = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, p))
        return;

    CGFloat width = self.bounds.size.width / 7;
    NSInteger day = (NSInteger)floorf(p.x / width);
    self.selectedWeekday ^= (0x1 << day);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
}

@end
