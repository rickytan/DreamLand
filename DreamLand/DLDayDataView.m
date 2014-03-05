//
//  DLDayDataView.m
//  DreamLand
//
//  Created by ricky on 14-3-5.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLDayDataView.h"

@implementation DLDayDataView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupHourRangeLabels];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupHourRangeLabels];
}

- (void)setupHourRangeLabels
{
    for (int i=0; i < 9; ++i) {
        UILabel *label = [[[UILabel alloc] init] autorelease];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        label.text = [NSString stringWithFormat:@"%02d", i];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        label.center = CGPointMake(56 + i * 28, 147);
        [self addSubview:label];
    }
}

@end
