//
//  CoursePackageDetail.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageDetail.h"
#import "FileUtils.h"
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

/**
 *  课件功能按钮的显示状态
 *
 *  @return 状态
 */
- (NSString *)actionButtonState {
    NSString *statu;
    if([self.type isEqualToString:kPackageCourse]) {
        if([FileUtils isCourseReaded:self.courseId Ext:self.courseExt]) {
            statu = @"继续学习";
        }
        else if ([FileUtils isCourseDownloaded:self.courseId Ext:self.courseExt]) {
            statu = @"开始学习";
        }
        else {
            statu = @"下载";
        }
    } else if([self.type isEqualToString:kPackageExam]) {
        statu = @"开始考试";// 查看结果
    } else if([self.type isEqualToString:kPackageQuestion]) {
        statu = @"开始填写";
    } else {
        statu = @"unkown type";
    }
    return statu;
}

/**
 *  课件状态标签
 *
 *  @return 状态
 */
- (NSString *)statusLabelText {
    NSString *statu;
    if([self.type isEqualToString:kPackageCourse]) {
        NSString *fileName = [NSString stringWithFormat:@"%@.%@", self.courseId, self.courseExt];
        if([FileUtils isCourseReaded:self.courseId Ext:self.courseExt]) {
            statu = @"学习完成";
        }
        else if ([FileUtils isCourseDownloaded:self.courseId Ext:self.courseExt]) {
            statu = @"尚未学习";
        }
        else {
            statu = @"未下载";
        }
    } else if([self.type isEqualToString:kPackageExam]) {
        statu = @"开始考试";// 查看结果
    } else if([self.type isEqualToString:kPackageQuestion]) {
        statu = @"开始填写";
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
