//
//  DLHistoryLIstViewController.h
//  DreamLand
//
//  Created by ricky on 13-6-5.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLHistoryListViewController;

@protocol DLHistoryListDelegate <NSObject>
@optional
- (void)historyList:(DLHistoryListViewController*)controller didSelectRecord:(NSUInteger)recordID;

@end

@interface DLHistoryListViewController : UITableViewController
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *spinnerView;
@property (nonatomic, assign) IBOutlet id<DLHistoryListDelegate> delegate;
- (IBAction)onCancel:(id)sender;
@end
