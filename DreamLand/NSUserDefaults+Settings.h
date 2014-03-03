//
//  NSUserDefaults+Settings.h
//  DreamLand
//
//  Created by ricky on 14-1-20.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Settings)

@property (nonatomic, assign, getter = isAlarmMusicOn) BOOL alarmMusicOn;
@property (nonatomic, assign, getter = isSoundOn) BOOL soundOn;
@property (nonatomic, assign, getter = isLightOn) BOOL lightOn;
@property (nonatomic, assign) NSTimeInterval wakeUpPhase;

@end
