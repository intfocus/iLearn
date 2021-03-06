//
//  Url.h
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//
#import "BaseModel.h"
/**
 *  api链接统一管理
 */
@interface Url : BaseModel

@property (nonatomic, strong) NSString *base;
// 登录
@property (nonatomic, strong) NSString *login;
// 通知公告
@property (nonatomic, strong) NSString *notifications;
// 行为记录
@property (nonatomic, strong) NSString *actionLog;
//// 批量下载
//@property (nonatomic, strong) NSString *slideList;
// 课程包
@property (nonatomic, strong) NSString *coursePackages;
@property (nonatomic, strong) NSString *coursePackageContent;
@property (nonatomic, strong) NSString *downloadCourse;
// 培训报名
@property (nonatomic, strong) NSString *trainCourses; // 报名列表
@property (nonatomic, strong) NSString *courseSignup; // 报名POST
@property (nonatomic, strong) NSString *courseSignins; // 培训报名签到列表
@property (nonatomic, strong) NSString *courseSignin; // 培训报名签到CRUD
@property (nonatomic, strong) NSString *courseSigninUsers; // 培训报表签到员工列表（所有，不含状态）
@property (nonatomic, strong) NSString *courseSigninScannedUsers; // 培训报表签到员工列表（只含状态的员工列表)
@property (nonatomic, strong) NSString *courseSigninUser; // 创建点名POST

@property (nonatomic, strong) NSString *uploadFile;
@property (nonatomic, strong) NSString *downloadFile;

@property (nonatomic, strong) NSString *uploadedExams;
@property (nonatomic, strong) NSString *uploadedExamResult;
@end
