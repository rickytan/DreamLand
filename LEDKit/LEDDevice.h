//
//  LEDDevice.h
//  DreamLand
//
//  Created by ricky on 13-7-26.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_DEVICE_PORT        5577

typedef enum {
    LEDDeviceTypeRGB,
    LEDDeviceTypeLuminance,
} LEDDeviceType;

@interface LEDDevice : NSObject

- (id)initWithIP:(NSString*)IP;
- (id)initWithIP:(NSString *)IP
            port:(NSUInteger)port;
- (id)initWithIP:(NSString *)IP port:(NSUInteger)port name:(NSString*)name;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, assign) LEDDeviceType type;

+ (id)deviceWithIP:(NSString*)IP;
+ (id)deviceWithIP:(NSString *)IP port:(NSUInteger)port;
+ (id)deviceWithIP:(NSString *)IP port:(NSUInteger)port name:(NSString*)name;

@end
