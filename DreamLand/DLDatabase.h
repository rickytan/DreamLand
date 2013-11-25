//
//  DLDatabase.h
//  DreamLand
//
//  Created by ricky on 13-11-25.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

@interface DLDatabase : FMDatabaseQueue

+ (instancetype)sharedDatabase;

@end
