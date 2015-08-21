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
@property (nonatomic, strong) NSString *courseID;
@property (nonatomic, strong) NSString *courseName;
@property (nonatomic, strong) NSString *courseDesc;
@property (nonatomic, strong) NSString *courseFile;
@property (nonatomic, strong) NSString *courseExt;
@property (nonatomic, strong) NSString *courseFileSize;

// 考试字段
@property (nonatomic, strong) NSString *examID;
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

// 问卷字段
@property (nonatomic, strong) NSString *questionID;
@property (nonatomic, strong) NSString *questionName;
@property (nonatomic, strong) NSString *questionDesc;
@property (nonatomic, strong) NSString *questionTemplateID;
@property (nonatomic, strong) NSString *questionStartDate;
@property (nonatomic, strong) NSString *questionEndDate;
@property (nonatomic, strong) NSString *questionCreaterID;
@property (nonatomic, strong) NSString *questionStatus;


// local
@property (nonatomic, strong) NSDictionary *examDictContent;
@property (nonatomic, strong) NSDictionary *questionDictContent;


// instance methods
- (CoursePackageDetail *)init:(NSDictionary *)data Type:(NSString *)typeName;
- (NSString *)name;
- (NSString *)desc;
- (NSString *)typeName;

- (BOOL)isExam;
- (BOOL)isQuestion;
- (BOOL)isCourseWrap;

- (BOOL)isCourse;
- (BOOL)isVideo;
- (BOOL)isPDF;
- (BOOL)isHTML;
- (BOOL)canRemove;
- (NSString *)infoButtonImage;
/**
 *  pdf阅读进度
 *
 *  @return float 相对y偏移量
 */
- (float)pdfProgress;

/**
 *  记录课件学习进度
 *
 *  @param dict 学习进度
 */
- (void)recordProgress:(NSDictionary *)dict;

- (BOOL)isExamDownload;
- (BOOL)isQuestionDownload;

/**
 *  课件状态标签
 *
 *  @return 状态
 */
- (NSArray *)statusLabelText;

// class methods
+ (NSMutableArray *)loadData:(NSArray *)dataList Type:(NSString *)typeName;
+ (NSArray *)loadCourses:(NSArray *)courses;
+ (NSArray *)loadExams:(NSArray *)exams;
+ (NSArray *)loadQuestions:(NSArray *)questions;

@end
