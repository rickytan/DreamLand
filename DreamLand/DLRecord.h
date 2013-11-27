//
//  DLRecord.h
//  DreamLand
//
//  Created by ricky on 13-11-28.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLRecord : NSObject
@property (nonatomic, assign) NSUInteger recordId;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *endTime;
+ (id)recordWithId:(NSUInteger)record;
- (void)start;      // Set startTime to now
- (void)end;        // Set endTime to now
@end
