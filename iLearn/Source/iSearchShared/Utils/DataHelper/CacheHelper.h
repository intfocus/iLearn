//
//  CacheHelper.h
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
//
#import <Foundation/Foundation.h>
/**
 *  处理本地缓存信息，与ApiHelper对应
 */
@interface CacheHelper : NSObject
/**
 *  读取本地缓存通知公告数据
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)notifications;
/**
 *  缓存服务器获取到的数据
 *
 *  @param notificationDatas 服务器获取到的数据
 */
+ (void)writeNotifications:(NSMutableDictionary *)notificationDatas;
/**
 *  目录信息缓存文件文件路径;
 *  同一个分类ID,下载它的子分类集与子文档集通过两个不同的api链接，所以会有两个缓存文件。
 *
 *  @param type          notification,course_package
 *  @param contentType   category,slide
 *  @param ID     ID
 *
 *  @return cacheName
 */
+ (NSString *)cachePath:(NSString *)type Type:(NSString *)contentType ID:(NSString *)ID;

/**
 *  课程包数据写入缓存文件
 *
 *  @param packages 课程包Name
 *  @param ID       课程包ID
 */
+ (void)writeCoursePackages:(NSMutableDictionary *)packages ID:(NSString *)ID;

/**
 *  读取缓存信息
 *
 *  @param ID 课程包ID
 *
 *  @return 课程包数据
 */
+ (NSMutableDictionary *)coursePackages:(NSString *)ID;

/**
 *  课程包内容写入缓存 文件
 *
 *  @param package 课程包内容
 *  @param ID      课程包ID
 */
+ (void)writeCoursePackageContent:(NSMutableDictionary *)package ID:(NSString *)ID;

/**
 *  缓存文件读取课程包内容
 *
 *  @param ID 课程包ID
 *
 *  @return 课程包内容
 */
+ (NSMutableDictionary *)coursePackageContent:(NSString *)ID;


/**
 *  报名课程列表写入缓存文件
 *
 *  @param trainCourses 报名课程列表
 *  @param UID          用户ID
 */
+ (void)writeTrainCourses:(NSMutableDictionary*)trainCourses UID:(NSString *)UID;
/**
 *  缓存文件读取报名课程列表
 *
 *  @param UID 用户ID
 *
 *  @return 报名课程列表
 */
+ (NSMutableDictionary *)trainCourses:(NSString *)UID;

/**
 *  某培训班的签到列表写入缓存
 *
 *  @param trainSignins 某培训班的签到列表
 *  @param tid          某培训班的ID
 */
+ (void)writeTrainSignins:(NSMutableDictionary *)trainSignins courseID:(NSString *)tid;
/**
 *  某课程的签到列表
 *
 *  @param CID 课程ID
 *
 *  @return 课程的签到列表
 */
+ (NSMutableDictionary *)trainSignins:(NSString *)tid;

/**
 *  签到员工列表写入缓存(含状态)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 */
+ (void)writeTrainSigninScannedUsers:(NSMutableDictionary *)trainSigninUsers courseID:(NSString *)tid signinID:(NSString *)ciid;

/**
 *  某课程的签到学员列表(含状态)
 *
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 *
 *  @return 课程的签到列表
 */
+ (NSMutableDictionary *)trainSigninScannedUsers:(NSString *)tid signinID:(NSString *)ciid;

/**
 *  签到员工列表写入缓存(所有)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 */
+ (void)writeTrainSigninUsers:(NSMutableDictionary *)trainSigninUsers courseID:(NSString *)tid;

/**
 *  某课程的签到学员列表(所有)
 *
 *  @param tid              培训班ID
 *
 *  @return 课程的签到列表
 */
+ (NSMutableDictionary *)trainSigninUsers:(NSString *)tid;
@end
