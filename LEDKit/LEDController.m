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
#import <sys/socket.h>
#import <arpa/inet.h>
#import <CFNetwork/CFNetwork.h>

NSString *const LEDControllerStateDidChangedNotification = @"LEDControllerStateDidChangedNotification";
NSString *const LEDControllerDeviceInfoDidUpdatedNotification = @"LEDControllerDeviceInfoDidUpdatedNotification";

@interface LEDController () <NSStreamDelegate>
{
    struct sockaddr           _address;
    int                       _socketfd;
    
    CFSocketRef                 _socket;
    
    CFReadStreamRef             _readStream;
    CFWriteStreamRef            _writeStream;
    NSInputStream             * _inputStream;
    NSOutputStream            * _outputStream;
    
    NSMutableData             * _writeData;
    NSMutableData             * _readData;
    
    
    struct {
        unsigned int isColorUpdated:1;
        unsigned int isModeUpdated:1;
        unsigned int isSpeedUpdated:1;
        unsigned int isLuminanceUpdated:1;
        unsigned int isPowerUpdated:1;
        unsigned int isPauseUpdated:1;
    } _flags;
}
@property (nonatomic, retain) NSError * error;
- (void)_writeData;
- (void)_readData;
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
        _state = LEDControllerStateNotConnected;
    }
    return self;
}

- (id)initWithDevice:(LEDDevice *)device
{
    self = [self init];
    if (self) {
        self.device = device;
    }
    return self;
}

- (void)dealloc
{
    [self _close];
    CFRelease(_readStream);
    CFRelease(_writeStream);
    
    self.error  = nil;
    self.color  = nil;
    self.device = nil;
    
    [super dealloc];
}

- (void)_readData
{
    uint8_t buffer[512] = {0};
    while (_inputStream.hasBytesAvailable) {
        NSInteger bytesRead = [_inputStream read:buffer
                                       maxLength:512];
        if (bytesRead < 0) {
            NSLog(@"Read Error!");
            
            break;
        }
        
        if (!_readData)
            _readData = [[NSMutableData alloc] init];
        [_readData appendBytes:buffer
                        length:bytesRead];
    }
}

- (void)_writeData
{
    while (_outputStream.hasSpaceAvailable && _writeData.length > 0) {
        NSInteger bytesWrite = [_outputStream write:_writeData.bytes
                                          maxLength:_writeData.length];
        if (bytesWrite < 0) {
            NSLog(@"Write Error!");
            
            break;
        }
        [_writeData replaceBytesInRange:NSMakeRange(0, bytesWrite)
                              withBytes:NULL
                                 length:0];
    }
}

- (void)sendData:(const void *)bytes length:(NSInteger)len
{
    if (!_writeData)
        _writeData = [[NSMutableData alloc] init];
    
    [_writeData appendBytes:bytes
                     length:len];
    [self _writeData];
}

- (BOOL)receiveData:(void *)buffer length:(NSInteger)len
{
    if (_readData.length >= len) {
        memcpy(buffer, _readData.bytes, len);
        [_readData replaceBytesInRange:NSMakeRange(0, len)
                             withBytes:NULL
                                length:0];
        return YES;
    }
    return NO;
}

- (void)_processData
{
    static BOOL isProcessing = NO;
    
    if (isProcessing)
        return;
    isProcessing = YES;
    
    uint8_t result[11] = {0};
    while ([self receiveData:result
                      length:11]) {
        if ((result[0] == 102) &&
            (result[10] == (unsigned char)-103))
        {
            _on    = result[2] == 35;
            _mode  = (-36 + result[3]);
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
        }
        if ([self.delegate respondsToSelector:@selector(LEDControllerDeviceInfoDidUpdated:)])
            [self.delegate LEDControllerDeviceInfoDidUpdated:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:LEDControllerDeviceInfoDidUpdatedNotification
                                                            object:self];
    }
    isProcessing = NO;
}

- (void)_close
{
    [_inputStream close];
    _inputStream = nil;
    [_outputStream close];
    _outputStream = nil;
    
    self.state = LEDControllerStateNotConnected;
}

- (void)_tryConnect
{
    [_inputStream close];
    [_outputStream close];
    
    self.state = LEDControllerStateConnecting;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)self.device.address, self.device.port, &_readStream, &_writeStream);
    _inputStream = (NSInputStream *)_readStream;
    _outputStream = (NSOutputStream *)_writeStream;
    
    if (_inputStream && _outputStream) {
        _inputStream.delegate = self;
        _outputStream.delegate = self;
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
        self.on = YES;
    }
    else
        self.state = LEDControllerStateError;
}

- (void)connect
{
    if (self.state != LEDControllerStateConnected)
        [self _tryConnect];
}

/*
 - (BOOL)connect
 {
 _socketfd = socket(AF_INET, SOCK_STREAM, 0);
 if (_socketfd == -1)
 return NO;
 
 struct sockaddr_in *address = (struct sockaddr_in*)&_address;
 address->sin_family      = AF_INET;
 address->sin_port        = htons(self.device.port);
 address->sin_addr.s_addr = inet_addr([self.device.address UTF8String]);
 
 
 // if (bind(_socketfd, _address, sizeof(_address))) {
 // return NO;
 / }
 
 
 int flags = fcntl(_socketfd, F_GETFL,0);
 fcntl(_socketfd,F_SETFL, flags | O_NONBLOCK);
 
 if (connect(_socketfd, &(_address), sizeof(_address)) == -1) {
 
 fd_set          fdwrite;
 struct timeval  timeout;
 
 FD_ZERO(&fdwrite);
 FD_SET(_socketfd, &fdwrite);
 timeout.tv_sec = DEVICE_CONNECTION_TIMEOUT;
 timeout.tv_usec = 0;
 
 if (select(_socketfd + 1,NULL, &fdwrite, NULL, &timeout) < 0) {
 
 switch (errno) {
 case EBADF:
 NSLog(@"参数sockfd 非合法socket处理代码");
 break;
 case EFAULT:
 NSLog(@"参数serv_addr指针指向无法存取的内存空间");
 break;
 case ENOTSOCK:
 NSLog(@"参数sockfd为一文件描述词，非socket。");
 break;
 case EISCONN:
 NSLog(@"参数sockfd的socket已是连线状态");
 break;
 case ECONNREFUSED:
 NSLog(@"连线要求被server端拒绝。");
 break;
 case ETIMEDOUT:
 NSLog(@"企图连线的操作超过限定时间仍未有响应。");
 break;
 case ENETUNREACH:
 NSLog(@"无法传送数据包至指定的主机。");
 break;
 case EAFNOSUPPORT:
 NSLog(@"sockaddr结构的sa_family不正确。");
 break;
 case EALREADY:
 NSLog(@"socket为不可阻塞且先前的连线操作还未完成。");
 break;
 default:
 NSLog(@"未知错误。");
 break;
 }
 [self disconnect];
 return NO;
 }
 }
 
 return YES;
 }
 */

- (void)setState:(LEDControllerState)state
{
    if (_state != state) {
        _state = state;
        if ([self.delegate respondsToSelector:@selector(LEDControllerStateDidChanged:)])
            [self.delegate LEDControllerStateDidChanged:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:LEDControllerStateDidChangedNotification
                                                            object:self];
    }
}

- (BOOL)isConnected
{
    return (self.state == LEDControllerStateConnected);
}

- (void)disconnect
{
    [self _close];
    close(_socketfd);
    _socketfd = -1;
}

- (BOOL)sendCommand:(unsigned char *)data
             length:(NSUInteger)length
{
    ssize_t size = send(_socketfd, data, length, 0);
    return size == length;
}

- (NSData *)fetchDataWithCommand:(unsigned char *)data length:(NSUInteger)lenght
{
    if ([self sendCommand:data
                   length:lenght]) {
        unsigned char buffer[256] = {0};
        NSMutableData *fetchedData = [NSMutableData data];
        while (YES) {
            int count = recv(_socketfd, buffer, sizeof(buffer), 0);
            if (count >= 0)
                [fetchedData appendBytes:buffer
                                  length:count];
            if (count < sizeof(buffer))
                break;
        }
        
        return [NSData dataWithData:fetchedData];
    }
    return nil;
}

- (void)updateDeviceInfo
{
    unsigned char command[] = {-17,1,119};
    [self sendData:command
            length:sizeof(command)];
    [self performSelectorInBackground:@selector(_processData)
                           withObject:nil];
}

/*
- (BOOL)updateDeviceInfo
{
    unsigned char command[] = {-17,1,119};
    NSData *data = [self fetchDataWithCommand:command
                                       length:sizeof(command)];
    
    const unsigned char *result = data.bytes;
    if (result) {
        NSLog(@"%d%d%d%d", result[0], result[10], result[3], result[4]);
        if ((result[0] == 102) &&
            (result[10] == (unsigned char)-103))
        {
            _on    = result[2] == 35;
            _mode  = (-36 + result[3]);
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
    }
    return NO;
}
 */

/*
- (void)updateDeviceInfoWithBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL success = [self updateDeviceInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
                callback(success);
        });
    });
}
 */

#pragma mark - getter & setter

- (void)setColor:(UIColor *)color
{
    if (_color != color) {
        [_color release];
        _color                = [color retain];
        _flags.isColorUpdated = 1;
        
        const CGFloat * comp  = CGColorGetComponents(_color.CGColor);
        unsigned char data[5] = {0};
        data[0]               = 86;
        data[1]               = (char)(comp[0] * 255);
        data[2]               = (char)(comp[1] * 255);
        data[3]               = (char)(comp[2] * 255);
        data[4]               = -86;
        
        [self sendData:data
                length:sizeof(data)];
        
//        [self sendCommand:data
//                   length:sizeof(data)];
    }
}

- (void)setColor:(UIColor *)color withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.color = color;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
                callback(YES);
        });
    });
}

//- (UIColor*)color
//{
//    if (!_flags.isColorUpdated)
//        [self updateDeviceInfo];
//    return _color;
//}

- (void)setLuminance:(NSInteger)luminance
{
    _luminance = luminance;
    
    unsigned char data[3] = {86, _luminance, -86};
    [self sendData:data
            length:sizeof(data)];
    
//    [self sendCommand:data
//               length:sizeof(data)];
}

- (void)setLuminance:(NSInteger)luminance withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.luminance = luminance;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
                callback(YES);
        });
    });
}

- (void)setMode:(NSInteger)mode
{
    _mode = mode;
    
    unsigned char data[] = {-69, 36 + _mode, _speed, 68};
    [self sendData:data
            length:sizeof(data)];
    
//    [self sendCommand:data
//               length:sizeof(data)];
    
}

- (void)setMode:(NSInteger)mode withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mode = mode;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
                callback(YES);
        });
    });
}

//- (NSInteger)mode
//{
//    if (!_flags.isModeUpdated)
//        [self updateDeviceInfo];
//    return _mode;
//}

- (void)setSpeed:(NSInteger)speed
{
    _speed = speed;
    
    unsigned char data[] = {-69, 36 + _mode, _speed, 68};
    [self sendData:data
            length:sizeof(data)];
    
//    [self sendCommand:data
//               length:sizeof(data)];
}

- (void)setSpeed:(NSInteger)speed withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.speed = speed;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
                callback(YES);
        });
    });
}

//- (NSInteger)speed
//{
//    if (!_flags.isSpeedUpdated)
//        [self updateDeviceInfo];
//    return _speed;
//}

- (void)setOn:(BOOL)on
{
    _on = on;
    
    unsigned char data[] = {-52, _on ? 35 : 36, 51};
    [self sendData:data
            length:sizeof(data)];
    
//    [self sendCommand:data
//               length:sizeof(data)];
}

- (void)setOn:(BOOL)on withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.on = on;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback)
                callback(YES);
        });
    });
}

- (void)setPause:(BOOL)pause
{
    _pause = pause;
    
    unsigned char data[] = {-52, _pause ? 32 : 33, 51};
    [self sendData:data
            length:sizeof(data)];
    
//    [self sendCommand:data
//               length:sizeof(data)];
}

- (void)setPause:(BOOL)pause withBlock:(LEDControllerCallback)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.pause = pause;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(YES);
            }
        });
    });
}

#pragma mark - NSStream Delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            self.state = LEDControllerStateConnected;
            break;
        case NSStreamEventHasBytesAvailable:
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
            [self _writeData];
            break;
        case NSStreamEventEndEncountered:
            break;
        case NSStreamEventErrorOccurred:
            self.state = LEDControllerStateError;
            self.error = aStream.streamError;
            break;
        case NSStreamEventNone:
            break;
        default:
            break;
    }
}

@end
