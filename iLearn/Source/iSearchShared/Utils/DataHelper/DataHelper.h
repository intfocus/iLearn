//
//  ApiUtils.h
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_DataHelper_h
#define iSearch_DataHelper_h
#import <UIKit/UIKit.h>

/**
 *  处理数据: ApiHelper + CacheHelper
 */
@interface DataHelper : NSObject

/**
 *  获取通知公告数据
 *
 *  @return 通知公告数据列表
 */
+ (NSMutableDictionary *)notifications;

/**
 *  给元素为字典的数组排序；
 *  需求: 分类、文档顺序排放，然后各自按ID/名称/更新日期排序
 *
 *  @param mutableArray mutableArray
 *  @param key          数组元素的key
 *  @param asceding     是否升序
 *
 *  @return 排序过的数组
 */
+ (NSMutableArray *)sortArray:(NSMutableArray *)mutableArray
                          Key:(NSString *)key
                    Ascending:(BOOL)asceding;

/**
 *  同步用户行为操作
 *
 *  @param unSyncRecords 未同步数据
 */
+ (NSMutableArray *)actionLog:(NSMutableArray *)unSyncRecords;

/**
 *  课程包列表
 *
 *  @param isNetworkAvailable 无网络读取缓存，有网络读取服务器
 *
 *  @return 课程包列表
 */
+ (NSArray *)coursePackages:(BOOL)isNetworkAvailable;

/**
 *  课程包内容明细
 
 *  @param isNetworkAvailable 无网络读取缓存，有网络读取服务器
 *  @param pid package ID
 *
 *  @return 课程包内容明细
 */
+ (NSArray *)coursePackageContent:(BOOL)isNetworkAvaliable pid:(NSString *)PID;

/**
 *  培训班课程列表
 *
 *  @param isNetworkAvaliable 网络环境
 *
 *  @return 培训班列表
 */
+ (NSArray *)trainCourses:(BOOL)isNetworkAvaliable;

/**
 *  某课程的签到列表
 *
 *  @param isNetworkAvailabel 网络环境
 *  @param tid                课程ID
 *
 *  @return 课程的签到列表
 */
+ (NSArray *)trainSingins:(BOOL)isNetworkAvailable courseID:(NSString *)tid;

/**
 *  报名POST
 *
 *  @param TID 课程ID
 */
+ (void)trainSignup:(NSString *)TID;

/**
 *  某课程的签到学员列表(含状态)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 *
 *  @return 课程的签到列表
 */
+ (NSArray *)trainSigninScannedUsers:(BOOL)isNetworkAvailable courseID:(NSString *)tid signinID:(NSString *)ciid;

/**
 *  某课程的签到学员列表(所有)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 *
 *  @return 课程的签到列表
 */
+ (NSDictionary *)trainSigninUsers:(BOOL)isNetworkAvailable tid:(NSString *)tid;

/**
 *  提交过的考试列表
 *
 *  @param isNetworkAvailable 网络环境
 *  @param userID             用户ID
 */
+ (NSMutableDictionary *)uploadedExams:(BOOL)isNetworkAvailable userID:(NSString *)userID;

/**
 *  提交过的考试答案
 *
 *  @param isNetworkAvailable 网络环境
 *  @param userID             用户ID
 *  @param examID             考试ID
 *
 *  @return 考试答案
 */
+ (NSMutableDictionary *)uploadedExamResult:(BOOL)isNetworkAvailable userID:(NSString *)userID examID:(NSString *)examID;
@end

#endif
