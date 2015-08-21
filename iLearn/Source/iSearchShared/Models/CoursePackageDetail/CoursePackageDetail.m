//
//  CoursePackageDetail.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageDetail.h"
#import "FileUtils.h"
#import "ExamUtil.h"
/**
 *  课程包内容明细
 */

static NSString *const kPackageCourse     = @"PackageCourse";
static NSString *const kPackageQuestion   = @"PackageQuestion";
static NSString *const kPackageExam       = @"PackageExam";
static NSString *const kPackageCourseWrap = @"PackageCourseWrap";

@implementation CoursePackageDetail

- (CoursePackageDetail *)init:(NSDictionary *)data Type:(NSString *)typeName {
    if(self = [super init]) {
        _type               = typeName;

        _courseID           = data[@"CoursewareId"];
        _courseName         = data[@"CoursewareName"];
        _courseDesc         = data[@"CoursewareDesc"];
        _courseFile         = data[@"CoursewareFile"];
        _courseExt          = data[@"Extension"];
        _courseFileSize     = data[@"FileSize"];

        _examID             = data[@"ExamId"];
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
    
        _questionID         = data[@"QuestionId"];
        _questionName       = data[@"QuestionName"];
        _questionDesc       = data[@"QuestionDesc"];
        _questionStartDate  = data[@"StartTime"];
        _questionEndDate    = data[@"EndTime"];
        _questionCreaterID  = data[@"CreatedUser"];
        _questionTemplateID = data[@"QuestionTemplateId"];
        _questionStatus     = data[@"Status"];
    }
    
    return self;
}

- (NSString *)name {
    NSString *name;
    if([self.type isEqualToString:kPackageCourse]) {
        name = _courseName;
    }
    else if([self.type isEqualToString:kPackageExam]) {
        name = _examName;
    }
    else if([self.type isEqualToString:kPackageQuestion]) {
        name = _questionName;
    }
    else {
        name = @"unkown type";
    }
    return name;
}

- (NSString *)desc {
    NSString *desc;
    if([self.type isEqualToString:kPackageCourse]) {
        desc = [NSString stringWithFormat:@"文件大小: %@\n\n描述:\n%@", [FileUtils humanFileSize:_courseFileSize], _courseDesc];
    }
    else if([self.type isEqualToString:kPackageExam]) {
        desc = [NSString stringWithFormat:@"描述:\n%@", _examDesc];
    }
    else if([self.type isEqualToString:kPackageQuestion]) {
        desc = [NSString stringWithFormat:@"描述:\n%@", _questionDesc];
    }
    else {
        desc = @"unkown type";
    }
    return desc;
}

- (NSString *)typeName {
    NSString *name;
    if([self.type isEqualToString:kPackageCourse]) {
        name = @"课件";
    }
    else if([self.type isEqualToString:kPackageExam]) {
        name = @"练习考";
    }
    else if([self.type isEqualToString:kPackageQuestion]) {
        name = @"问卷";
    }
    else {
        name = @"unkown type";
    }
    return name;
}

/**
 *  课件状态标签
 *
 *  @return 状态
 */
- (NSArray *)statusLabelText {
    NSString *labelState, *btnState;
    if([self.type isEqualToString:kPackageCourse]) {
        if([FileUtils isCourseReaded:self.courseID Ext:self.courseExt]) {
            if([self isPDF]) {
                NSDictionary *dict = [FileUtils readConfigFile:[FileUtils courseProgressPath:self.courseID Ext:self.courseExt]];
                float ratio = [dict[@"readPercentage"] floatValue];
                if(ratio < 1.0) {
                    labelState = @"阅读不足1%";
                }
                else if(ratio >= 100.0 ){
                    labelState = @"学习完成";
                }
                else {
                    labelState = [NSString stringWithFormat:@"已阅读至%i%%", (int)ratio];
                }
            }
            else {
                labelState = @"学习完成";
            }
            btnState = @"继续学习";
        }
        else if ([FileUtils isCourseDownloaded:self.courseID Ext:self.courseExt]) {
            labelState = @"尚未学习";
            btnState   = @"开始学习";
        }
        else {
            labelState = @"未下载";
            btnState   = @"下载";
        }
    }
    else if([self.type isEqualToString:kPackageExam]) {
        if([self isExamDownload]) {
            NSNumber *score = self.examDictContent[ExamScore];
            if(score && [score intValue] >= 0) {
                labelState = [NSString stringWithFormat:NSLocalizedString(@"LIST_SCORE_TEMPLATE", nil), [score longLongValue]];
                btnState = @"查看结果";
            }
            else {
                labelState = @"未考试";
                btnState   = @"开始考试";
            }
        }
        else {
            labelState = @"未下载";
            btnState   = @"下载";
        }
    }
    else if([self.type isEqualToString:kPackageQuestion]) {
        labelState = @"开始填写";
        btnState   = @"TODO";
    }
    else {
        labelState = @"unkown type";
        btnState   = @"unkown type";
    }
    return @[labelState, btnState];
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
- (BOOL)isCourseWrap {
    return NO;
}

- (NSString *)infoButtonImage {
    NSString *imageName = @"icon_info";
    if([self isExam]) {
        imageName = @"course_exam";
    }
    else if([self isQuestion]) {
        imageName = @"course_question";
    }
    else if([self isCourse]) {
        imageName = @"course_course";
        if([self isHTML]) {
            imageName = @"course_html";
        }
        else if([self isPDF]) {
            imageName = @"course_pdf";
        }
        else if([self isVideo]) {
            imageName = @"course_video";
        }
    }
    return imageName;
}

#pragma mark - Around PDF
/**
 *  检查课程包类型
 *
 *  @param typeName 课程包类型
 *
 *  @return BOOL
 */
- (BOOL)checkType:(NSString *)typeName {
    return [self.type isEqualToString:kPackageCourse] && [[self.courseExt lowercaseString] isEqualToString:typeName];
}

- (BOOL)isVideo {
    return [self checkType:@"mp4"];
}
- (BOOL)isPDF {
    return [self checkType:@"pdf"];
}
- (BOOL)isHTML {
    return [self checkType:@"zip"];
}

- (BOOL)canRemove {
    return (([self isPDF] || [self isVideo]) && [FileUtils isCourseDownloaded:self.courseID Ext:self.courseExt]) ||
            ([self isExam] && [self isExamDownload]);
}
/**
 *  pdf阅读进度
 *
 *  @return float 相对y偏移量
 */
- (float)pdfProgress {
    NSDictionary *dict = [FileUtils readConfigFile:[FileUtils courseProgressPath:self.courseID Ext:self.courseExt]];
    return [dict[@"currentHeight"] floatValue];
}
/**
 *  记录课件学习进度
 *
 *  @param dict 学习进度
 */
- (void)recordProgress:(NSDictionary *)dict {
    [FileUtils recordProgress:dict CourseID:self.courseID Ext:self.courseExt];
}


#pragma mark - Around Exam
- (BOOL)isExamDownload {
    NSString *examPath = [FileUtils coursePath:self.examID Ext:@"json"];
    return [FileUtils checkFileExist:examPath isDir:NO];
}

- (NSDictionary *)examDictContent {
    NSString *examDBPath = [FileUtils coursePath:self.examID Ext:@"db"];
    if([FileUtils checkFileExist:examDBPath isDir:NO]) {
        _examDictContent = [ExamUtil contentFromDBFile:examDBPath];
    }
    else {
        NSString *examPath = [FileUtils coursePath:self.examID Ext:@"json"];
        _examDictContent = [FileUtils readConfigFile:examPath];
    }
        
    return _examDictContent;
}

#pragma mark - class methods

+ (NSArray *)loadData:(NSMutableArray *)dataList Type:(NSString *)typeName {
    if([dataList count] == 0) {
        return @[];
    }
    
    if([typeName isEqualToString:kPackageCourse]) {
        dataList = [self sortArray:dataList key:@"CoursewareName"];
    }
    else if([typeName isEqualToString:kPackageExam]) {
        dataList = [self sortArray:dataList key:@"ExamName"];
    }
    else if([typeName isEqualToString:kPackageQuestion]) {
        dataList = [self sortArray:dataList key:@"QuestionName"];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in dataList) {
        [array addObject:[[CoursePackageDetail alloc] init:dict Type:typeName]];
    }
    
    return [NSArray arrayWithArray:array];
}

+ (NSMutableArray *)sortArray:(NSMutableArray *)array key:(NSString *)keyName {
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:keyName ascending:YES];
    [array sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    return array;
}

+ (NSArray *)loadCourses:(NSArray *)courses {
    return [self loadData:[NSMutableArray arrayWithArray:courses] Type:kPackageCourse];
}
+ (NSArray *)loadExams:(NSArray *)exams {
   return [self loadData:[NSMutableArray arrayWithArray:exams] Type:kPackageExam];
}
+ (NSArray *)loadQuestions:(NSArray *)questions {
    return [self loadData:[NSMutableArray arrayWithArray:questions] Type:kPackageQuestion];
}
@end
