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
{
    NSTimer                 * _fireTimer, _rangeTimer;
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
    
}

- (void)schedule
{
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
                                           interval:-self.alarmRange
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
    NSDate *alarmDate = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                    fromDate:alarmDate];
    if (comp.hour > self.hour || comp.minute > self.minute) {   // 还是当天

        ++comp.day;
    }
    comp.hour = self.hour;
    comp.minute = self.minute;
    return [cal dateFromComponents:comp];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.hour             = 8;
        self.minute           = 0;
        self.selectedWeekdays = DLWeekdayWorkday;
        self.alarmRange       = 30.0*60;
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
        self.alarmRange       = [aDecoder decodeDoubleForKey:@"Range"];
        self.snoozeDuration   = [aDecoder decodeDoubleForKey:@"Snooze"];
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
    [aCoder encodeDouble:self.alarmRange
                  forKey:@"Range"];
    [aCoder encodeDouble:self.snoozeDuration
                  forKey:@"Snooze"];
}

@end
