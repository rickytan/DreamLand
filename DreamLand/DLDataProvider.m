//
//  DLDataProvider.m
//  DreamLand
//
//  Created by ricky on 13-11-15.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDataProvider.h"
#import "DLDatabase.h"

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
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Data WHERE time <= ? AND rid = ? ORDER BY time DESC LIMIT 0,1", time, recordID];
        float lvalue = 0.f, rvalue = 0.f;
        if ([result next])
            lvalue = [result doubleForColumn:@"value"];
        result = [db executeQuery:@"SELECT * FROM Data WHERE time >= ? AND rid = ? ORDER BY time ASC LIMIT 0,1", time, recordID];
        if ([result next])
            rvalue = [result doubleForColumn:@"value"];
        value = (lvalue + rvalue) / 2.0;
    }];
    return value;
}

- (NSDate*)startTimeOfRecord:(NSUInteger)recordID
{
    __block NSDate *date = nil;
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Record WHERE id = ?", recordID];
        if ([result next])
            date = [result dateForColumn:@"starttime"];
    }];
    return date;
}

- (NSDate*)endTimeOfRecord:(NSUInteger)recordID
{
    __block NSDate *date = nil;
    [[DLDatabase sharedDatabase] inDatabase:^(FMDatabase *db) {
        db.shouldCacheStatements = YES;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Record WHERE id = ?", recordID];
        if ([result next])
            date = [result dateForColumn:@"endtime"];
    }];
    return date;
}

@end
