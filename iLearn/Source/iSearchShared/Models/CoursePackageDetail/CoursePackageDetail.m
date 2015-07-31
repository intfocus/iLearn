//
//  CoursePackageDetail.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageDetail.h"
/**
 *  课程包内容明细
 */

static NSString *const kPackageCourse   = @"PackageCourse";
static NSString *const kPackageQuestion = @"PackageQuestion";
static NSString *const kPackageExam     = @"PackageExam";
static NSString *const kPackagePackage  = @"PackagePackage";

@implementation CoursePackageDetail

- (CoursePackageDetail *)init:(NSDictionary *)data Type:(NSString *)typeName {
    if(self = [super init]) {
        _type       = typeName;
        
        _courseId   = data[@"CoursewareId"];
        _courseName = data[@"CoursewareName"];
        _courseDesc = data[@"CoursewareDesc"];
        _courseFile = data[@"CoursewareFile"];
        _courseExt  = data[@"Extension"];
        
        _examId             = data[@"ExamId"];
        _examName           = data[@"ExamName"];
        _examDesc           = data[@"ExamDesc"];
        _examType           = data[@"ExamType"];
        _examLocation       = data[@"ExamLocation"];
        _examAnsType        = data[@"ExamAnsType"];
        _examPassword       = data[@"ExamPassword"];
        _examContent        = data[@"ExamContent"];
        _examDuration       = data[@"Duration"];
        _examAllowTime      = data[@"AllowTime"];
        _examQualifyPercent = data[@"QualifyPercent"];

    }
    return self;
}

- (NSString *)name {
    NSString *name;
    if([self.type isEqualToString:kPackageCourse]) {
        name = self.courseName;
    } else if([self.type isEqualToString:kPackageExam]) {
        name = self.examName;
    } else if([self.type isEqualToString:kPackageQuestion]) {
        name = @"Question todo";
    } else {
        name = @"unkown type";
    }
    return name;
}

- (NSString *)desc {
    NSString *desc;
    if([self.type isEqualToString:kPackageCourse]) {
        desc = self.courseDesc;
    } else if([self.type isEqualToString:kPackageExam]) {
        desc = self.examDesc;
    } else if([self.type isEqualToString:kPackageQuestion]) {
        desc = @"Question todo";
    } else {
        desc = @"unkown type";
    }
    return desc;
}

- (NSString *)typeName {
    NSString *name;
    if([self.type isEqualToString:kPackageCourse]) {
        name = @"课程";
    } else if([self.type isEqualToString:kPackageExam]) {
        name = @"考试";
    } else if([self.type isEqualToString:kPackageQuestion]) {
        name = @"问卷";
    } else {
        name = @"unkown type";
    }
    return name;
}

- (NSString *)actionButtonStatu {
    NSString *statu;
    if([self.type isEqualToString:kPackageCourse]) {
        statu = @"课程";
    } else if([self.type isEqualToString:kPackageExam]) {
        statu = @"考试";
    } else if([self.type isEqualToString:kPackageQuestion]) {
        statu = @"问卷";
    } else {
        statu = @"unkown type";
    }
    return statu;
}

- (BOOL)isExam {
    return [self.type isEqualToString:kPackageExam];
}
- (BOOL)isQuestion {
    return [self.type isEqualToString:kPackageQuestion];
}
- (BOOL)isCourse {
    return [self.type isEqualToString:kPackageCourse];
}
- (BOOL)isPackage {
    return [self.type isEqualToString:kPackagePackage];
}



+ (NSArray *)loadData:(NSArray *)dataList Type:(NSString *)typeName {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in dataList) {
        [array addObject:[[CoursePackageDetail alloc] init:dict Type:typeName]];
    }
    return [NSArray arrayWithArray:array];
}

+ (NSArray *)loadCourses:(NSArray *)courses {
    return [self loadData:courses Type:kPackageCourse];
}
+ (NSArray *)loadExams:(NSArray *)exams {
    return [self loadData:exams Type:kPackageExam];
}
+ (NSArray *)loadQuestions:(NSArray *)questions {
    return [self loadData:questions Type:kPackageQuestion];
}
@end
