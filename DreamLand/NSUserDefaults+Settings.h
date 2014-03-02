//
//  NSUserDefaults+Settings.h
//  DreamLand
//
//  Created by ricky on 14-1-20.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Settings)

@property (nonatomic, assign) NSUInteger selectedWeekdays;
@property (nonatomic, assign) NSInteger alarmHour;
@property (nonatomic, assign) NSInteger alarmMinute;

- (NSArray *)e;
- (NSUInteger)selectedWeekdays;

@end
