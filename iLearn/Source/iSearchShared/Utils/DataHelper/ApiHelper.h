//
//  ApiHelper.h
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HttpResponse;
/**
 *  仅处理与服务器获取信息交互
 *  服务器获取失败或无网络时，交给CacheHelper
 */
@interface ApiHelper : NSObject
/**
 *  用户登录难
 *
 *  @param UID user ID
 *
 *  @return 用户信息
 */
+ (HttpResponse *)login:(NSString *)UID;

/**
 *  通知公告列表
 *
 *  @return 数据列表
 */
+ (HttpResponse *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID;

/**
 *  用户操作记录
 *
 *  @param params ActionLog.toParams
 *
 *  @return 服务器响应信息
 */
+ (HttpResponse *)actionLog:(NSMutableDictionary *)params;

/**
 *  功能：获取某个人能看到的课程包
 *  URL：http://tsa-china.takeda.com.cn/uatui/api/CoursePackets_Api.php?uid=1
 *
 *  @param params uid：用户ID（和获得考卷的一样）
 *
 *  @return 课程包列表
 */
+ (HttpResponse *)coursePackages:(NSString *)UID;

/**
 *  功能：获取单个课程包的详细信息
 *  URL：http://tsa-china.takeda.com.cn/uatui/api/CPOne_Api.php?cpid=1
 *
 *  @param PID 课程包编号
 *
 *  @return 课程包的详细信息
 */
+ (HttpResponse *)coursePackageContent:(NSString *)PID;

/**
 *  培训报名列表
 *
 *  @param UID 用户ID
 *
 *  @return 培训报名列表
 */
+ (HttpResponse *)trainCourses:(NSString *)UID;
/**
 *  报名
 *
 *  @param params 课程ID与UserId
 *
 *  @return who care
 */
+ (HttpResponse *)trainSignup:(NSMutableDictionary *)params;
@end
