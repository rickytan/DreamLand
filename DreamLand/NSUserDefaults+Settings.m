//
//  NSUserDefaults+Settings.m
//  DreamLand
//
//  Created by ricky on 14-1-20.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "NSUserDefaults+Settings.h"
#import "UIApplication+RExtension.h"

@implementation NSUserDefaults (Settings)

- (NSDictionary *)settingsDictionary
{
    NSMutableDictionary *settings = [self valueForKey:[UIApplication sharedApplication].appBundleID];
    if (!settings) {
        settings = [[@{@"AlarmMusicOn": [NSNumber numberWithBool:YES],
                       @"SoundOn": [NSNumber numberWithBool:YES],
                       @"LightOn": [NSNumber numberWithBool:YES],
                       @"WakeUpPhase": [NSNumber numberWithDouble:30],
                       @"AlarmMusic": [[NSBundle mainBundle] pathForResource:@"alarm_sound_1"
                                                                      ofType:@"mp3"],
                       @"SnoozeDuration": [NSNumber numberWithDouble:10*60]} mutableCopy] autorelease];
        [self setObject:settings
                 forKey:[UIApplication sharedApplication].appBundleID];
        [self synchronize];
    }
    return settings;
}

- (BOOL)isAlarmMusicOn
{
    return [[[self settingsDictionary] objectForKey:@"AlarmMusicOn"] boolValue];
}

- (void)setAlarmMusicOn:(BOOL)alarmMusicOn
{
    [[self settingsDictionary] setValue:[NSNumber numberWithBool:alarmMusicOn]
                                 forKey:@"AlarmMusicOn"];
    [self synchronize];
}

- (BOOL)isSoundOn
{
    return [[[self settingsDictionary] objectForKey:@"SoundOn"] boolValue];
}

- (void)setSoundOn:(BOOL)soundOn
{
    [[self settingsDictionary] setValue:[NSNumber numberWithBool:soundOn]
                                 forKey:@"SoundOn"];
    [self synchronize];
}

- (BOOL)isLightOn
{
    return [[[self settingsDictionary] objectForKey:@"LightOn"] boolValue];
}

- (void)setLightOn:(BOOL)lightOn
{
    [[self settingsDictionary] setValue:[NSNumber numberWithBool:lightOn]
                                 forKey:@"LightOn"];
    [self synchronize];
}

- (NSTimeInterval)wakeUpPhase
{
    return [[[self settingsDictionary] objectForKey:@"WakeUpPhase"] doubleValue];
}

- (void)setWakeUpPhase:(NSTimeInterval)wakeUpPhase
{
    [[self settingsDictionary] setValue:[NSNumber numberWithDouble:wakeUpPhase]
                                 forKey:@"WakeUpPhase"];
    [self synchronize];
}

- (void)setAlarmMusic:(NSString *)alarmMusic
{
    [[self settingsDictionary] setValue:alarmMusic
                                 forKey:@"AlarmMusic"];
    [self synchronize];
}

- (NSString *)alarmMusic
{
    return [[self settingsDictionary] objectForKey:@"AlarmMusic"];
}

- (void)setSnoozeDuration:(NSTimeInterval)snoozeDuration
{
    [[self settingsDictionary] setValue:[NSNumber numberWithDouble:snoozeDuration]
                                 forKey:@"SnoozeDuration"];
    [self synchronize];
}

- (NSTimeInterval)snoozeDuration
{
    return [[[self settingsDictionary] objectForKey:@"SnoozeDuration"] doubleValue];
}

@end
