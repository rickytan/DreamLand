//
//  DLCustomPlaceholderColorTextField.m
//  DreamLand
//
//  Created by ricky on 13-12-24.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLCustomPlaceholderColorTextField.h"

@implementation DLCustomPlaceholderColorTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
- (void)drawPlaceholderInRect:(CGRect)rect
{
    [self.placeholderColor setFill];
    CGSize size = [self.placeholder sizeWithFont:self.font];
    rect.origin.y = (rect.size.height - size.height) / 2;
    [self.placeholder drawInRect:rect
                        withFont:self.font];
}

@end
