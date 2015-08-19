//
//  CourseSignin.h
//  iLearn
//
//  Created by lijunjie on 15/8/19.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "BaseModel.h"

@interface CourseSignin : BaseModel

@property (nonatomic, strong) NSString *courseID; // 课程ID
@property (nonatomic, strong) NSString *signinID; // 签到ID
@property (nonatomic, strong) NSString *employeeID; // 员工编号
@property (nonatomic, strong) NSString *userID; // 员工ID
@property (nonatomic, strong) NSString *createrID;
@property (nonatomic, strong) NSString *createAt;
@property (nonatomic, strong) NSString *choices;
@property (nonatomic, assign) BOOL isUpload;
@end
