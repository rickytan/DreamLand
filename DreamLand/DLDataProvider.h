//
//  DLDataProvider.h
//  DreamLand
//
//  Created by ricky on 13-11-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLDataProvider : NSObject

+ (instancetype)sharedProvider;

- (float)valueForTime:(NSDate*)time ofRecord:(NSUInteger)recordID;
- (NSDate*)startTimeOfRecord:(NSUInteger)recordID;
- (NSDate*)endTimeOfRecord:(NSUInteger)recordID;

- (NSArray*)dataOfRecord:(NSUInteger)recordID
        inRangeStartDate:(NSDate*)start
                 endDate:(NSDate*)end;
- (NSArray*)allRecords;

@end
