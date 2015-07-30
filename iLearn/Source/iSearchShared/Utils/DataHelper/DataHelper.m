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
        return [CacheHelper readNotifications];
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
    if([unSyncRecords count] == 0) { return IDS; }

    NSString *ID;
    HttpResponse *httpResponse;
    for(NSMutableDictionary *dict in unSyncRecords) {
        ID = dict[@"id"]; [dict removeObjectForKey:@"id"];
        @try {
            httpResponse = [ApiHelper actionLog:dict];
            if([httpResponse isSuccessfullyPostActionLog]) { [IDS addObject:ID]; }
        } @catch (NSException *exception) {
            NSLog(@"sync action log(%@) faild for %@#%@\n %@", dict, exception.name, exception.reason);
        } @finally {
            [IDS addObject:ID];
        }
    }
    
    return IDS;
}

/**
 *  课程包列表
 *
 *  @return 课程包列表
 */
+ (NSArray *)coursePackages {
    //无网络，读缓存
//    if(![HttpUtils isNetworkAvailable]) {
//        return [CacheHelper readNotifications];
//    }
    
    HttpResponse *httpResponse = [ApiHelper coursePackages:@"1"];
    
//    if([httpResponse isValid]) {
//        [CacheHelper writeNotifications:httpResponse.data];
//    }
    NSArray *dataList = httpResponse.data[COURSE_PACKAGES_FIELD_DATA];
    if([dataList count] > 0) {
        NSMutableArray *coursePackages = [[NSMutableArray alloc] init];
        for(NSDictionary *data in dataList) {
            [coursePackages addObject: [[CoursePackage alloc] initWithData:data]];
        }
        dataList = [NSArray arrayWithArray:coursePackages];
    }
    return dataList;
}

/**
 *  课程包内容明细
 *
 *  @return 课程包内容明细
 */
+ (NSArray *)coursePackageContent:(NSString *)PID {
    //无网络，读缓存
    //    if(![HttpUtils isNetworkAvailable]) {
    //        return [CacheHelper readNotifications];
    //    }
    
    HttpResponse *httpResponse = [ApiHelper coursePackageContent:PID];
    
    //    if([httpResponse isValid]) {
    //        [CacheHelper writeNotifications:httpResponse.data];
    //    }

    NSDictionary *content = httpResponse.data[COURSE_PACKAGES_FIELD_DATA];
    CoursePackageContent *packageContent = [[CoursePackageContent alloc] initWithData:content];
    NSArray *courseList = [CoursePackageDetail loadDataFromCourse:packageContent.courseList];
    
    return courseList;
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