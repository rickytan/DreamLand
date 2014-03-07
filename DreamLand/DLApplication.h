//
//  DLApplication.h
//  DreamLand
//
//  Created by ricky on 14-3-1.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLApplication : UIApplication

@property (nonatomic, readonly, getter = isLightConnected) BOOL lightConnected;
- (void)searchAndConnectLight;
- (void)disconnectLight;
- (void)testLight;
- (void)lightUp;
- (void)dimDown;
- (void)setLightColor:(UIColor *)color;

@end
