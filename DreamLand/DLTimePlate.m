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

@interface DLTimePlate ()

- (IBAction)onHourChanged:(id)sender;
- (IBAction)onMinuteChaged:(id)sender;
@end

@implementation DLTimePlate

- (void)dealloc
{
    [super dealloc];
}

- (void)commonInit
{
    self.hourPlate.startAngle   = -M_PI_2;
    self.hourPlate.endAngle     = -M_PI_2;
    self.minutePlate.startAngle = -M_PI_2;
    self.minutePlate.endAngle   = -M_PI_2;

    self.hourPlate.strokeColor     = [UIColor colorWithRed: 0.227 green: 0.749 blue: 0.816 alpha: 1];
    self.hourPlate.strokeWidth     = 12.0;
    self.hourPlate.stepAngle       = M_PI / 6;
    self.hourPlate.backgroundImage = [UIImage imageNamed:@"circle-small.png"];
    self.hourPlate.shadowImage     = [UIImage imageNamed:@"circle-small-shadow.png"];
    self.hourPlate.radius          = 90.0;
    self.hourPlate.contentInsets   = UIEdgeInsetsMake(-1, 0, 1, 0);

    self.minutePlate.strokeColor     = self.hourPlate.strokeColor;
    self.minutePlate.strokeWidth     = 4.0;
    self.minutePlate.stepAngle       = M_PI / 6;
    [self.minutePlate setThumbImage:[UIImage imageNamed:@"small dot.png"]];
    self.minutePlate.backgroundImage = [UIImage imageNamed:@"circle-big.png"];
    self.minutePlate.shadowImage     = [UIImage imageNamed:@"circle-big-shadow.png"];
    self.minutePlate.radius          = 135.0;
    self.minutePlate.contentInsets   = UIEdgeInsetsMake(2, -2, -3.5, 2);

    self.isAM = YES;
    self.hour = 0;
    self.minute = 0;
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

#pragma mark - Actions

- (void)setHour:(NSInteger)hour
{
    NSAssert(0 <= hour && hour < 12, @"Hour out of Range!");
    _hour = hour;
    self.hourPlate.endAngle = -M_PI + _hour * M_PI / 6 + M_PI_2;
}

- (void)setMinute:(NSInteger)minute
{
    NSAssert(0 <= minute && minute < 60, @"Minute out of Range!");
    _minute = minute;
    self.minutePlate.endAngle = -M_PI + _minute * M_PI / 30 + M_PI_2;
}

- (IBAction)onHourChanged:(id)sender
{
    NSInteger v = self.hour;
    if (self.hourPlate.endAngle <= -M_PI_2)
        _hour = floorf((self.hourPlate.endAngle) / M_PI * 6) + 15;
    else
        _hour = floorf((self.hourPlate.endAngle) / M_PI * 6) + 3;
    if (self.hour == 12)
        _hour = 0;
    if (self.hour != v) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (IBAction)onMinuteChaged:(id)sender
{
    NSInteger v = self.minute;
    if (self.minutePlate.endAngle <= -M_PI_2)
        _minute = floorf(self.minutePlate.endAngle / M_PI * 30) + 75;
    else
        _minute = floorf(self.minutePlate.endAngle / M_PI * 30) + 15;
    if (self.minute == 60)
        _minute = 0;
    if (self.minute != v) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
