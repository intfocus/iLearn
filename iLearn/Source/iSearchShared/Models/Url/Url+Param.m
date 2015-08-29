//
//  Url+Param.m
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "const.h"
#import "Url+Param.h"
#import "ExtendNSLogFunctionality.h"

@implementation Url (Param)

#pragma mark - GET

/**
 *  用户登录经第三方验证成功，会通过UIWebView返回cookie值
 *
 *  @param UID user ID
 *
 *  @return urlString
 */
+ (NSString *)login:(NSString *)UID {
    NSString *urlString  = [[Url alloc] init].login;
    NSDictionary *params = @{LOGIN_PARAM_UID: UID};

    return [Url concate:urlString param:params];
}

/**
 *  通知公告列表
 *
 *  @return urlString
 */
+ (NSString *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID {
    NSString *urlString  = [[Url alloc] init].notifications;
    NSDictionary *params = @{NOTIFICATION_PARAM_DEPTID: depthID, NOTIFICATION_PARAM_DATESTR:currentDate};
    
    return [Url concate:urlString param:params];
}

/**
 *  课程包列表
 *
 *  @param UID 用户ID
 *
 *  @return 课程包列表
 */
+ (NSString *)coursePackages:(NSString *)UID {
    NSString *urlString  = [[Url alloc] init].coursePackages;
    NSDictionary *params = @{COURSE_PACKAGES_PARAMS_UID: UID};
    
    return [Url concate:urlString param:params];
}

/**
 *  某个课程包明细
 *
 *  @param PID 课程包ID
 *
 *  @return 课程内容
 */
+ (NSString *)coursePackageContent:(NSString *)PID {
    NSString *urlString  = [[Url alloc] init].coursePackageContent;
    NSDictionary *params = @{COURSE_PACKAGE_CONTENT_PARAMS_PID: PID};
    
    return [Url concate:urlString param:params];
}

/**
 *  课件下载
 *
 *  @param cid 课件ID
 *  @param ext 课件文件扩展名
 *
 *  @return 课件下载链接
 */
+ (NSString *)downloadCourse:(NSString *)cid Ext:(NSString *)ext {
    NSString *urlString  = [[Url alloc] init].downloadCourse;
    NSDictionary *params = @{COURSE_DOWNLOAD_PARAMS_CID:cid, COURSE_DOWNLOAD_PARAMS_EXT:ext};
    
    return [Url concate:urlString param:params];
}

/**
 *  培训班报名
 *
 *  @param uid 用户ID
 *
 *  @return 培训班报名链接
 */
+ (NSString *)trainCourses:(NSString *)uid {
    NSString *urlString  = [[Url alloc] init].trainCourses;
    NSDictionary *params = @{@"uid":uid, @"edate":[DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT]};
    
    return [Url concate:urlString param:params];
}

/**
 *  获取签到列表
 *
 *  @param tid 培训班ID
 *
 *  @return 签到列表
 */
+ (NSString *)trainSignins:(NSString *)tid {
    NSString *urlString  = [[Url alloc] init].courseSignins;
    NSDictionary *params = @{@"tid":tid};
    
    return [Url concate:urlString param:params];
}

/**
 *  签到的员工列表(含状态)
 *
 *  @param tid  培训班ID
 *  @param ciid 签到ID
 *
 *  @return 签到的员工列表
 */
+ (NSString *)trainSigninScannedUsers:(NSString *)tid ciid:(NSString *)ciid {
    NSString *urlString  = [[Url alloc] init].courseSigninScannedUsers;
    NSDictionary *params = @{@"tid":tid, @"ciid":ciid};
    
    return [Url concate:urlString param:params];
}
/**
 *  签到的员工列表(所有)
 *
 *  @param tid  培训班ID
 *
 *  @return 签到的员工列表
 */
+ (NSString *)trainSigninUsers:(NSString *)tid {
    NSString *urlString  = [[Url alloc] init].courseSigninUsers;
    NSDictionary *params = @{@"tid":tid};
    
    return [Url concate:urlString param:params];
}

/**
 *  http://tsa-china.takeda.com.cn/uat/api/FileDownload_Api.php?fid=uat.sql&ftype=sql&uid=111
 *
 *  @param fileName 文件名称
 *  @param fileType 文件后缀
 *  @param userID   用户ID
 */
+ (NSString *)downloadFile:(NSString*)fileName type:(NSString *)fileType userID:(NSString *)userID {
    NSString *urlString  = [[Url alloc] init].downloadFile;
    NSDictionary *params = @{@"fid":fileName, @"ftype":fileType, @"uid":userID};
    
    return [Url concate:urlString param:params];
}

/**
 *  提交过的考试列表。（考试列表中不包含这些考试）
 *
 *  @param userID 用户ID
 *
 *  @return 链接
 */
+ (NSString *)uploadedExams:(NSString *)userID {
    NSString *urlString  = [[Url alloc] init].uploadedExams;
    NSDictionary *params = @{@"uid":userID};
    
    return [Url concate:urlString param:params];
}

/**
 *  某次提交过的考试各题的用户答案
 *
 *  @param userID 用户ID
 *  @param examID 考试ID
 *
 *  @return 链接
 */
+ (NSString *)uploadedExamResult:(NSString *)userID examID:(NSString *)examID {
    NSString *urlString  = [[Url alloc] init].uploadedExamResult;
    NSDictionary *params = @{@"uid":userID, @"eid": examID};
    
    return [Url concate:urlString param:params];
}

#pragma mark - GET# assistant methods
+ (NSString *)concate:(NSString *)url param:(NSDictionary *)params {
    NSString *paramString = [Url _parameters:params];
    NSString *urlString   = [NSString stringWithFormat:@"%@?%@", url, paramString];
    return urlString;
}


+ (NSString *)_parameters:(NSDictionary *)params {
    // additional params
    NSMutableDictionary *baseParams = [[NSMutableDictionary alloc] init];
    [baseParams addEntriesFromDictionary:@{PARAM_LANG: APP_LANG}];
    [baseParams addEntriesFromDictionary:params];
    
    NSString *value;
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for(NSString *key in baseParams) {
        value = [baseParams objectForKey:key];
        [paramArray addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    return [paramArray componentsJoinedByString:@"&"];
}

#pragma mark - POST
/**
 *  行为记录
 *
 *  @return urlString
 */
+ (NSString *)actionLog {
    return [[Url alloc] init].actionLog;
}
@end
