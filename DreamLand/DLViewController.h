//
//  DLViewController.h
//  DreamLand
//
//  Created by ricky on 13-5-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTGraphHostingView.h"
#import "DLHistoryListViewController.h"

@class RTPulseWaveView;
@class S7GraphView;
@class CPTGraphHostingView;

typedef enum {
    DLViewStateNormal,
    DLViewStateRecording,
    DLViewStatePaused,
    DLViewStateViewing,
}DLViewState;

@interface DLViewController : UIViewController <DLHistoryListDelegate>
@property (nonatomic, assign) IBOutlet RTPulseWaveView *pulseView;
@property (nonatomic, assign) IBOutlet UIView *contentView;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *startItem;
@property (nonatomic, assign) IBOutlet UIBarButtonItem *doneItem;
@property (nonatomic, assign) DLViewState state;
- (IBAction)onStart:(UIBarButtonItem*)sender;
- (IBAction)onDone:(UIBarButtonItem*)sender;
@end
