//
//  DLTimePlate.m
//  DreamLand
//
//  Created by ricky on 13-12-31.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLTimePlate.h"
#import "DLDialPlate.h"
#import "NSDate+RExtension.h"

@implementation DLTimePlate

- (void)commonInit
{
    self.hourPlate.startAngle = 3 * M_PI_2;
    self.minutePlate.startAngle = 3 * M_PI_2;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
