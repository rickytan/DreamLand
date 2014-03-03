//
//  DLWeeklyAlerm.h
//  DreamLand
//
//  Created by ricky on 14-2-16.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DLWeekday) {
    DLWeekdaySunday     = 0x1 << 0,
    DLWeekdayMonday     = 0x1 << 1,
    DLWeekdayTuesday    = 0x1 << 2,
    DLWeekdayWednesday  = 0x1 << 3,
    DLWeekdayThursday   = 0x1 << 4,
    DLWeekdayFriday     = 0x1 << 5,
    DLWeekdaySaturday   = 0x1 << 6,
    DLWeekdayWeekend    = DLWeekdaySunday | DLWeekdaySaturday,
    DLWeekdayWorkday    = 0x7f ^ DLWeekdaySaturday ^ DLWeekdaySunday,
    DLWeekdayAll        = 0x7f,
};

@interface DLWeeklyAlerm : UIControl
@property (nonatomic, assign) DLWeekday selectedWeekday;
@end
