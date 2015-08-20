//
//  CourseSignin.m
//  iLearn
//
//  Created by lijunjie on 15/8/19.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CourseSignin.h"
#import "FileUtils.h"
#import "const.h"
#import "ApiHelper.h"
#import "HttpResponse.h"

@implementation CourseSignin

- (CourseSignin *)initServerData:(NSDictionary *)dict {
    if(self = [super init]) {
        //_courseID   = dict[@"TrainingId"];
        //_signinID   = dict[@"CheckInId"];
        //_userName   = dict[@"UserName"];
        //_userID     = dict[@"UserId"];
        //_createrID  = dict[@"CreatedUser"];
        //_userID     = dict[@"UserId"];
        _employeeID = dict[@"EmployeeId"];
        _createAt   = dict[@"IssueDate"];
        _choices    = dict[@"Reason"];
        _isUpload   = ([dict[@"Status"] intValue] > 0);
    }
    
    return self;
}

- (CourseSignin *)initLocalData:(NSDictionary *)dict {
    if(self = [super init]) {
        //_courseID   = dict[@"CourseID"];
        //_signinID   = dict[@"SigninID"];
        //_userName   = dict[@"UserName"];
        //_userID     = dict[@"UserId"];
        //_createrID  = dict[@"CreaterID"];
        //_userID     = dict[@"UserID"];
        _employeeID = dict[@"EmployeeID"];
        _createAt   = dict[@"CreatedAt"];
        _choices    = dict[@"Choices"];
        _isUpload   = [dict[@"IsUpload"] boolValue];
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *localDict = [NSMutableDictionary dictionary];
    //localDict[@"CourseID"]  = self.courseID;
    //localDict[@"SigninID"]  = self.signinID;
    //localDict[@"UserName"]  = self.userName;
    //localDict[@"UserId"]    = self.userID;
    //localDict[@"CreaterID"] = self.createrID;
    //localDict[@"UserID"]     = self.userID;
    localDict[@"CreatedAt"]  = self.createAt;
    localDict[@"Choices"]    = self.choices;
    localDict[@"EmployeeID"] = self.employeeID;
    localDict[@"IsUpload"]   = [NSNumber numberWithBool:self.isUpload];
    
    return [NSDictionary dictionaryWithDictionary:localDict];
}

+ (NSDictionary *)toLocal:(NSDictionary *)serverDict {
    NSMutableDictionary *localDict = [NSMutableDictionary dictionary];
    //localDict[@"CourseID"]  = serverDict[@"TrainingId"];
    //localDict[@"SigninID"]  = serverDict[@"CheckInId"];
    //localDict[@"UserName"]  = serverDict[@"UserName"];
    //localDict[@"CreaterID"] = serverDict[@"CreatedUser"];
    localDict[@"UserID"]     = serverDict[@"UserId"];
    localDict[@"EmployeeID"] = serverDict[@"EmployeeId"];
    localDict[@"CreatedAt"]  = serverDict[@"IssueDate"];
    localDict[@"Choices"]    = serverDict[@"Reason"];
    localDict[@"IsUpload"]   = serverDict[@"Status"];
    
    return [NSDictionary dictionaryWithDictionary:localDict];
}

/**
 *  离线时，点名数据存放在本地；
 *  本质: 无论在线与否数据都先存放在本地，然后统一上传至服务器，
 *       从服务器拉取点击状态列表时也写入本地缓存，客户展示数据仅与缓存交互
 *
 *  @param courseID 课程ID
 *  @param signinID 签到ID
 *
 *  @return 缓存文件路径
 */
+ (NSString *)scannedFilePath:(NSString *)courseID signinID:(NSString *)signinID {
    NSString *scannedFileName = [NSString stringWithFormat:@"%@-%@.scanned", courseID, signinID];
    return [FileUtils dirPath:CACHE_DIRNAME FileName:scannedFileName];
}

/**
 *  从缓存文件，读取某个员工在某个课程某个签到中的状态
 *
 *  @param employeeID 员工编号
 *  @param courseID 课程ID
 *  @param signinID 签到ID
 *
 *  @return 签到状态；字符按逗号分隔
 */
+ (NSString *)findChoices:(NSString *)employeeID
                 courseID:(NSString *)courseID
                 signinID:(NSString *)signinID {
    NSString *scannedFilePath = [CourseSignin scannedFilePath:courseID signinID:signinID];
    NSString *choices = @"";
    if([FileUtils checkFileExist:scannedFilePath isDir:NO]) {
        NSMutableDictionary *scannedList = [FileUtils readConfigFile:scannedFilePath][@"Data"];
        CourseSignin *courseSignin;
        for(NSDictionary *dict in scannedList) {
            courseSignin = [[CourseSignin alloc] initLocalData:dict];
            if([courseSignin.employeeID isEqualToString:employeeID]) {
                choices = courseSignin.choices;
                break;
            }
        }
    }
    return choices;
}

/**
 *  扫描签到某个员工信息后，写入本地缓存。
 *
 *  @param courseID 课程ID
 *  @param signinID 签到ID
 *  @param employeeID 员工编号
 *  @param choices  签到状态
 */
+ (void)saveToLocal:(NSString *)employeeID
            choices:(NSString *)choices
           courseID:(NSString *)courseID
           signinID:(NSString *)signinID {
    NSString *scannedFilePath = [CourseSignin scannedFilePath:courseID signinID:signinID];
    NSMutableDictionary *scannedList = [NSMutableDictionary dictionary];
    NSString *createdAt = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];
    
    CourseSignin *newCourseSignin = [[CourseSignin alloc] init];
    newCourseSignin.employeeID = employeeID;
    newCourseSignin.choices    = choices;
    newCourseSignin.isUpload   = NO;
    newCourseSignin.createAt   = createdAt;
    
    if([FileUtils checkFileExist:scannedFilePath isDir:NO]) {
        scannedList = [FileUtils readConfigFile:scannedFilePath];
        
        BOOL isExist = NO;
        CourseSignin *courseSignin;
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for(NSInteger i=0; i < [scannedList[@"Data"] count]; i++) {
            temp = scannedList[@"Data"][i];
            courseSignin = [[CourseSignin alloc] initLocalData:temp];
            if([courseSignin.employeeID isEqualToString:employeeID]) {
                isExist            = YES;
                courseSignin.choices = choices;
                courseSignin.isUpload = NO;
                courseSignin.createAt = createdAt;
                scannedList[@"Data"][i] = [courseSignin dictionary];
                break;
            }
        }
        if(!isExist) {
            [scannedList[@"Data"] addObject:[newCourseSignin dictionary]];
        }
    }
    else {
        scannedList[@"CourseId"] = courseID;
        scannedList[@"SigninId"] = signinID;
        scannedList[@"Data"] = @[[newCourseSignin dictionary]];
    }
    [FileUtils writeJSON:scannedList Into:scannedFilePath];
}

/**
 *  本地点击数据推送至服务器
 *
 * {
 *     TrainingId: "1",
 *     UserId: "2",
 *     IssueDate: "2015/07/18 14:33:43",
 *     Status: "1",
 *     Reason: "等快递快递收到伐",
 *     CreatedUser: "1",
 *     CheckInId: "1"
 * }
 *
 *
 *  @param courseID   课程ID
 *  @param signinID   签到ID
 *  @param employeeID 员工编号
 *  @param createrID  点名人ID
 *  @param userID     签到创建人ID
 */
+ (void)postToServer:(NSString *)courseID
            signinID:(NSString *)signinID
           createrID:(NSString *)createrID {
    NSString *scannedFilePath = [CourseSignin scannedFilePath:courseID signinID:signinID];
    if(![FileUtils checkFileExist:scannedFilePath isDir:NO]) {
        return;
    }
    
    CourseSignin *courseSignin;
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    NSMutableDictionary *scannedList = [FileUtils readConfigFile:scannedFilePath];
    for(NSInteger i=0; i < [scannedList[@"Data"] count]; i++) {
        temp = scannedList[@"Data"][i];
        courseSignin = [[CourseSignin alloc] initLocalData:temp];
        if(!courseSignin.isUpload) {
            courseSignin.isUpload = YES;
            scannedList[@"Data"][i] = [courseSignin dictionary];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"TrainingId"]  = courseID;
            params[@"CheckInId"]   = signinID;
            params[@"CreatedUser"] = createrID;
            params[@"Status"]      = @"1";
            params[@"Reason"]      = courseSignin.choices;
            params[@"IssueDate"]   = courseSignin.createAt;
            params[@"UserId"]      = courseSignin.employeeID;
            
            HttpResponse *response = [ApiHelper courseSigninUser:params];
            NSString *log = [NSString stringWithFormat:@"courseID:%@, singinID:%@, employeeID:%@, status:%@, created_at:%@, http status code: %@, data:%@", courseID, signinID, courseSignin.employeeID, courseSignin.choices, courseSignin.createAt, response.statusCode, response.string];
            ActionLogRecord(@"课程培训签到点名", log);
        }
    }
    [FileUtils writeJSON:scannedList Into:scannedFilePath];
}

/**
 *  服务器端点名状态的列表数据转换为本地数据
 *
 *  @param serverDict 服务器端点名状态的列表数据
 *  @param courseID   课程ID
 *  @param signinID   签到ID
 */
+ (void)serverDataToLocal:(NSDictionary *)serverDict
                 courseID:(NSString *)courseID
                 signinID:(NSString *)signinID {
    NSString *scannedFilePath = [CourseSignin scannedFilePath:courseID signinID:signinID];
    
    NSArray *serverData = serverDict[@"traineesdata"];
    NSMutableArray *localData = [NSMutableArray array];
    if(serverData && [serverData count] > 0) {
        NSDictionary *localDict = [NSDictionary dictionary];
        for(NSDictionary *dict in serverData) {
            localDict = [CourseSignin toLocal:dict];
            [localData addObject:localDict];
        }
    }
    
    NSMutableDictionary *localDict = [NSMutableDictionary dictionary];
    localDict[@"CourseID"] = courseID;
    localDict[@"SigninID"] = signinID;
    localDict[@"Data"]     = localData;
    
    [FileUtils writeJSON:localDict Into:scannedFilePath];
}

/**
 *  点击过我员工列表信息(在线的，离线的)
 *  从服务器拉取数据前，先把提交本地未上传代码，再拉取最新数据，转换为本地格式，离线时可以继续点名，有网时上传
 *
 *  @param courseID   课程ID
 *  @param signinID   签到ID
 *
 *  @return 点击过我员工列表信息(在线的，离线的)
 */
+ (NSArray *)scannedUsers:(NSString *)courseID signinID:(NSString *)signinID {
    NSArray *dataList = [NSArray array];
    NSString *scannedFilePath = [CourseSignin scannedFilePath:courseID signinID:signinID];
    if([FileUtils checkFileExist:scannedFilePath isDir:NO]) {
        dataList = [FileUtils readConfigFile:scannedFilePath][@"Data"];
    }
    
    return dataList;
}
@end
