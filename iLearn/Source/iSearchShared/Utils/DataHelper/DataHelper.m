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

#pragma mark - assistant methods
+ (NSString *)dictToParams:(NSMutableDictionary *)dict {
    NSMutableArray *paramArray = [[NSMutableArray alloc] init];
    for(NSString *key in dict) {
        [paramArray addObject:[NSString stringWithFormat:@"%@=%@", key, dict[key]]];
    }
    return [paramArray componentsJoinedByString:@"&"];
}
//+ (NSString *)postActionLog:(NSMutableDictionary *) params {
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSString *url = [ApiUtils apiUrl:ACTION_LOGGER_URL_PATH];
//    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//    
//    return @"";
//}

#pragma mark - funny methods
- (void)traverseVisitContent:(NSString *)categoryID Depth:(NSInteger)depth {
    HttpResponse *httpResponse;
    NSDate *date = [NSDate date];
    NSInteger categoryCount = 0, slideCount = 0;
    
    httpResponse = [ApiHelper slides:categoryID DeptID:[User deptID]];
    [CacheHelper writeContents:httpResponse.data Type:CONTENT_SLIDE ID:categoryID];
    slideCount = [httpResponse.data[CONTENT_FIELD_DATA] count];
    
    httpResponse = [ApiHelper categories:categoryID DeptID:[User deptID]];
    [CacheHelper writeContents:httpResponse.data Type:CONTENT_CATEGORY ID:categoryID];
    categoryCount = [httpResponse.data[CONTENT_FIELD_DATA] count];
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    NSLog(@"depth:%i, categoryID:%@, slides: %i, categories: %i, duration: %i(ms)", depth, categoryID, slideCount, categoryCount, (int)(interval*1000));
    [self.visitData addObject:@[[NSNumber numberWithInteger:depth], categoryID, [NSNumber numberWithInteger:slideCount], [NSNumber numberWithInteger:categoryCount], [NSNumber numberWithDouble:interval]]];
    
    NSMutableDictionary *responseJSON = httpResponse.data;
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    if(responseJSON[CONTENT_FIELD_DATA]) {
        mutableArray = [NSMutableArray arrayWithArray:responseJSON[CONTENT_FIELD_DATA]];
        for(NSMutableDictionary *dict in mutableArray) {
            [self traverseVisitContent:dict[CONTENT_FIELD_ID] Depth:depth+1];
        }
    }
}

- (void)traverseVisitReport {
    NSInteger maxDepth=0, maxSlides=0, maxCategories=0, slideCount=0, categoryCount=0;
    double duration = 0.0;
    for(NSArray *array in self.visitData) {
        if([array[0] intValue] > maxDepth)      maxDepth      = [array[0] intValue];
        if([array[2] intValue] > maxSlides)     maxSlides     = [array[2] intValue];
        if([array[3] intValue] > maxCategories) maxCategories = [array[3] intValue];
        
        
        slideCount    += [array[2] intValue];
        categoryCount += [array[3] intValue];
        duration      += [array[4] doubleValue];
    }
    User *user = [[User alloc] init];
    NSLog(@"name: %@, deptID:%@, employeeID: %@", user.name, user.deptID, user.employeeID);
    NSLog(@"maxDepth: %i, maxSlides: %i, maxCategories: %i", maxDepth, maxSlides, maxCategories);
    NSLog(@"slideCount: %i, categoryCount: %i", slideCount, categoryCount);
    NSLog(@"averageVisit: %i (max)", (int)(duration/categoryCount*1000));
    NSLog(@"self:%i, caculate: %i, isValid: %i", [self.visitData count], categoryCount, [self.visitData count] == categoryCount);
}
@end