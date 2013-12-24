//
//  DLDateField.m
//  DreamLand
//
//  Created by ricky on 13-12-24.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDateField.h"

@implementation DLDateField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)inputView
{
    if (![super inputView]) {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
        picker.datePickerMode = UIDatePickerModeDate;
        self.inputView = picker;
        [picker release];
    }
    return [super inputView];
}

- (BOOL)resignFirstResponder
{
    UIDatePicker *picker = (UIDatePicker*)self.inputView;
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"yyyy-MM-dd";
    self.text = [formatter stringFromDate:picker.date];
    return [super resignFirstResponder];
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
