//
//  DLChartView.h
//  DreamLand
//
//  Created by ricky on 14-3-4.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLChartView;

@protocol DLChartViewDatasource <NSObject>

@required
- (NSInteger)numberOfRowsInChartView:(DLChartView *)chartView;
- (NSInteger)numberOfColsInChartView:(DLChartView *)chartView;

@optional
- (UIView *)chartViewLabelForRow:(NSInteger)rowIndex;
- (UIView *)chartViewLabelForCol:(NSInteger)colIndex;

@end

@interface DLChartView : UIView
@property (nonatomic, assign) id<DLChartViewDatasource> delegate;
@property (nonatomic, retain) UIColor * rowLineColor;
@property (nonatomic, retain) UIColor * colLineColor;
@property (nonatomic, retain) UIImage * chartImage;

- (void)reloadData;
@end
