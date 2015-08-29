//
//  CacheHelper.m
//  iSearch
//
//  Created by lijunjie on 15/7/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "CacheHelper.h"
#import "const.h"
#import "FileUtils.h"

@implementation CacheHelper
/**
 *  读取本地缓存通知公告数据
 *
 *  @return 数据列表
 */
+ (NSMutableDictionary *)notifications {
    NSString *cachePath = [self cachePath:@"notification" Type:@"nil" ID:@"nil"];
    
    NSMutableDictionary *notificationDatas = [[NSMutableDictionary alloc] init];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        notificationDatas = [FileUtils readConfigFile:cachePath];
    }
    
    return notificationDatas;
}
/**
 *  缓存服务器获取到的数据
 *
 *  @param notificationDatas 服务器获取到的数据
 */
+ (void)writeNotifications:(NSMutableDictionary *)notificationDatas {
    if(!notificationDatas) return;
    
    NSString *cachePath = [self cachePath:@"notification" Type:@"nil" ID:@"nil"];
    [FileUtils writeJSON:notificationDatas Into:cachePath];
}

/**
 *  课程包数据写入缓存文件
 *
 *  @param packages 课程包Name
 *  @param ID       课程包ID
 */
+ (void)writeCoursePackages:(NSMutableDictionary *)packages ID:(NSString *)ID {
    if(!packages)  return;
    
    NSString *cachePath = [self cachePath:@"course" Type:@"package" ID:ID];
    [FileUtils writeJSON:packages Into:cachePath];
}

/**
 *  读取缓存信息
 *
 *  @param ID 课程包ID
 *
 *  @return 课程包数据
 */
+ (NSMutableDictionary *)coursePackages:(NSString *)ID {
    NSString *cachePath = [self cachePath:@"course" Type:@"package" ID:ID];
  
    NSMutableDictionary *packages = [[NSMutableDictionary alloc] init];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        packages = [FileUtils readConfigFile:cachePath];
    }
    
    return packages;
}

/**
 *  课程包内容写入缓存 文件
 *
 *  @param package 课程包内容
 *  @param ID      课程包ID
 */
+ (void)writeCoursePackageContent:(NSMutableDictionary *)package ID:(NSString *)ID {
    if(!package)  return;
    
    NSString *cachePath = [self cachePath:@"course" Type:@"content" ID:ID];
    [FileUtils writeJSON:package Into:cachePath];
}

/**
 *  缓存文件读取课程包内容
 *
 *  @param ID 课程包ID
 *
 *  @return 课程包内容
 */
+ (NSMutableDictionary *)coursePackageContent:(NSString *)ID {
    NSString *cachePath = [self cachePath:@"course" Type:@"content" ID:ID];
    
    NSMutableDictionary *package = [[NSMutableDictionary alloc] init];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        package = [FileUtils readConfigFile:cachePath];
    }
    
    return package;
}

/**
 *  报名课程列表写入缓存文件
 *
 *  @param trainCourses 报名课程列表
 *  @param UID          用户ID
 */
+ (void)writeTrainCourses:(NSMutableDictionary*)trainCourses UID:(NSString *)UID {
    if(!trainCourses)  return;
    
    NSString *cachePath = [self cachePath:@"train" Type:@"course" ID:UID];
    [FileUtils writeJSON:trainCourses Into:cachePath];
}
/**
 *  缓存文件读取报名课程列表
 *
 *  @param UID 用户ID
 *
 *  @return 报名课程列表
 */
+ (NSMutableDictionary *)trainCourses:(NSString *)UID {
    NSString *cachePath = [self cachePath:@"train" Type:@"course" ID:UID];
   //cachePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"JsonTemplate/Registration/courses.json"];
    
    NSMutableDictionary *trainCourses = [NSMutableDictionary dictionary];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        trainCourses = [FileUtils readConfigFile:cachePath];
    }
    
    return trainCourses;
}

/**
 *  某培训班的签到列表写入缓存
 *
 *  @param trainSignins 某培训班的签到列表
 *  @param tid          某培训班的ID
 */
+ (void)writeTrainSignins:(NSMutableDictionary *)trainSignins courseID:(NSString *)tid {
    if(!trainSignins)  return;
    
    NSString *cachePath = [self cachePath:@"train" Type:@"signins" ID:tid];
    [FileUtils writeJSON:trainSignins Into:cachePath];
}
/**
 *  某课程的签到列表
 *
 *  @param CID 课程ID
 *
 *  @return 课程的签到列表
 */
+ (NSMutableDictionary *)trainSignins:(NSString *)tid {
    NSString *cachePath = [self cachePath:@"train" Type:@"signins" ID:tid];
    //cachePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"JsonTemplate/Registration/signins.json"];
    
    NSMutableDictionary *singins = [NSMutableDictionary dictionary];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        singins = [FileUtils readConfigFile:cachePath];
    }
    
    return singins;
}

/**
 *  签到员工列表写入缓存(含状态)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 */
+ (void)writeTrainSigninScannedUsers:(NSMutableDictionary *)trainSigninUsers courseID:(NSString *)tid signinID:(NSString *)ciid {
    if(!trainSigninUsers)  return;
    
    NSString *cachePath = [self cachePath:@"train_signin_users" Type:tid ID:ciid];
    [FileUtils writeJSON:trainSigninUsers Into:cachePath];
}

/**
 *  某课程的签到学员列表(含状态)
 *
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 *
 *  @return 课程的签到列表
 */
+ (NSMutableDictionary *)trainSigninScannedUsers:(NSString *)tid signinID:(NSString *)ciid {
    NSString *cachePath = [self cachePath:@"train_signin_users" Type:tid ID:ciid];
    //cachePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"JsonTemplate/Registration/users.json"];
    
    NSMutableDictionary *trainSigninUsers = [NSMutableDictionary dictionary];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        trainSigninUsers = [FileUtils readConfigFile:cachePath];
    }
    
    return trainSigninUsers;
}
/**
 *  签到员工列表写入缓存(所有)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 */
+ (void)writeTrainSigninUsers:(NSMutableDictionary *)trainSigninUsers courseID:(NSString *)tid {
    if(trainSigninUsers) {
        NSString *cachePath = [self cachePath:@"train_signin_users" Type:@"all" ID:tid];
        [FileUtils writeJSON:trainSigninUsers Into:cachePath];
    }
}

/**
 *  某课程的签到学员列表(所有)
 *
 *  @param tid              培训班ID
 *
 *  @return 课程的签到列表
 */
+ (NSMutableDictionary *)trainSigninUsers:(NSString *)tid  {
    NSString *cachePath = [self cachePath:@"train_signin_users" Type:@"all" ID:tid];
    
    NSMutableDictionary *trainSigninUsers = [NSMutableDictionary dictionary];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        trainSigninUsers = [FileUtils readConfigFile:cachePath];
    }
    
    return trainSigninUsers;
}

/**
 *  提交过的考试列表写入缓存。（已有用户空间概念，不需要再指定userID）
 *
 *  @param uploadedExams 提交过的考试列表
 */
+ (void)writeUploadedExams:(NSMutableDictionary *)uploadedExams {
    if(uploadedExams) {
        NSString *cachePath = [self cachePath:@"exams" Type:@"uploaded" ID:@"self"];
        [FileUtils writeJSON:uploadedExams Into:cachePath];
    }
}

/**
 *  缓存中的提交过的考试列表
 *
 *  @return 提交过的考试列表
 */
+ (NSMutableDictionary *)uploadedExams {
    NSMutableDictionary *uploadedExams = [NSMutableDictionary dictionary];
    
    NSString *cachePath = [self cachePath:@"exams" Type:@"uploaded" ID:@"self"];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        uploadedExams = [FileUtils readConfigFile:cachePath];
    }
    
    return uploadedExams;
}

/**
 *  提交过的考试结果写入缓存
 *
 *  @param examResult 考试结果
 *  @param userID     用户ID
 *  @param examID     考试ID
 */
+ (void)writeUploadedExamResult:(NSMutableDictionary *)examResult userID:(NSString *)userID examID:(NSString *)examID {
    if(examResult) {
        NSString *cachePath = [self cachePath:@"exam_result" Type:userID ID:examID];
        [FileUtils writeJSON:examResult Into:cachePath];
    }
}

/**
 *  缓存中的考试结果
 *
 *  @param userID     用户ID
 *  @param examID     考试ID
 *
 *  @return 考试结果
 */
+ (NSMutableDictionary *)uploadedExamResult:(NSString *)userID examID:(NSString *)examID {
    NSMutableDictionary *examResult = [NSMutableDictionary dictionary];
    
    NSString *cachePath = [self cachePath:@"exam_result" Type:userID ID:examID];
    if([FileUtils checkFileExist:cachePath isDir:NO]) {
        examResult = [FileUtils readConfigFile:cachePath];
    }
    
    return examResult;
}
#pragma mark - asisstant methods
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
+ (NSString *)cachePath:(NSString *)type Type:(NSString *)contentType ID:(NSString *)ID {
    NSString *cacheName = [NSString stringWithFormat:@"%@-%@-%@.cache",type, contentType, ID];
    NSString *cachePath = [FileUtils dirPath:CACHE_DIRNAME FileName:cacheName];
    return cachePath;
}
@end
