//
//  DLAlarm.h
//  DreamLand
//
//  Created by ricky on 14-3-2.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLWeeklyAlerm.h"

@class DLAlarm;

@protocol DLAlarmDelegate <NSObject>

- (void)alarmDidFired:(DLAlarm *)alarm;
- (void)alarmDidEnterAlarmRange:(DLAlarm *)alarm;

@end

@interface DLAlarm : NSObject <NSCoding>
@property (nonatomic, assign)   NSInteger hour     ,  minute;
@property (nonatomic, assign)   NSUInteger            selectedWeekdays;
@property (nonatomic, readonly) NSDate              * nextAlarmDate;
@property (nonatomic, assign)   NSTimeInterval        snoozeDuration;   // Default 10 * 60 seconds
@property (nonatomic, assign, readonly, getter = isRunning) BOOL running;
@property (nonatomic, assign)   id<DLAlarmDelegate >  delegate;

+ (instancetype)alarmWithHour:(NSInteger)hour andMinute:(NSInteger)minute;
+ (instancetype)alarmWithHour:(NSInteger)hour andMinute:(NSInteger)minute repeatWeekdays:(NSUInteger)selectedWeekdays;

+ (instancetype)sharedAlarm;

- (void)schedule;
- (void)cancel;

- (void)startAlarm;

@end
