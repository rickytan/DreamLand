//
//  LEDFinder.h
//  DreamLand
//
//  Created by ricky on 13-7-26.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEDDevice;
@class LEDFinder;

@protocol LEDFinderDelegate <NSObject>
@optional
- (void)finderDidFindDevice:(LEDDevice *)device;
- (void)finderDidUpdateDeviceInfo:(LEDDevice *)device;

@end

@interface LEDFinder : NSObject
@property (nonatomic, assign) id<LEDFinderDelegate> delegate;
@property (nonatomic, readonly, getter = isScanning) BOOL scanning;
@property (nonatomic, readonly) NSUInteger numberOfCurrentFoundDevices;

- (void)startScanWithDelegate:(id<LEDFinderDelegate>)delegate;
- (void)stopScan;

@end
