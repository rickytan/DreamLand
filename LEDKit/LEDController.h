//
//  LEDController.h
//  DreamLand
//
//  Created by ricky on 13-7-26.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEDDevice.h"

#define DEVICE_CONNECTION_TIMEOUT   5

typedef void (^LEDControllerCallback)(BOOL success);

@interface LEDController : NSObject

@property (nonatomic, retain)                    LEDDevice * device;
@property (nonatomic, assign, readonly)          BOOL        isConnected;
@property (nonatomic, retain, readwrite)         UIColor   * color;
@property (nonatomic, assign)                    NSInteger   mode;
@property (nonatomic, assign)                    NSInteger   speed;
@property (nonatomic, assign)                    NSInteger   luminance;
@property (nonatomic, assign, getter = isOn)     BOOL        on;
@property (nonatomic, assign, getter = isPaused) BOOL        pause;

- (id)initWithDevice:(LEDDevice*)device;

- (BOOL)connect;
- (void)disconnect;

- (BOOL)updateDeviceInfo;
- (void)updateDeviceInfoWithBlock:(LEDControllerCallback)callback;

- (void)setMode:(NSInteger)mode withBlock:(LEDControllerCallback)callback;
- (void)setColor:(UIColor*)color withBlock:(LEDControllerCallback)callback;
- (void)setSpeed:(NSInteger)speed withBlock:(LEDControllerCallback)callback;
- (void)setOn:(BOOL)on withBlock:(LEDControllerCallback)callback;
- (void)setPause:(BOOL)pause withBlock:(LEDControllerCallback)callback;
- (void)setLuminance:(NSInteger)luminance withBlock:(LEDControllerCallback)callback;

@end
