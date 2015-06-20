//
//  LicenseUtil.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "LicenseUtil.h"
#import "Constants.h"

static NSString *const kUserAccount = @"UserAccount";
static NSString *const kUserId = @"UserId";

@implementation LicenseUtil

+ (NSString*)userAccount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userAccount = [userDefaults stringForKey:kUserAccount];

    // TODO: Remove FakeAccount for developing
    if ([userAccount length]) {
        return userAccount;
    }
    else {
        return FakeAccount;
    }
}

+ (void)saveUserAccount:(NSString*)userAccount
{
    if ([userAccount length]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userAccount forKey:kUserAccount];
    }
}

+ (NSString*)userId
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults stringForKey:kUserId];

    // TODO: Remove FakeId for developing
    if ([userId length]) {
        return userId;
    }
    else {
        return FakeId;
    }
}

+ (void)saveUserId:(NSString*)userId
{
    if ([userId length]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userId forKey:kUserId];
    }
}

+ (NSString*)serviceNumber
{
    return ServiceNumber;
}

@end
