//
//  DLTimePlate.h
//  DreamLand
//
//  Created by ricky on 13-12-31.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLDialPlate;

@interface DLTimePlate : UIControl
@property (nonatomic, assign) IBOutlet DLDialPlate *hourPlate;
@property (nonatomic, assign) IBOutlet DLDialPlate *minutePlate;
@property (nonatomic, retain) NSDate *time;
@end
