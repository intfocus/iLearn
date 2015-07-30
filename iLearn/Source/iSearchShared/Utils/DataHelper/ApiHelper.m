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

@end
