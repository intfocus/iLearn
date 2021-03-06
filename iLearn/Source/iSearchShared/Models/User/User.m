//
//  User.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "User.h"
#import "FileUtils.h"
#import "DateUtils.h"

@implementation User

- (User *)init {
    if(self = [super init]) {
        NSString *configPath = [[FileUtils basePath] stringByAppendingPathComponent:LOGIN_CONFIG_FILENAME];
        self = [self initWithConfigPath:configPath];
        
        _personalPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:LOGIN_CONFIG_FILENAME];
    }

    return self;
}

- (User *)initWithConfigPath:(NSString *)configPath {
    if(self = [super init]) {
        NSMutableDictionary *configDict =[FileUtils readConfigFile:configPath];
        
        _configPath   = configPath;
        _personalPath = configPath;
        _configDict   = configDict;
        
        _ID         = configDict[USER_ID];
        _name       = configDict[USER_NAME];
        _email      = configDict[USER_EMAIL];
        _deptID     = configDict[USER_DEPTID];
        _employeeID = configDict[USER_EMPLOYEEID];
        
        // local fields
        _loginUserName    = configDict[USER_LOGIN_USERNAME];
        _loginPassword    = configDict[USER_LOGIN_PASSWORD];
        _loginRememberPWD = [configDict[USER_LOGIN_REMEMBER_PWD] isEqualToString:@"1"];
        _loginLast        = configDict[USER_LOGIN_LAST];
        
    }
    
    return self;
}
#pragma mark - instance methods

- (void)save {
    // server info
    _configDict[USER_ID]         = self.ID;
    _configDict[USER_NAME]       = self.name;
    _configDict[USER_EMAIL]      = self.email;
    _configDict[USER_DEPTID]     = self.deptID;
    _configDict[USER_EMPLOYEEID] = self.employeeID;
    
    // local info
    _configDict[USER_LOGIN_USERNAME]     = self.loginUserName;
    _configDict[USER_LOGIN_PASSWORD]     = self.loginPassword;
    _configDict[USER_LOGIN_REMEMBER_PWD] = (self.loginRememberPWD ? @"1" : @"0");
    _configDict[USER_LOGIN_LAST]         = self.loginLast;
    
    [FileUtils writeJSON:self.configDict Into:self.configPath];
}

- (void)writeInToPersonal {
    _personalPath = [FileUtils dirPath:CONFIG_DIRNAME FileName:LOGIN_CONFIG_FILENAME];
    [FileUtils writeJSON:self.configDict Into:self.personalPath];
}

#pragma mark - class methods

- (NSString *)basePath {
    NSString *userSpaceName = [NSString stringWithFormat:@"%@-%@", _deptID, _employeeID];
    return [[FileUtils basePath] stringByAppendingPathComponent:userSpaceName];
}

/**
 *  快捷获取用户ID
 *
 *  @return 用户ID
 */
+ (NSString *)userID {
    return [self configData][USER_ID];
}
/**
 *  快捷获取部门ID
 *
 *  @return 部门ID
 */
+ (NSString *)deptID {
    return [self configData][USER_DEPTID];
}

+ (NSMutableDictionary *)configData {
    NSString *configPath = [[FileUtils basePath] stringByAppendingPathComponent:LOGIN_CONFIG_FILENAME];
    return [FileUtils readConfigFile:configPath];
}


- (BOOL)isEverLogin {
    return self.loginLast;
}


- (void)userIDmapEmployeeID:(NSMutableDictionary *)mapDict {
    NSString *mapPath = [FileUtils dirPath:CACHE_DIRNAME FileName:@"userID-employeeID.map"];
    
    [FileUtils writeJSON:mapDict Into:mapPath];
}
- (NSMutableDictionary *)userIDmapEmployeeID {
    NSString *mapPath = [FileUtils dirPath:CACHE_DIRNAME FileName:@"userID-employeeID.map"];
    NSMutableDictionary *mapDict = [NSMutableDictionary dictionary];
    if([FileUtils checkFileExist:mapPath isDir:NO]) {
        mapDict = [FileUtils readConfigFile:mapPath];
    }
    
    return mapDict;
}
@end
