//
//  LEDController.m
//  DreamLand
//
//  Created by ricky on 13-7-26.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "LEDController.h"
#import "LEDDevice.h"
#import <netinet/in.h>
#import <CFNetwork/CFNetwork.h>

@interface LEDController ()
{
    struct sockaddr         * _address;
    int                       _socketfd;
    
    struct {
        unsigned int isColorUpdated:1;
        unsigned int isModeUpdated:1;
        unsigned int isSpeedUpdated:1;
        unsigned int isLuminanceUpdated:1;
        unsigned int isPowerUpdated:1;
        unsigned int isPauseUpdated:1;
    } _flags;
}

- (BOOL)sendCommand:(unsigned char *)data
             length:(NSUInteger)length;
- (NSData*)fetchDataWithCommand:(unsigned char *)data
                         length:(NSUInteger)lenght;

@end

@implementation LEDController
@synthesize color = _color;
@synthesize on = _on;
@synthesize mode = _mode;
@synthesize pause = _pause;
@synthesize luminance = _luminance;
@synthesize speed = _speed;

- (id)init
{
    self = [super init];
    if (self) {
        _socketfd = -1;
    }
    return self;
}

- (id)initWithDevice:(LEDDevice *)device
{
    [self init];
    self.device = device;
    return self;
}

- (BOOL)connect
{
    _socketfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (_socketfd == -1)
        return NO;
    
    struct sockaddr_in *address = (struct sockaddr_in*)&_address;
    address->sin_family = AF_INET;
    address->sin_port = htons(self.device.port);
    address->sin_addr.s_addr = inet_addr([self.device.address UTF8String]);
    
    /*
     if (bind(_socketfd, _address, sizeof(_address))) {
     return NO;
     }
     */
    if (connect(_socketfd, _address, sizeof(_address))) {
        [self disconnect];
        return NO;
    }
    
    return YES;
}

- (BOOL)isConnected
{
    return (_socketfd != -1);
}

- (void)disconnect
{
    close(_socketfd);
    _socketfd = -1;
}

- (BOOL)sendCommand:(unsigned char *)data
             length:(NSUInteger)length
{
    return send(_socketfd, data, length, 0) == length;
}

- (NSData *)fetchDataWithCommand:(unsigned char *)data length:(NSUInteger)lenght
{
    if ([self sendCommand:data
                   length:lenght]) {
        unsigned char buffer[256] = {0};
        NSMutableData *fetchedData = [NSMutableData data];
        while (YES) {
            int count = recv(_socketfd, buffer, sizeof(buffer), 0);
            [fetchedData appendBytes:buffer
                              length:count];
            if (count < sizeof(buffer))
                break;
        }
        
        return [NSData dataWithData:fetchedData];
    }
    return nil;
}

- (BOOL)updateDeviceInfo
{
    static unsigned char command[] = {-17,1,119};
    NSData *data = [self fetchDataWithCommand:command
                                       length:sizeof(command)];
    
    const unsigned char *result = data.bytes;
    
    if ((result[0] == 102) &&
        (result[10] == -103))
    {
        _on = result[2] == 35;
        _mode = (-36 + result[3]);
        _pause = result[4] == 32;
        _speed = result[5];
        
        CGFloat comp[4] = {
            1.0 * result[6] / 255,
            1.0 * result[7] / 255,
            1.0 * result[8] / 255,
            1.0
        };
        
        [_color release];
        _color = [[UIColor colorWithRed:comp[0]
                                  green:comp[1]
                                   blue:comp[2]
                                  alpha:comp[3]] retain];
        _flags.isColorUpdated = 1;
        _flags.isLuminanceUpdated = 1;
        _flags.isModeUpdated = 1;
        _flags.isSpeedUpdated = 1;
        _flags.isPauseUpdated = 1;
        _flags.isPowerUpdated = 1;
        
        return YES;
    }
    return NO;
}

- (void)updateDeviceInfoWithBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL success = [self updateDeviceInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(success);
        });
    });
}

#pragma mark - getter & setter

- (void)setColor:(UIColor *)color
{
    if (_color != color) {
        [_color release];
        _color = [color retain];
        _flags.isColorUpdated = 1;
        
        const CGFloat * comp = CGColorGetComponents(_color.CGColor);
        unsigned char data[5] = {0};
        data[0] = 86;
        data[1] = (char)(comp[0] * 255);
        data[2] = (char)(comp[1] * 255);
        data[3] = (char)(comp[2] * 255);
        data[4] = -86;
        
        [self sendCommand:data
                   length:sizeof(data)];
    }
}

- (void)setColor:(UIColor *)color withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.color = color;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES);
        });
    });
}

- (UIColor*)color
{
    if (!_flags.isColorUpdated)
        [self updateDeviceInfo];
    return _color;
}

- (void)setLuminance:(NSInteger)luminance
{
    _luminance = luminance;
    
    unsigned char data[3] = {86, _luminance, -86};
    [self sendCommand:data
               length:sizeof(data)];
}

- (void)setLuminance:(NSInteger)luminance withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.luminance = luminance;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES);
        });
    });
}

- (void)setMode:(NSInteger)mode
{
    _mode = mode;
    
    unsigned char data[4] = {-69, 36 + _mode, _speed, 68};
    [self sendCommand:data
               length:sizeof(data)];
    
}

- (void)setMode:(NSInteger)mode withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mode = mode;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES);
        });
    });
}

- (NSInteger)mode
{
    if (!_flags.isModeUpdated)
        [self updateDeviceInfo];
    return _mode;
}

- (void)setSpeed:(NSInteger)speed
{
    _speed = speed;
    
    unsigned char data[4] = {-69, 36 + _mode, _speed, 68};
    [self sendCommand:data
               length:sizeof(data)];
}

- (void)setSpeed:(NSInteger)speed withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.speed = speed;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES);
        });
    });
}

- (NSInteger)speed
{
    if (!_flags.isSpeedUpdated)
        [self updateDeviceInfo];
    return _speed;
}

- (void)setOn:(BOOL)on
{
    _on = on;
    
    unsigned char data[4] = {-52, _on ? 35 : 36, 51};
    [self sendCommand:data
               length:sizeof(data)];
}

- (void)setOn:(BOOL)on withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.on = on;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES);
        });
    });
}

- (void)setPause:(BOOL)pause
{
    _pause = pause;
    
    unsigned char data[4] = {-52, _pause ? 32 : 33, 51};
    [self sendCommand:data
               length:sizeof(data)];
}

- (void)setPause:(BOOL)pause withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.pause = pause;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(YES);
        });
    });
}


@end
