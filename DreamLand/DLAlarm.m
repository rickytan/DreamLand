//
//  DLAlarm.m
//  DreamLand
//
//  Created by ricky on 14-3-2.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLAlarm.h"
#import "DLWeeklyAlerm.h"

static DLAlarm *theAlarm = nil;

@implementation DLAlarm

+ (id)alarmWithHour:(NSInteger)hour
          andMinute:(NSInteger)minute
{
    return [self alarmWithHour:hour
                     andMinute:minute
                repeatWeekdays:DLWeekdayWorkday];
}

+ (id)alarmWithHour:(NSInteger)hour
          andMinute:(NSInteger)minute
     repeatWeekdays:(NSUInteger)selectedWeekdays
{
    DLAlarm *alarm = [[[DLAlarm alloc] init] autorelease];
    alarm.hour             = hour;
    alarm.minute           = minute;
    alarm.selectedWeekdays = selectedWeekdays;
    alarm.alarmRange       = 30.0*60;
    alarm.snoozeDuration   = 10.0*60;
    alarm.alarmSound       = [[NSBundle mainBundle] pathForResource:@"alarm_sound_1"
                                                       ofType:@"mp3"];
    return alarm;
}

+ (instancetype)sharedAlarm
{

    return theAlarm;
}

- (NSDate *)nextAlarmDate
{
    return nil;
}

@end
