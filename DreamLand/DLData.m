//
//  DLData.m
//  DreamLand
//
//  Created by ricky on 13-5-29.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLData.h"


@implementation DLData

+ (id)dataWithValue:(double)value
{
    DLData *data = [[DLData alloc] init];
    data.value = [NSNumber numberWithDouble:value];
    data.date = [NSDate date];
    return [data autorelease];
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.value
                  forKey:@"Value"];
    [aCoder encodeObject:self.date
                  forKey:@"Date"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.value = [aDecoder decodeObjectForKey:@"Value"];
        self.date = [aDecoder decodeObjectForKey:@"Date"];
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Value: %@ at time: %@",self.value, self.date];
}

- (void)appendToData:(NSMutableData *)data
{
    Unit unit;
    unit.value = self.value.doubleValue;
    unit.timestamp = self.date.timeIntervalSince1970;
    [data appendBytes:&unit
               length:sizeof(Unit)];
}

@end


@implementation DLDataBuffer

@synthesize dataFilePath = _dataFilePath;

- (void)dealloc
{
    self.dataFilePath = nil;
    [_cachedData release];
    _cachedData = nil;
    [_dataToSave release];
    _dataToSave = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _cachedData = [[NSMutableData alloc] initWithCapacity:4*1024*1024];
        _dataToSave = [[NSMutableData alloc] initWithCapacity:1024*1024];
        
        NSArray *arr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        self.dataFilePath = [[arr lastObject] stringByAppendingPathComponent:@"wave.db"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:self.dataFilePath
                       error:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)addData:(DLData*)data
{
    @synchronized(self) {
        [data appendToData:_cachedData];
    }
}

- (void)handleMemoryWarning:(NSNotification*)notification
{
    @synchronized(self) {
        NSMutableData *tmp = _dataToSave;
        _dataToSave = _cachedData;
        _cachedData = tmp;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self saveToDisk];
        });
    }
}

- (void)saveToDisk
{
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:self.dataFilePath]) {
        [fm createFileAtPath:self.dataFilePath
                    contents:nil
                  attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.dataFilePath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:_dataToSave];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
    
    [_dataToSave release];
    _dataToSave = [[NSMutableData alloc] initWithCapacity:1024*1024];
}

- (void)flushToFile
{
    @synchronized(self) {
        NSMutableData *tmp = _dataToSave;
        _dataToSave = _cachedData;
        _cachedData = tmp;
        [self saveToDisk];
    }
}

@end
