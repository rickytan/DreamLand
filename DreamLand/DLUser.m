//
//  DLUser.m
//  DreamLand
//
//  Created by ricky on 14-1-20.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLUser.h"
#import <ShareSDK/ShareSDK.h>

static DLUser *theUser = nil;

@implementation DLUser

+ (instancetype)currentUser
{
    return theUser;
}

+ (void)setCurrentUser:(DLUser *)user
{
    if (theUser == user)
        return;
    
    [theUser release];
    theUser = [user retain];
}

@end
