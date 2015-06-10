//
//  Constants.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

typedef NS_ENUM(NSUInteger, ListViewType) {
    ListViewTypeExam,
    ListViewTypeQuestionnaire,
    ListViewTypeRegistration,
    ListViewTypeLecture,
};

typedef NS_ENUM(NSUInteger, ExamTypes) {
    ExamTypesPractice = 0,
    ExamTypesFormal,
};

typedef NS_ENUM(NSUInteger, ExamSubjectType) {
    ExamSubjectTypeTrueFalse = 1,
    ExamSubjectTypeSingle,
    ExamSubjectTypeMultiple,
};

extern NSString *const ServiceNumber;
extern NSString *const FakeAccount;

extern NSString *const CacheFolder;
extern NSString *const QuestionnaireFolder;
extern NSString *const ExamFolder;

extern NSString *const CommonFileName;

extern NSString *const QuestionnaireTitle;
extern NSString *const QuestionnaireDesc;
extern NSString *const QuestionnaireExpirationDate;
extern NSString *const QuestionnaireStatus;
extern NSString *const QuestionnaireQuestions;
extern NSString *const QuestionnaireQuestionTitle;
extern NSString *const QuestionnaireQuestionAnswers;
extern NSString *const QuestionnaireQuestionAnswerTitle;

extern NSString *const Exams;
extern NSString *const ExamId;
extern NSString *const ExamTitle;
extern NSString *const ExamDesc;
extern NSString *const ExamBeginDate;
extern NSString *const ExamEndDate;
extern NSString *const ExamExpirationDate;
extern NSString *const ExamStatus;
extern NSString *const ExamSubmitted;
extern NSString *const ExamType;
extern NSString *const ExamAnsType;
extern NSString *const ExamCached;
extern NSString *const ExamPassword;
extern NSString *const ExamScore;
extern NSString *const ExamOpened;

extern NSString *const ExamQuestions;
extern NSString *const ExamQuestionId;
extern NSString *const ExamQuestionTitle;
extern NSString *const ExamQuestionLevel;
extern NSString *const ExamQuestionType;
extern NSString *const ExamQuestionAnswer;
extern NSString *const ExamQuestionAnswerBySeq;
extern NSString *const ExamQuestionNote;
extern NSString *const ExamQuestionAnswered;
extern NSString *const ExamQuestionCorrect;

extern NSString *const ExamQuestionOptions;
extern NSString *const ExamQuestionOptionId;
extern NSString *const ExamQuestionOptionTitle;
extern NSString *const ExamQuestionOptionSeq;
extern NSString *const ExamQuestionOptionSelected;
