//
//  DLViewController.h
//  DreamLand
//
//  Created by ricky on 13-5-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTGraphHostingView.h"

@class RTPulseWaveView;
@class S7GraphView;
@class CPTGraphHostingView;

@interface DLViewController : UIViewController
@property (nonatomic, assign) IBOutlet RTPulseWaveView *pulseView;
@property (nonatomic, assign) IBOutlet UIView *contentView;
@property (nonatomic, assign) IBOutlet CPTGraphHostingView *graphHostingView;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *startItem;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *doneItem;
- (IBAction)onStart:(UIBarButtonItem*)sender;
- (IBAction)onDone:(UIBarButtonItem*)sender;
@end
