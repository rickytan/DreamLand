//
//  DLDataProvider.m
//  DreamLand
//
//  Created by ricky on 13-11-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDataProvider.h"
#import "DLDatabase.h"
#import "DLRecord.h"
#import "DLData.h"
#import "DLDataRecorder.h"

static DLDataProvider *theProvider = nil;

@interface DLDataProvider ()

@end

@implementation DLDataProvider
{
    NSCache             * _cache;
}

+ (instancetype)sharedProvider
{
    @synchronized(self) {
        if (!theProvider) {
            theProvider = [[DLDataProvider alloc] init];
        }
        return theProvider;
    }
    return nil;
}

- (void)dealloc
{
    [_cache release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (float)valueForTime:(NSDate *)time
             ofRecord:(NSUInteger)recordID
{
    __block float value = 0.f;
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        //        FMResultSet *r = [db executeQuery:@"select * from Data where rid = ?", [NSNumber numberWithUnsignedInteger:recordID]];
        //        while ([r next]) {
        //            NSLog(@"%f %@", [r doubleForColumn:@"value"], [NSDate dateWithTimeIntervalSince1970:[r doubleForColumn:@"time"]]);
        //        }
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Data WHERE time <= ? AND rid = ? ORDER BY time DESC LIMIT 0,1", [NSNumber numberWithDouble:time.timeIntervalSince1970], [NSNumber numberWithUnsignedInteger:recordID]];
        float lvalue = 0.f, rvalue = 0.f;
        BOOL hasLeft = NO, hasRight = NO;
        if ([result next]) {
            hasLeft = YES;
            lvalue = [result doubleForColumn:@"value"];
            [result close];
        }
        result = [db executeQuery:@"SELECT * FROM Data WHERE time >= ? AND rid = ? ORDER BY time ASC LIMIT 0,1", [NSNumber numberWithDouble:time.timeIntervalSince1970], [NSNumber numberWithUnsignedInteger:recordID]];
        if ([result next]) {
            hasRight = YES;
            rvalue = [result doubleForColumn:@"value"];
            [result close];
        }
        if (hasRight && hasLeft)
            value = (lvalue + rvalue) / 2.0;
        
    }];
    return value;
}

- (NSDate*)startTimeOfRecord:(NSUInteger)recordID
{
    __block NSDate *date = nil;
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Record WHERE id = ?", [NSNumber numberWithUnsignedInteger:recordID]];
        if ([result next])
            date = [result dateForColumn:@"starttime"];
        [result close];
    }];
    return date;
}

- (NSDate*)endTimeOfRecord:(NSUInteger)recordID
{
    __block NSDate *date = nil;
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Record WHERE id = ?", [NSNumber numberWithUnsignedInteger:recordID]];
        if ([result next])
            date = [result dateForColumn:@"endtime"];
        [result close];
    }];
    return date;
}

- (NSArray*)dataOfRecord:(NSUInteger)recordID inRangeStartDate:(NSDate *)start endDate:(NSDate *)end
{
    DLData *data = [DLData dataWithValue:0.0];
    data.date = start;
    __block NSMutableArray *arr = [NSMutableArray arrayWithObject:data];
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;

        static const NSInteger MAX_ITER_COUNT = 6;
        
        CGFloat threshold = 0.0;
        NSInteger numberOfIter = 0;
        NSInteger numberOfData = 0;
        while (YES) {
            FMResultSet *count = [db executeQuery:@"SELECT COUNT(1), MAX(value), MIN(value) FROM Data WHERE time >= ? AND time <= ? AND rid = ? AND (value >= ? OR value <= ?)", start, end, @(recordID), @(threshold), @(-threshold)];
            if ([count next]) {
                double max = [count doubleForColumnIndex:1];
                double min = [count doubleForColumnIndex:2];
                double v = MAX(fabs(max), fabs(min));
                
                numberOfData = [count intForColumnIndex:0];
                [count close];
                
                if (numberOfData > 320)
                    threshold = 0.6 * threshold + 0.4 * v;
                else
                    break;
            }
            
            if (++numberOfIter > MAX_ITER_COUNT)
                break;
        }
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Data WHERE time >= ? AND time <= ? AND rid = ? AND (value >= ? OR value <= ?)", start, end, @(recordID), @(threshold), @(-threshold)];
        while ([result next]) {
            DLData *data = [DLData dataWithValue:[result doubleForColumn:@"value"]];
            data.date = [result dateForColumn:@"time"];
            [arr addObject:data];
        }
    }];
    data = [DLData dataWithValue:0.0];
    data.date = end;
    [arr addObject:data];
    
    return [NSArray arrayWithArray:arr];
}

- (NSArray*)allRecords
{
    __block NSMutableArray *arr = [NSMutableArray array];
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Record WHERE 1 ORDER BY id DESC"];
        while ([result next]) {
            DLRecord *record = [DLRecord recordWithId:[result intForColumn:@"id"]];
            record.startTime = [result dateForColumn:@"starttime"];
            record.endTime = [result dateForColumn:@"endtime"];
            [arr addObject:record];
        }
    }];
    return [NSArray arrayWithArray:arr];
}

@end
