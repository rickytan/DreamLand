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

typedef NS_ENUM(NSInteger, LEDControllerState) {
    LEDControllerStateNotConnected      = 0,
    LEDControllerStateConnecting,
    LEDControllerStateConnected,
    LEDControllerStateError
};

@class LEDController;

extern NSString *const LEDControllerStateDidChangedNotification;
extern NSString *const LEDControllerDeviceInfoDidUpdatedNotification;

@protocol LEDControllerDelegate <NSObject>

- (void)LEDControllerStateDidChanged:(LEDController *)controller;
- (void)LEDControllerDeviceInfoDidUpdated:(LEDController *)controller;

@end

@interface LEDController : NSObject

@property (nonatomic, retain)                    LEDDevice * device;
@property (nonatomic, assign, readonly)          BOOL        isConnected;
@property (nonatomic, assign) LEDControllerState             state;
@property (nonatomic, readonly) NSError                    * error;
@property (nonatomic, assign) id<LEDControllerDelegate>      delegate;
@property (nonatomic, retain, readwrite)         UIColor   * color;
@property (nonatomic, assign)                    NSInteger   mode;          // 1~20, 21 is custom mode
@property (nonatomic, assign)                    NSInteger   speed;         // 1~31
@property (nonatomic, assign)                    NSInteger   luminance;     // 0~100
@property (nonatomic, assign, getter = isOn)     BOOL        on;
@property (nonatomic, assign, getter = isPaused) BOOL        pause;

- (id)initWithDevice:(LEDDevice*)device;

- (void)connect;
- (void)disconnect;

- (void)updateDeviceInfo;
//- (void)updateDeviceInfoWithBlock:(LEDControllerCallback)callback;

- (void)setMode:(NSInteger)mode withBlock:(LEDControllerCallback)callback;
- (void)setColor:(UIColor*)color withBlock:(LEDControllerCallback)callback;
- (void)setSpeed:(NSInteger)speed withBlock:(LEDControllerCallback)callback;
- (void)setOn:(BOOL)on withBlock:(LEDControllerCallback)callback;
- (void)setPause:(BOOL)pause withBlock:(LEDControllerCallback)callback;
- (void)setLuminance:(NSInteger)luminance withBlock:(LEDControllerCallback)callback;

@end
