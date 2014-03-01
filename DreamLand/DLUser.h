//
//  DLUser.h
//  DreamLand
//
//  Created by ricky on 14-1-20.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLUser : NSObject <NSCoding>
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) UIImage *headerImage;
@property (nonatomic, retain) NSString *headerURL;
@property (nonatomic, assign, getter = isLogin) BOOL login;

+ (instancetype)currentUser;
+ (void)setCurrentUser:(DLUser *)user;

@end
