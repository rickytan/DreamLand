//
//  DLDialPlate.h
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLDialPlate : UIControl
@property (nonatomic, assign) CGFloat radius;           // Defalut ((MIN(width, height) - strokeWidth) / 2)
@property (nonatomic, assign) CGFloat strokeWidth;      // Default 4.0
@property (nonatomic, retain) UIColor *strokeColor;     // Defalut Black
@property (nonatomic, retain) UIColor *strokeBackgroundColor;   // Defalut White
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGFloat stepAngle;        // Default 0.0
@property (nonatomic, assign) BOOL clockWise;           // Default YES
@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) UIImage *shadowImage;
@property (nonatomic, assign) UIEdgeInsets contentInsets;   // Default zero

- (void)setThumbImage:(UIImage *)image;
@end
