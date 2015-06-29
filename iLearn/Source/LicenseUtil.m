//
//  LicenseUtil.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "LicenseUtil.h"
#import "ExamUtil.h"
#import "Constants.h"

static NSString *const kUserAccount = @"UserAccount";
static NSString *const kUserId = @"UserId";
static NSString *const kUserName = @"UserName";

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
        [userDefaults synchronize];
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
        NSString *savedUserId = [userDefaults stringForKey:kUserId];

        if (![savedUserId isEqualToString:userId]) {
            [ExamUtil cleanExamFolder];
            [userDefaults setObject:userId forKey:kUserId];
            [userDefaults synchronize];
        }
    }
}

+ (NSString*)userName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:kUserName];

    // TODO: Remove FakeName for developing
    if ([userName length]) {
        return userName;
    }
    else {
        return FakeName;
    }
}

+ (void)saveUserName:(NSString*)userName
{
    if ([userName length]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userName forKey:kUserName];
        [userDefaults synchronize];
    }
}

+ (NSString*)serviceNumber
{
    return ServiceNumber;
}

@end
