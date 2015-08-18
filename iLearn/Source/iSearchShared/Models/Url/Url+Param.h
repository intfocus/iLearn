//
//  Url+Param.h
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "Url.h"
/**
 *  api链接传递参数，约束统一在此
 */
@interface Url (Param)

/**
 *  用户登录经第三方验证成功，会通过UIWebView返回cookie值
 *
 *  @param UID user ID
 *
 *  @return urlString
 */
+ (NSString *)login:(NSString *)UID;

/**
 *  通知公告列表
 *
 *  @return urlString
 */
+ (NSString *)notifications:(NSString *)currentDate DeptID:(NSString *)depthID;

/**
 *  行为记录
 *
 *  @return urlString
 */
+ (NSString *)actionLog;

/**
 *  课程包列表
 *
 *  @param UID 用户ID
 *
 *  @return 课程包列表
 */
+ (NSString *)coursePackages:(NSString *)UID;

/**
 *  某个课程包明细
 *
 *  @param PID 课程包ID
 *
 *  @return 课程内容
 */
+ (NSString *)coursePackageContent:(NSString *)PID;


/**
 *  课件下载
 *
 *  @param cid 课件ID
 *  @param ext 课件文件扩展名
 *
 *  @return 课件下载链接
 */
+ (NSString *)downloadCourse:(NSString *)cid Ext:(NSString *)ext;

/**
 *  培训班报名
 *
 *  @param uid 用户ID
 *
 *  @return 培训班报名链接
 */
+ (NSString *)trainCourses:(NSString *)uid;

/**
 *  获取签到列表
 *
 *  @param tid 培训班ID
 *
 *  @return 签到列表
 */
+ (NSString *)trainSignins:(NSString *)tid;
@end
