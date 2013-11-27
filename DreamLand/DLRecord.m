//
//  DLRecord.m
//  DreamLand
//
//  Created by ricky on 13-11-28.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLRecord.h"


@implementation DLRecord

+ (id)recordWithId:(NSUInteger)record
{
    DLRecord *r = [[self alloc] init];
    r.recordId = record;
    return [r autorelease];
}

- (void)dealloc
{
    self.startTime = nil;
    self.endTime = nil;
    [super dealloc];
}

- (void)start
{
    self.startTime = [NSDate date];
}

- (void)end
{
    self.endTime = [NSDate date];
}

@end