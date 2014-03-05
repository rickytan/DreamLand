//
//  DLDayDataView.h
//  DreamLand
//
//  Created by ricky on 14-3-5.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLDataCurveView.h"

@interface DLDayDataView : UIView
@property (nonatomic, assign) IBOutlet DLDataCurveView * curveView;
@property (nonatomic, assign) IBOutlet UIButton * heartButton;
@property (nonatomic, assign) IBOutlet UILabel * dateLabel;
@property (nonatomic, assign) IBOutlet UILabel * durationLabel;
@property (nonatomic, assign) IBOutlet UILabel * totalLabel;
@property (nonatomic, assign) IBOutlet UILabel * timeInBedLabel;
@property (nonatomic, assign) IBOutlet UILabel * bedTimeLabel;
@property (nonatomic, assign) IBOutlet UILabel * efficiencyLabel;
@end
