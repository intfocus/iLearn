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
    params[@"AppName"] = @"iLearn";
    return [HttpUtils httpPost:[Url actionLog] Params:params];
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
+ (HttpResponse *)courseSigninScannedUsers:(NSString *)tid ciid:(NSString *)ciid {
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
@end
