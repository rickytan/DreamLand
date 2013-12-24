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

- (void)dealloc
{
    self.options = nil;
    self.optionItems = nil;
    [super dealloc];
}

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
        picker.showsSelectionIndicator = YES;
        self.inputView = picker;
        [picker release];
    }
    return [super inputView];
}

- (BOOL)resignFirstResponder
{
    UIPickerView *picker = (UIPickerView*)self.inputView;
    self.text = self.optionItems[[picker selectedRowInComponent:0]];
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

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.optionItems[row];
}

@end
