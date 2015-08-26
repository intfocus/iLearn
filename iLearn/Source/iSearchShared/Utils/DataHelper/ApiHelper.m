//
//  ApiHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "ApiHelper.h"
#import "Url+Param.h"
#import "HttpUtils.h"
#import "HttpResponse.h"
#import "SSZipArchive.h"
#import "FileUtils.h"
#import "ExtendNSLogFunctionality.h"

@implementation ApiHelper
/**
 *  用户登录难
 *
 *  @param UID user ID
 *
 *  @return 用户信息
 */
+ (HttpResponse *)login:(NSString *)UID {
    NSString *urlString = [Url login:UID];
    return [HttpUtils httpGet:urlString];
}

/**
 *  通知公告列表
 *
 *  @return 数据列表
 */
+ (HttpResponse *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID {
    NSString *urlString = [Url notifications:currentDate DeptID:depthID];
    return [HttpUtils httpGet:urlString];
}
/**
 *  用户操作记录
 *
 *  @param params ActionLog.toParams
 *
 *  @return 服务器响应信息
 */
+ (HttpResponse *)actionLog:(NSMutableDictionary *)params {
    NSMutableDictionary *logParams = [NSMutableDictionary dictionary];
    logParams[@"AppName"]              = @"iLearn";
    logParams[ACTIONLOG_FIELD_UID]     = params[ACTIONLOG_FIELD_UID];
    logParams[ACTIONLOG_FIELD_FUNNAME] = params[ACTIONLOG_FIELD_FUNNAME];
    logParams[ACTIONLOG_FIELD_ACTNAME] = params[ACTIONLOG_FIELD_ACTNAME];
    logParams[ACTIONLOG_FIELD_ACTOBJ]  = params[ACTIONLOG_FIELD_ACTOBJ];
    logParams[ACTIONLOG_FIELD_ACTRET]  = params[ACTIONLOG_FIELD_ACTRET];
    logParams[ACTIONLOG_FIELD_ACTTIME] = params[ACTIONLOG_FIELD_ACTTIME];
    return [HttpUtils httpPost:[Url actionLog] Params:logParams];
}

/**
 *  功能：获取某个人能看到的课程包
 *  URL：http://tsa-china.takeda.com.cn/uatui/api/CoursePackets_Api.php?uid=1
 *
 *  @param params uid：用户ID（和获得考卷的一样）
 *
 *  @return 课程包列表
 */
+ (HttpResponse *)coursePackages:(NSString *)UID {
    NSString *urlString = [Url coursePackages:UID];
    return [HttpUtils httpGet:urlString];
}

/**
 *  功能：获取单个课程包的详细信息
 *  URL：http://tsa-china.takeda.com.cn/uatui/api/CPOne_Api.php?cpid=1
 *
 *  @param PID 课程包编号
 *
 *  @return 课程包的详细信息
 */
+ (HttpResponse *)coursePackageContent:(NSString *)PID {
    NSString *urlString = [Url coursePackageContent:PID];
    return [HttpUtils httpGet:urlString];
}

/**
 *  培训报名列表
 *
 *  @param UID 用户ID
 *
 *  @return 培训报名列表
 */
+ (HttpResponse *)courseCourses:(NSString *)UID {
    NSString *urlString = [Url trainCourses:UID];
    return [HttpUtils httpGet:urlString];
}

/**
 *  报名
 *
 *  @param params 课程ID与UserId
 *
 *  @return who care
 */
+ (HttpResponse *)courseSignup:(NSMutableDictionary *)params {
    return [HttpUtils httpPost:[[[Url alloc] init] courseSignup] Params:params];
}

+ (HttpResponse *)trainSigninCreate:(NSMutableDictionary *)params {
    
    return [HttpUtils httpPost:[[[Url alloc] init] courseSignup] Params:params];
}


/**
 *  培训班的签到列表
 *
 *  @param tid 培训片ID
 *
 *  @return 培训班的签到列表
 */
+ (HttpResponse *)courseSignins:(NSString *)tid {
    NSString *urlString = [Url trainSignins:tid];
    return [HttpUtils httpGet:urlString];
}

/**
 *  培训班的签到CRUD
 *
 *  @param params 
 *{
 *    UserId: "8",//创建用户
 *    CheckInName: "ccssdd",//签到名称
 *    CheckInId: "5",//签到ID，修改和删除时生效
 *    Status: "-1"，//状态（0：新增，1：修改，-1：删除）
 *    TrainingId: "1"//课程编号
 *}
 *
 *  @return 服务器状态
 */
+ (HttpResponse *)courseSignin:(NSMutableDictionary *)params {
    return [HttpUtils httpPost:[[[Url alloc] init] courseSignin] Params:params];
}

/**
 *  签到的员工列表(含状态)
 *
 *  @param tid  培训班ID
 *  @param ciid 签到ID
 *
 *  @return 签到的员工列表
 */
+ (HttpResponse *)courseSigninScannedUsers:(NSString *)tid signinID:(NSString *)ciid {
    NSString *urlString = [Url trainSigninScannedUsers:tid ciid:ciid];
    return [HttpUtils httpGet:urlString];
}

/**
 *  签到的员工列表(所有)
 *
 *  @param tid  培训班ID
 *  @param ciid 签到ID
 *
 *  @return 签到的员工列表
 */
+ (HttpResponse *)courseSigninUsers:(NSString *)tid {
    NSString *urlString = [Url trainSigninUsers:tid];
    return [HttpUtils httpGet:urlString];
}

/**
 *  培训班签到点名
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
 *  @return 服务器响应
 */
+ (HttpResponse *)courseSigninUser:(NSMutableDictionary *)params {
    return [HttpUtils httpPost:[[[Url alloc] init] courseSigninUser] Params:params];
}

/**
 *  上传考试/问卷结果db.zip文件
 *
 *  @param filePath 上传文件路径, 
 *  @param type     考试或问卷
 *  @param userID   用户ID
 *
 *  @return 服务器响应结果
 */
+ (HttpResponse *)uploadFile:(NSString *)filePath userID:(NSString *)userID type:(NSString *)type {
    NSString *zipName = [NSString stringWithFormat:@"%@-%@-%@.zip", userID, type, [filePath lastPathComponent]];
    NSString *zipPath = [FileUtils dirPath:DOWNLOAD_DIRNAME FileName:zipName];
    [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[filePath]];
    
    return [HttpUtils uploadFile:zipPath userID:userID];
}

/**
 *  服务器下载考试/填写过的考试/问卷
 *
 *  @param fileName 下载文件名称 1430-exam-21.db.zip => 21.db.zip(直接解压即可)
 *  @param userID   用户ID
 *  @param destDir  下载到指定目录下
 */
+ (BOOL)downloadFile:(NSString *)fileName userID:(NSString *)userID destDir:(NSString *)destDir {
    NSString *urlStr   = [Url downloadFile:fileName type:[fileName pathExtension] userID:userID];
    NSURL *url         = [NSURL URLWithString:urlStr];
    NSData *data       = [NSData dataWithContentsOfURL:url];
    NSString *filePath = [destDir stringByAppendingPathComponent:fileName];
    [data writeToFile:filePath atomically:YES];
    BOOL state = [SSZipArchive unzipFileAtPath:filePath toDestination:destDir];
    NSLog(@"解压%@  %@", filePath, state ? @"成功" : @"失败");
    //[FileUtils removeFile:filePath];
    return state;
}

/**
 *  提交过的考试列表。（考试列表中不包含这些考试）
 *
 *  @param userID 用户ID
 *
 *  @return 考试列表
 */
+ (HttpResponse *)uploadedExams:(NSString *)userID {
    NSString *urlString = [Url uploadedExams:userID];
    
    return [HttpUtils httpGet:urlString];
}

/**
 *  某次提交过的考试各题的用户答案
 *
 *  @param userID 用户ID
 *  @param examID 考试ID
 *
 *  @return 用户答案
 */
+ (HttpResponse *)uploadedExamResult:(NSString *)userID examID:(NSString *)examID {
    NSString *urlString = [Url uploadedExamResult:userID examID:examID];
    
    return [HttpUtils httpGet:urlString];
}
@end
