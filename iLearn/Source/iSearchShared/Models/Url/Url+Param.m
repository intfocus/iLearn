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
    BOOL isParamsValid = CheckParams(GenFormat(1), UID);
    if(!isParamsValid) {
        UID = (NSString *)psd(UID, @"null");
    }
                              
    NSString *urlString  = [[Url alloc] init].login;
    NSDictionary *params = @{LOGIN_PARAM_UID: UID};

    return [Url UrlConcate:urlString Param:params];
}

/**
 *  通知公告列表
 *
 *  @return urlString
 */
+ (NSString *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID {
    BOOL isParamsValid = CheckParams(GenFormat(2), currentDate, depthID);
    if(!isParamsValid) {
        currentDate = (NSString *)psd(currentDate, @"null");
        depthID     = (NSString *)psd(depthID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].notifications;
    NSDictionary *params = @{NOTIFICATION_PARAM_DEPTID: depthID, NOTIFICATION_PARAM_DATESTR:currentDate};
    
    return [Url UrlConcate:urlString Param:params];
}

/**
 *  课程包列表
 *
 *  @param UID 用户ID
 *
 *  @return 课程包列表
 */
+ (NSString *)coursePackages:(NSString *)UID {
    BOOL isParamsValid = CheckParams(GenFormat(1), UID);
    if(!isParamsValid) {
        UID = (NSString *)psd(UID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].coursePackages;
    NSDictionary *params = @{COURSE_PACKAGES_PARAMS_UID: UID};
    
    return [Url UrlConcate:urlString Param:params];
}

/**
 *  某个课程包明细
 *
 *  @param PID 课程包ID
 *
 *  @return 课程内容
 */
+ (NSString *)coursePackageContent:(NSString *)PID {
    BOOL isParamsValid = CheckParams(GenFormat(1), PID);
    if(!isParamsValid) {
        PID = (NSString *)psd(PID, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].coursePackageContent;
    NSDictionary *params = @{COURSE_PACKAGE_CONTENT_PARAMS_PID: PID};
    
    return [Url UrlConcate:urlString Param:params];
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
    BOOL isParamsValid = CheckParams(GenFormat(2), cid, ext);
    if(!isParamsValid) {
        cid = (NSString *)psd(cid, @"null");
        ext = (NSString *)psd(ext, @"null");
    }
    
    NSString *urlString  = [[Url alloc] init].downloadCourse;
    NSDictionary *params = @{COURSE_DOWNLOAD_PARAMS_CID:cid, COURSE_DOWNLOAD_PARAMS_EXT:ext};
    
    return [Url UrlConcate:urlString Param:params];
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
    
    return [Url UrlConcate:urlString Param:params];
}

/**
 *  获取签到列表
 *
 *  @param tid 培训班ID
 *
 *  @return 签到列表
 */
+ (NSString *)trainSignins:(NSString *)tid {
    NSString *urlString  = [[Url alloc] init].trainSignins;
    NSDictionary *params = @{@"tid":tid};
    
    return [Url UrlConcate:urlString Param:params];
}

#pragma mark - GET# assistant methods
+ (NSString *)UrlConcate:(NSString *)url Param:(NSDictionary *)params {
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
