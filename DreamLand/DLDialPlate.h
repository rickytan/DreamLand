//
//  DLDialPlate.h
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLDialPlate : UIControl
@property (nonatomic, assign) CGFloat strokeWidth;      // Default 4.0
@property (nonatomic, retain) UIColor *strokeColor;     // Defalut Black
@property (nonatomic, retain) UIColor *strokeBackgroundColor;   // Defalut White
@property (nonatomic, retain) NSDate *time;

- (void)setThumbImage:(UIImage *)image;
@end
