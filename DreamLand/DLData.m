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

- (void)dealloc
{
    self.date = nil;
    [super dealloc];
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
    [_tmpPath release];
    _tmpPath = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _cachedData = [[NSMutableData alloc] initWithCapacity:4*1024*1024];
        _dataToSave = [[NSMutableData alloc] initWithCapacity:1024*1024];
        
        _tmpPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.dat"] retain];
        
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

- (void)clear
{
    @synchronized(self) {
        _cachedData.data = nil;
        _dataToSave.data = nil;
        
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:_tmpPath];
        [fh truncateFileAtOffset:0lu];
        [fh closeFile];
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
    if (![fm fileExistsAtPath:_tmpPath]) {
        [fm createFileAtPath:_tmpPath
                    contents:nil
                  attributes:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:_tmpPath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:_dataToSave];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
    
    [_dataToSave release];
    _dataToSave = [[NSMutableData alloc] initWithCapacity:1024*1024];
}

- (NSString*)flushToFile
{
    @synchronized(self) {
        NSMutableData *tmp = _dataToSave;
        _dataToSave = _cachedData;
        _cachedData = tmp;
        [self saveToDisk];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSString *fileSavePath = nil;
        if (self.dataFilePath) {
            NSString *dirPath = [self.dataFilePath stringByDeletingLastPathComponent];
            NSString *fileName = [[self.dataFilePath lastPathComponent] stringByDeletingPathExtension];
            NSString *ext = [self.dataFilePath pathExtension];
            
            NSString *fullPath = self.dataFilePath;
            NSInteger i = 1;
            while ([fm fileExistsAtPath:fullPath]) {
                NSString *tmp = [NSString stringWithFormat:@"%@(%d).%@",fileName,i++, ext];
                fullPath = [dirPath stringByAppendingPathComponent:tmp];
            }
            fileSavePath = fullPath;
        }
        else {
            NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *doc = [arr lastObject];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *file = [NSString stringWithFormat:@"%@.dat",[formatter stringFromDate:[NSDate date]]];
            [formatter release];
            fileSavePath = [doc stringByAppendingPathComponent:file];
        }
        
        [fm moveItemAtPath:_tmpPath
                    toPath:fileSavePath
                     error:NULL];
        
        [self clear];
        
        return fileSavePath;
    }
}

@end
