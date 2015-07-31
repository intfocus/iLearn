//
//  SlideUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/22.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Version.h"

#import "const.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "ExtendNSLogFunctionality.h"

@implementation Version

- (Version *)init {
    if(self = [super init]) {
        NSDictionary *localVersionInfo =[[NSBundle mainBundle] infoDictionary];
        _current   = localVersionInfo[@"CFBundleShortVersionString"];
        _appName   = localVersionInfo[@"CFBundleExecutable"];
        _lang      = localVersionInfo[@"CFBundleDevelopmentRegion"];
        _suport    = localVersionInfo[@"MinimumOSVersion"];
        _sdkName   = localVersionInfo[@"DTSDKName"];
        _platform  = localVersionInfo[@"DTPlatformName"];
        _dbVersion = (NSString *)psd(localVersionInfo[@"Database Version"], @"NotSet");
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSDictionary *fattributes = [fm attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
        _fileSystemSize     = [fattributes objectForKey:NSFileSystemSize];
        _fileSystemFreeSize = [fattributes objectForKey:NSFileSystemFreeSize];
        
        [self reload];
        [self updateTimestamp];
    }
    return self;
}

- (void)updateTimestamp {
    NSString *timestamp = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];;
    if(!self.localCreatedDate) { _localCreatedDate = timestamp; }
    _localUpdatedDate = timestamp;
}

- (BOOL)isUpgrade {
    return self.latest && ![self.latest isEqualToString:self.current];
}

- (void)reload {
    NSString *configPath = [[FileUtils basePath] stringByAppendingPathComponent:UPGRADE_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    _latest    = configDict[VERSION_LATEST];
    _insertURL = configDict[VERSION_INSERTURL];
    _changeLog = configDict[VERSION_CHANGELOG];
}

- (void)save {
    NSString *configPath = [[FileUtils basePath] stringByAppendingPathComponent:UPGRADE_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    configDict[VERSION_CHANGELOG]   = self.changeLog;
    configDict[VERSION_LATEST]      = self.latest;
    configDict[VERSION_INSERTURL]   = self.insertURL;
    configDict[DB_COLUMN_CREATED] = self.localCreatedDate;
    configDict[DB_COLUMN_CREATED] = self.localUpdatedDate;
    
    [FileUtils writeJSON:configDict Into:configPath];
}

- (void)setLatest:(NSString *)latest {
    if(![self.latest isEqualToString:latest]) {
        _latest = latest;
        [self save];
    }
}

- (NSString *)simpleDescription {
    return [NSString stringWithFormat:@"<#%@ version: %@, dbVersion:%@, platform:%@, sdkName: %@, lang: %@>", self.appName,self.current,self.dbVersion,self.platform,self.sdkName,self.lang];
}

+ (NSString *)pgy_app_id {
    return PGY_APP_ID;
}
@end