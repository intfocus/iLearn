//
//  ApiUtils.m
//  iSearch
//
//  Created by lijunjie on 15/6/23.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataHelper.h"

#import "User.h"
#import "HttpResponse.h"
#import "FileUtils.h"
#import "DateUtils.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "ApiHelper.h"
#import "CacheHelper.h"
#import "ExtendNSLogFunctionality.h"
#import "CoursePackage.h"
#import "CoursePackageContent.h"
#import "CoursePackageDetail.h"
#import "CourseWrap+CoursePackageDetail.h"
#import "TrainCourse.h"
#import "CourseSignin.h"

@interface DataHelper()
@property (nonatomic, strong) NSMutableArray *visitData;

@end
@implementation DataHelper

- (DataHelper *)init {
    if(self = [super init]) {
        _visitData = [[NSMutableArray alloc] init];
    }
    return self;
}

/**
 *  获取通知公告数据
 *
 *  @return 通知公告数据列表
 */
+ (NSMutableDictionary *)notifications {
    
    //无网络，读缓存
    if(![HttpUtils isNetworkAvailable]) {
        return [CacheHelper notifications];
    }
    
    // 从服务器端获取[公告通知]
    NSString *currentDate = [DateUtils dateToStr:[NSDate date] Format:DATE_SIMPLE_FORMAT];
    HttpResponse *httpResponse = [ApiHelper notifications:currentDate DeptID:[User deptID]];
    
    if([httpResponse isValid]) { [CacheHelper writeNotifications:httpResponse.data]; }
    
    return httpResponse.data;
}

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
                    Ascending:(BOOL)asceding {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:asceding];
    NSArray *array = [mutableArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    return [NSMutableArray arrayWithArray:array];
}

/**
 *  同步用户行为操作
 *
 *  @param unSyncRecords 未同步数据
 */
+ (NSMutableArray *)actionLog:(NSMutableArray *)unSyncRecords {
    NSMutableArray *IDS = [[NSMutableArray alloc] init];
    if([unSyncRecords count] == 0) {
        return IDS;
    }

    NSString *ID;
    HttpResponse *httpResponse;
    for(NSMutableDictionary *dict in unSyncRecords) {
        ID = dict[@"id"]; [dict removeObjectForKey:@"id"];
        @try {
            httpResponse = [ApiHelper actionLog:dict];
            if([httpResponse isSuccessfullyPostActionLog]) {
                [IDS addObject:ID];
            }
        } @catch (NSException *exception) {
            NSLog(@"sync action log(%@) faild for %@#%@\n %@", dict, exception.name, exception.reason);
        } @finally {
        }
    }
    
    return IDS;
}

/**
 *  课程包列表
 *
 *  @param isNetworkAvailable 无网络读取缓存，有网络读取服务器
 *
 *  @return 课程包列表
 */
+ (NSArray *)coursePackages:(BOOL)isNetworkAvailable {
    NSMutableDictionary *packages = [[NSMutableDictionary alloc] init];
    NSArray *dataList             = [[NSArray alloc] init];
    NSString *PID                 = [User userID];
    
    if(isNetworkAvailable) {
        HttpResponse *httpResponse = [ApiHelper coursePackages:PID];
        packages = httpResponse.data;
        
        [CacheHelper writeCoursePackages:packages ID:PID];
    }
    else {
        packages = [CacheHelper coursePackages:PID];
    }

    dataList = packages[COURSE_PACKAGES_FIELD_DATA];
    if(dataList && [dataList count] > 0) {
        NSMutableArray *sortArray = [self sortArray:[NSMutableArray arrayWithArray:dataList] Key:@"Name" Ascending:YES];
        NSMutableArray *coursePackages = [[NSMutableArray alloc] init];
        for(NSDictionary *data in sortArray) {
            [coursePackages addObject: [[CoursePackage alloc] initWithData:data]];
        }
        dataList = [NSArray arrayWithArray:coursePackages];
    }
    return dataList;
}

/**
 *  课程包内容明细
 
 *  @param isNetworkAvailable 无网络读取缓存，有网络读取服务器
 *  @param pid package ID
 *
 *  @return 课程包内容明细
 */
+ (NSArray *)coursePackageContent:(BOOL)isNetworkAvaliable pid:(NSString *)PID {
    NSMutableDictionary *packages = [NSMutableDictionary dictionary];
    
    if(isNetworkAvaliable) {
        HttpResponse *httpResponse = [ApiHelper coursePackageContent:PID];
        packages = httpResponse.data;
        
        [CacheHelper writeCoursePackageContent:packages ID:PID];
    }
    else {
        packages = [CacheHelper coursePackageContent:PID];
    }

    NSDictionary *content = packages[COURSE_PACKAGES_FIELD_DATA];
    CoursePackageContent *packageContent = [[CoursePackageContent alloc] initWithData:content];
    NSArray *dataList = [NSArray array];
    dataList = [dataList arrayByAddingObjectsFromArray:[CoursePackageDetail loadCourses:packageContent.courseList]];
    dataList = [dataList arrayByAddingObjectsFromArray:[CourseWrap loadCourseWraps:packageContent.courseWrapList]];
    dataList = [dataList arrayByAddingObjectsFromArray:[CoursePackageDetail loadExams:packageContent.examList]];
    dataList = [dataList arrayByAddingObjectsFromArray:[CoursePackageDetail loadQuestions:packageContent.questionList]];
    
    return dataList;
}

/**
 *  培训班课程列表
 *
 *  @param isNetworkAvaliable 网络环境
 *
 *  @return 培训班列表
 */
+ (NSArray *)trainCourses:(BOOL)isNetworkAvaliable {
    NSMutableDictionary *trainCourses = [NSMutableDictionary dictionary];
    NSString *uid = [User userID];
    
    if(isNetworkAvaliable) {
        HttpResponse *response = [ApiHelper courseCourses:uid];;
        trainCourses = response.data;
        
        [CacheHelper writeTrainCourses:trainCourses UID:uid];
    }
    else {
        trainCourses = [CacheHelper trainCourses:uid];
    }
    NSArray *courses = [TrainCourse loadCourseData:trainCourses[@"trainingsdata"]];
    NSArray *signins = [TrainCourse loadSigninData:trainCourses[@"tmanagerdata"]];
    
    return [courses arrayByAddingObjectsFromArray:signins];
}

/**
 *  某课程的签到列表
 *
 *  @param isNetworkAvailabel 网络环境
 *  @param tid                课程ID
 *
 *  @return 课程的签到列表
 */
+ (NSArray *)trainSingins:(BOOL)isNetworkAvailable courseID:(NSString *)tid {
    NSMutableDictionary *signins = [NSMutableDictionary dictionary];
    
    if(isNetworkAvailable) {
        HttpResponse *response = [ApiHelper courseSignins:tid];;
        signins = response.data;
        
        [CacheHelper writeTrainSignins:signins courseID:tid];
    }
    else {
        signins = [CacheHelper trainSignins:tid];
    }
    
    
    return signins[@"data"];
}

/**
 *  某课程的签到学员列表(含状态)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 *
 *  @return 课程的签到列表
 */
+ (NSArray *)trainSigninScannedUsers:(BOOL)isNetworkAvailable
                            courseID:(NSString *)tid
                            signinID:(NSString *)ciid {
    NSMutableDictionary *trainSigninUsers = [NSMutableDictionary dictionary];
    NSArray *dataLits = [NSArray array];
    
    if(isNetworkAvailable) {
        HttpResponse *response = [ApiHelper courseSigninScannedUsers:tid signinID:ciid];
        trainSigninUsers = response.data;
        dataLits = trainSigninUsers[@"traineesdata"];
        
        [CacheHelper writeTrainSigninScannedUsers:trainSigninUsers courseID:tid signinID:ciid];
        [CourseSignin serverDataToLocal:trainSigninUsers courseID:tid signinID:ciid];
    }
    else {
        // trainSigninUsers = [CacheHelper trainSigninScannedUsers:tid signinID:ciid];
        dataLits = [CourseSignin scannedUsers:tid signinID:ciid];
    }
    
    return dataLits;
}

/**
 *  某课程的签到学员列表(所有)
 *
 *  @param trainSigninUsers 签到员工列表
 *  @param tid              培训班ID
 *  @param ciid             签到ID
 *
 *  @return 课程的签到列表
 */
+ (NSDictionary *)trainSigninUsers:(BOOL)isNetworkAvailable tid:(NSString *)tid {
    NSMutableDictionary *trainSigninUsers = [NSMutableDictionary dictionary];
    
    if(isNetworkAvailable) {
        HttpResponse *response = [ApiHelper courseSigninUsers:tid];;
        trainSigninUsers = response.data;
        
        [CacheHelper writeTrainSigninUsers:trainSigninUsers courseID:tid];
    }
    else {
        trainSigninUsers = [CacheHelper trainSigninUsers:tid];
    }
    
    return trainSigninUsers;
}

/**
 *  报名POST
 *
 *  @param TID 课程ID
 */
+ (void)trainSignup:(NSString *)TID {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"UserId"]     = [User userID];
    param[@"TrainingId"] = TID;
    HttpResponse *response = [ApiHelper courseSignup:param];
    NSString *log = [NSString stringWithFormat:@"userID: %@, courseID: %@, httpStatusCode:%@, response: %@", param[@"UserId"], param[@"TrainingId"], response.statusCode, response.string];
    ActionLogRecord(@"课程报名", log);
}

#pragma mark - assistant methods
+ (NSString *)dictToParams:(NSMutableDictionary *)dict {
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for(NSString *key in dict) {
        [paramArray addObject:[NSString stringWithFormat:@"%@=%@", key, dict[key]]];
    }
    return [paramArray componentsJoinedByString:@"&"];
}
@end