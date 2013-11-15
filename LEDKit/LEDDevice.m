//
//  LEDDevice.m
//  DreamLand
//
//  Created by ricky on 13-7-26.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "LEDDevice.h"

@implementation LEDDevice

+ (id)deviceWithIP:(NSString *)IP
{
    return [self deviceWithIP:IP
                         port:DEFAULT_DEVICE_PORT];
}

+ (id)deviceWithIP:(NSString *)IP port:(NSUInteger)port
{
    return [self deviceWithIP:IP
                         port:port
                         name:nil];
}

+ (id)deviceWithIP:(NSString *)IP port:(NSUInteger)port name:(NSString *)name
{
    return [[[LEDDevice alloc] initWithIP:IP
                                     port:port
                                     name:name] autorelease];
}

- (id)initWithIP:(NSString *)IP
{
    return [self initWithIP:IP
                       port:DEFAULT_DEVICE_PORT];
}

- (id)initWithIP:(NSString *)IP
            port:(NSUInteger)port
{
    return [self initWithIP:IP port:port name:nil];
}

- (id)initWithIP:(NSString *)IP
            port:(NSUInteger)port
            name:(NSString *)name
{
    self = [super init];
    if (self) {
        self.address = IP;
        self.port = port;
        self.name = name;
    }
    return self;
}

@end
