//
//  LicenseUtil.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LicenseUtil : NSObject

+ (void)saveUserAccount:(NSString*)userAccount;
+ (NSString*)userAccount;
+ (void)saveUserId:(NSString*)userId;
+ (NSString*)userId;
+ (NSString*)userName;
+ (void)saveUserName:(NSString*)userName;
+ (NSString*)serviceNumber;

@end
