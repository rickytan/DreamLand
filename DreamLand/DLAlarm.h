//
//  DLAlarm.h
//  DreamLand
//
//  Created by ricky on 14-3-2.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DLWeeklyAlerm;

@interface DLAlarm : NSObject
@property (nonatomic, assign)   NSInteger hour ,  minute;
@property (nonatomic, assign)   NSUInteger        selectedWeekdays;
@property (nonatomic, retain)   NSString        * alarmSound;
@property (nonatomic, readonly) NSDate          * nextAlarmDate;
@property (nonatomic, assign)   NSTimeInterval    snoozeDuration;   // Default 10 minutes
@property (nonatomic, assign)   NSTimeInterval    alarmRange;       // Default 30 minutes

+ (instancetype)alarmWithHour:(NSInteger)hour andMinute:(NSInteger)minute;
+ (instancetype)alarmWithHour:(NSInteger)hour andMinute:(NSInteger)minute repeatWeekdays:(NSUInteger)selectedWeekdays;

+ (instancetype)sharedAlarm;

- (void)schedule;
- (void)cancel;

- (void)startAlarm;
- (void)stop;

@end
