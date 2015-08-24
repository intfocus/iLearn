//
//  TrainCourse.h
//  iLearn
//
//  Created by lijunjie on 15/8/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "BaseModel.h"

@interface TrainCourse : BaseModel

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *lecturer;
@property (nonatomic, strong) NSString *begin; // 课程开始时间
@property (nonatomic, strong) NSString *end; // 课程结束时间
@property (nonatomic, strong) NSString *startDate; // 报名开始时间
@property (nonatomic, strong) NSString *endDate; // 报名截止时间
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, strong) NSString *manager;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *approreLevel;
@property (nonatomic, strong) NSString *traineesStatus;

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *originalDict;

// instance methods
+ (NSArray *)loadCourseData:(NSArray *)dataList;
+ (NSArray *)loadSigninData:(NSArray *)dataList;

+ (NSArray *)loadData:(NSArray *)dataList type:(NSString *)typeName;
- (TrainCourse *)initCourseData:(NSDictionary *)dict;
- (TrainCourse *)initSigninData:(NSDictionary *)dict;
- (NSString *)desc;
- (BOOL)isCourse;
- (BOOL)isSignin;
- (NSString *)statusName;
- (NSString *)actionButtonLabel;
/**
 *  报名状态不同，显示截止日期不同
 *
 *  @return 截止日期
 */
- (NSString *)availabelTime;
@end
