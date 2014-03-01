//
//  DLUser.m
//  DreamLand
//
//  Created by ricky on 14-1-20.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLUser.h"

static DLUser *theUser = nil;

@implementation DLUser

+ (instancetype)currentUser
{
    if (!theUser) {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.db"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            @try {
                theUser = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
            }
            @catch (NSException *exception) {

            }
        }
    }
    return theUser;
}

+ (void)setCurrentUser:(DLUser *)user
{
    if (theUser == user)
        return;
    
    [theUser release];
    theUser = [user retain];
    if (theUser)
        [theUser _saveToDisk];
    else {
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.db"];
        [[NSFileManager defaultManager] removeItemAtPath:path
                                                   error:NULL];
    }
}

- (void)_saveToDisk
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"user.db"];
    if ([NSKeyedArchiver archiveRootObject:self
                                toFile:path])
        NSLog(@"User saved!");
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.displayName = [aDecoder decodeObjectForKey:@"DisplayName"];
        self.userID = [aDecoder decodeObjectForKey:@"UserID"];
        self.headerImage = [aDecoder decodeObjectForKey:@"HeaderImage"];
        self.headerURL = [aDecoder decodeObjectForKey:@"HeaderURL"];
        self.email = [aDecoder decodeObjectForKey:@"Email"];
        self.login = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (self.displayName)
        [aCoder encodeObject:self.displayName
                      forKey:@"DisplayName"];
    if (self.userID)
        [aCoder encodeObject:self.userID
                      forKey:@"UserID"];
    if (self.headerURL)
        [aCoder encodeObject:self.headerURL
                      forKey:@"HeaderURL"];
    if (self.headerImage)
        [aCoder encodeObject:self.headerImage
                      forKey:@"HeaderImage"];
    if (self.email)
        [aCoder encodeObject:self.email
                      forKey:@"Email"];
}

@end
