//
//  DLAlarm.m
//  DreamLand
//
//  Created by ricky on 14-3-2.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLAlarm.h"
#import "DLWeeklyAlerm.h"
#import "NSUserDefaults+Settings.h"

static DLAlarm *theAlarm = nil;

@implementation DLAlarm
{
    NSTimer                 * _fireTimer, * _rangeTimer;
    NSDate                  * _nextFireDate;
}

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

    return alarm;
}

+ (instancetype)sharedAlarm
{
    @synchronized(self) {
        if (!theAlarm) {
            @try {
                NSData *alarmData = [[NSUserDefaults standardUserDefaults] dataForKey:@"AlarmData"];
                theAlarm = [[NSKeyedUnarchiver unarchiveObjectWithData:alarmData] retain];
            }
            @catch (NSException *exception) {
            }
            @finally {
                if (!theAlarm) {
                    theAlarm = [[self alarmWithHour:8
                                          andMinute:0] retain];
                }
            }
        }
        return theAlarm;
    }
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancel];

    self.alarmSound = nil;


    [super dealloc];
}

- (void)_saveToDisk
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data
                                              forKey:@"AlarmData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_fire
{
    if ([self.delegate respondsToSelector:@selector(alarmDidFired:)])
        [self.delegate alarmDidFired:self];

    [_fireTimer release];
    _fireTimer = nil;
}

- (void)_enterRange
{
    if ([self.delegate respondsToSelector:@selector(alarmDidEnterAlarmRange:)]) {
        [self.delegate alarmDidEnterAlarmRange:self];
    }

    [_rangeTimer release];
    _rangeTimer = nil;
}

- (void)startAlarm
{
    [self _fire];
    [self cancel];
}

- (BOOL)isRunning
{
    return _fireTimer.isValid;
}

- (void)schedule
{
    if (self.isRunning)
        return;

    [_fireTimer invalidate];
    [_fireTimer release];
    _fireTimer = [[NSTimer alloc] initWithFireDate:self.nextAlarmDate
                                          interval:0
                                            target:self
                                          selector:@selector(_fire)
                                          userInfo:nil
                                           repeats:NO];

    [_rangeTimer invalidate];
    [_rangeTimer release];
    _rangeTimer = [[NSTimer alloc] initWithFireDate:self.nextAlarmDate
                                           interval:-[NSUserDefaults standardUserDefaults].wakeUpPhase
                                             target:self
                                           selector:@selector(_enterRange)
                                           userInfo:nil
                                            repeats:NO];

}

- (void)cancel
{
    [_fireTimer invalidate];
    [_fireTimer release];
    _fireTimer = nil;

    [_rangeTimer invalidate];
    [_rangeTimer release];
    _rangeTimer = nil;
}

- (NSDate *)nextAlarmDate
{
    if (!_nextFireDate) {
        NSDate *alarmDate = [NSDate date];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comp = [cal components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit
                                        fromDate:alarmDate];
        NSInteger daysToAdd = 0;
        NSInteger extraDay = 0;
        if (comp.hour > self.hour || comp.minute > self.minute) {   // 还是当天
            extraDay = 1;
        }
        if (self.selectedWeekdays) {
            for (int i=0; i < 7 && !(self.selectedWeekdays & (0x1 << ((i + comp.weekday - 1 + extraDay) % 7))); ++i, ++daysToAdd) {
                // Nothing
            }
        }
        daysToAdd += extraDay;


        comp.hour = self.hour;
        comp.minute = self.minute;
        comp.day += daysToAdd;
        _nextFireDate = [[cal dateFromComponents:comp] retain];
    }
    return _nextFireDate;
}

- (void)setHour:(NSInteger)hour
{
    if (_hour != hour) {
        _hour = hour;
        [self cancel];

        [_nextFireDate release];
        _nextFireDate = nil;
    }
}

- (void)setMinute:(NSInteger)minute
{
    if (_minute != minute) {
        _minute = minute;
        [self cancel];

        [_nextFireDate release];
        _nextFireDate = nil;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        self.hour             = 8;
        self.minute           = 0;
        self.selectedWeekdays = DLWeekdayWorkday;
        self.snoozeDuration   = 10.0*60;
        self.alarmSound       = [[NSBundle mainBundle] pathForResource:@"alarm_sound_1"
                                                                ofType:@"mp3"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_saveToDisk)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.hour             = [aDecoder decodeIntegerForKey:@"Hour"];
        self.minute           = [aDecoder decodeIntegerForKey:@"Minute"];
        self.selectedWeekdays = [aDecoder decodeIntegerForKey:@"Weekdays"];
        self.alarmSound       = [aDecoder decodeObjectForKey:@"Sound"];
        self.snoozeDuration   = [aDecoder decodeDoubleForKey:@"Snooze"];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_saveToDisk)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.hour
                   forKey:@"Hour"];
    [aCoder encodeInteger:self.minute
                   forKey:@"Minute"];
    [aCoder encodeInteger:self.selectedWeekdays
                   forKey:@"Weekdays"];
    [aCoder encodeObject:self.alarmSound
                  forKey:@"Sound"];
    [aCoder encodeDouble:self.snoozeDuration
                  forKey:@"Snooze"];
}

@end
