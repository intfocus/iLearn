//
//  FileUtils+Setting.m
//  iLearn
//
//  Created by lijunjie on 15/8/22.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "FileUtils+Setting.h"
#import "User.h"

@implementation FileUtils (Setting)

+ (NSArray *)appFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [FileUtils basePath];
    NSMutableArray *array = [NSMutableArray array];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:basePath error:nil];
    NSString *filePath;
    NSDictionary *dict = [NSDictionary dictionary];
    BOOL isDir = NO;
    User *user;
    for(NSString *fileName in files) {
        filePath = [basePath stringByAppendingPathComponent:fileName];
        filePath = [filePath stringByAppendingPathComponent:CONFIG_DIRNAME];
        filePath = [filePath stringByAppendingPathComponent:LOGIN_CONFIG_FILENAME];
        if([fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
            dict = [FileUtils readConfigFile:filePath];
            user = [[User alloc] init];
            user.ID         = dict[USER_ID];
            user.name       = dict[USER_NAME];
            user.employeeID = dict[USER_EMPLOYEEID];
            
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];

            [array addObject:@[user, fileSizeNumber]];
        }
    }
    
    return [NSArray arrayWithArray:array];
}
@end
