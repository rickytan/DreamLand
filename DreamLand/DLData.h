//
//  DLData.h
//  DreamLand
//
//  Created by ricky on 13-5-29.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct Unit {
    double value;
    double timestamp;
} Unit;

@interface DLData : NSObject <NSCoding>
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSNumber *value;
+ (id)dataWithValue:(double)value;
- (void)appendToData:(NSMutableData*)data;
@end


@interface DLDataBuffer : NSObject
{
    NSMutableData       * _cachedData;
    NSMutableData       * _dataToSave;
    
    NSString            * _tmpPath;
}
@property (nonatomic, retain) NSString *dataFilePath;   // Default /Documents/YYYYMMDDHHmmss.dat
- (void)addData:(DLData*)data;
- (void)clear;
- (NSString*)flushToFile;
@end
