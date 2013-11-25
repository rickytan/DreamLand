//
//  DLDatabase.m
//  DreamLand
//
//  Created by ricky on 13-11-25.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDatabase.h"

static DLDatabase *theDatabase = nil;

@interface DLDatabase ()
- (void)initTables;
@end

@implementation DLDatabase

+ (instancetype)sharedDatabase
{
    @synchronized(self) {
        if (!theDatabase) {
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
            path = [path stringByAppendingPathComponent:@"record.db"];
            
            theDatabase = [[self alloc] initWithPath:path];
        }
        return theDatabase;
    }
    return nil;
}

- (id)initWithPath:(NSString *)aPath
{
    self = [super initWithPath:aPath];
    if (self) {
        [self initTables];
    }
    return self;
}

- (void)initTables
{
    [self inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:
              @"CREATE TABLE IF NOT EXISTS Data ("
              @"    value float NOT NULL DEFAULT 0,"
              @"    time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,"
              @"    rid int"
              @")"
              ]) {
            NSLog(@"%@", [db lastError]);
        }
        if (![db executeUpdate:
              @"CREATE TABLE IF NOT EXISTS Record ("
              @"    id int NOT NULL DEFAULT 0,"
              @"    starttime timestamp NULL,"
              @"    endtime timestamp NULL,"
              @"    rate int NULL,"
              @"    desc text NULL"
              @")"
              ]) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}

@end
