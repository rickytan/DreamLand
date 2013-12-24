//
//  DLOptionField.m
//  DreamLand
//
//  Created by ricky on 13-12-24.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLOptionField.h"

@interface DLOptionField () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, retain) NSArray *optionItems;
@end

@implementation DLOptionField

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
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
        picker.dataSource = self;
        picker.delegate = self;
        self.inputView = picker;
    }
    return [super inputView];
}

- (BOOL)resignFirstResponder
{
    
    return [super resignFirstResponder];
}

- (void)setOptions:(NSString *)options
{
    if (_options != options) {
        [_options release];
        _options = [options retain];
        self.optionItems = [options componentsSeparatedByString:@";"];
    }
}

#pragma mark - UIPicker Datasource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.optionItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.optionItems[row];
}

@end
