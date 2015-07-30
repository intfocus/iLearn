//
//  CoursePackageDetail.h
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "BaseModel.h"

@interface CoursePackageDetail : BaseModel

@property (nonatomic, strong) NSString *type;

// 课件字段
@property (nonatomic, strong) NSString *courseId;
@property (nonatomic, strong) NSString *courseName;
@property (nonatomic, strong) NSString *courseDesc;
@property (nonatomic, strong) NSString *courseFile;
@property (nonatomic, strong) NSString *courseExt;

// 考试字段
@property (nonatomic, strong) NSString *examId;
@property (nonatomic, strong) NSString *examName;
@property (nonatomic, strong) NSString *examType;
@property (nonatomic, strong) NSString *examLocation;
@property (nonatomic, strong) NSString *examAnsType;
@property (nonatomic, strong) NSString *examPassword;
@property (nonatomic, strong) NSString *examDesc;
@property (nonatomic, strong) NSString *examContent;
@property (nonatomic, strong) NSString *examDuration;
@property (nonatomic, strong) NSString *examAllowTime;
@property (nonatomic, strong) NSString *examQualifyPercent;


- (CoursePackageDetail *)initWithCourse:(NSDictionary *)data;

+ (NSArray *)loadDataFromCourse:(NSArray *)courses;
@end
