//
//  CourseSignin.h
//  iLearn
//
//  Created by lijunjie on 15/8/19.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "BaseModel.h"
/**
 *  课程签到状态（某个员工）
 *  本质: 无论在线与否数据都先存放在本地，然后统一上传至服务器，
 *       从服务器拉取点击状态列表时也写入本地缓存，客户展示数据仅与缓存交互
 */
@interface CourseSignin : BaseModel

//@property (nonatomic, strong) NSString *courseID; // 课程ID
//@property (nonatomic, strong) NSString *signinID; // 签到ID
//@property (nonatomic, strong) NSString *userName; // 员工ID
//@property (nonatomic, strong) NSString *createrID;
@property (nonatomic, strong) NSString *employeeID; // 员工编号
@property (nonatomic, strong) NSString *userID; // 员工ID
@property (nonatomic, strong) NSString *createAt;
@property (nonatomic, strong) NSString *choices;
@property (nonatomic, assign) BOOL isUpload;

- (NSDictionary *)dictionary;
- (CourseSignin *)initLocalData:(NSDictionary *)dict;
- (CourseSignin *)initServerData:(NSDictionary *)dict;
+ (NSDictionary *)toLocal:(NSDictionary *)serverDict;
/**
 *  离线时，点名数据存放在本地；
 *  本质: 无论在线与否数据都先存放在本地，然后统一上传至服务器，
 *       从服务器拉取点击状态列表时也写入本地缓存，客户展示数据仅与缓存交互
 *
 *  @param courseID 课程ID
 *  @param signinID 签到ID
 *
 *  @return 缓存文件路径
 */
+ (NSString *)scannedFilePath:(NSString *)courseID
                     signinID:(NSString *)signinID;

/**
 *  从缓存文件，读取某个员工在某个课程某个签到中的状态
 *
 *  @param employeeID 员工编号
 *  @param courseID 课程ID
 *  @param signinID 签到ID
 *
 *  @return 签到状态；字符按逗号分隔
 */
+ (NSString *)findChoices:(NSString *)employeeID
                 courseID:(NSString *)courseID
                 signinID:(NSString *)signinID;

/**
 *  扫描签到某个员工信息后，写入本地缓存。
 *
 *  @param courseID 课程ID
 *  @param signinID 签到ID
 *  @param employeeID 员工编号
 *  @param choices  签到状态
 */
+ (void)saveToLocal:(NSString *)employeeID
            choices:(NSString *)choices
           courseID:(NSString *)courseID
           signinID:(NSString *)signinID;

/**
 *  本地点击数据推送至服务器
 *
 *  @param courseID   课程ID
 *  @param signinID   签到ID
 *  @param employeeID 员工编号
 *  @param createrID  点名人ID
 *  @param userID     签到创建人ID
 */
+ (void)postToServer:(NSString *)courseID
            signinID:(NSString *)signinID
           createrID:(NSString *)createrID;

/**
 *  服务器端点名状态的列表数据转换为本地数据
 *
 *  @param serverDict 服务器端点名状态的列表数据
 *  @param courseID   课程ID
 *  @param signinID   签到ID
 */
+ (void)serverDataToLocal:(NSDictionary *)serverDict
                 courseID:(NSString *)courseID
                 signinID:(NSString *)signinID;

/**
 *  点击过我员工列表信息(在线的，离线的)
 *  从服务器拉取数据前，先把提交本地未上传代码，再拉取最新数据，转换为本地格式，离线时可以继续点名，有网时上传
 *
 *  @param courseID   课程ID
 *  @param signinID   签到ID
 *
 *  @return 点击过我员工列表信息(在线的，离线的)
 */
+ (NSArray *)scannedUsers:(NSString *)courseID signinID:(NSString *)signinID;
@end
