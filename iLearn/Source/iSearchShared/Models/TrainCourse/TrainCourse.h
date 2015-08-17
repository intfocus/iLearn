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
@property (nonatomic, strong) NSString *begin;
@property (nonatomic, strong) NSString *end;
@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *memo;
@property (nonatomic, strong) NSString *manager;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *approreLevel;
@property (nonatomic, strong) NSString *traineesStatus;

@property (nonatomic, strong) NSString *type;

// instance methods
+ (NSArray *)loadCourseData:(NSArray *)dataList;
+ (NSArray *)loadSigninData:(NSArray *)dataList;

+ (NSArray *)loadData:(NSArray *)dataList type:(NSString *)typeName;
- (NSString *)desc;
- (BOOL)isCourse;
- (BOOL)isSignin;
- (NSString *)statusName;
- (NSString *)actionButtonLabel;
@end
