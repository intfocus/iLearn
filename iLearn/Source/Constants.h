//
//  Constants.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

#define ILLightGray     [UIColor colorWithRed:188.0 / 255.0 green:188.0 / 255.0 blue:188.0 / 255.0 alpha:1.0f]  // #bcbcbc
#define ILGray          [UIColor colorWithRed:106.0 / 255.0 green:106.0 / 255.0 blue:106.0 / 255.0 alpha:1.0f]  // #6a6a6a
#define ILDarkGray      [UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:1.0f]     // #333333
#define ILGreen         [UIColor colorWithRed:67.0 / 255.0 green:187.0 / 255.0 blue:184.0 / 255.0 alpha:1.0f]   // #43bbb8
#define ILRed           [UIColor colorWithRed:213.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0f]  // #d56464
#define ILDarkRed       [UIColor colorWithRed:206.0 / 255.0 green:64.0 / 255.0 blue:64.0 / 255.0 alpha:1.0f]    // #ce4040
#define ILLightGreen    [UIColor colorWithRed:19 / 255.0 green:187 / 255.0 blue:177 / 255.0 alpha:1.0f]         // #ce4040

typedef NS_ENUM(NSUInteger, ListViewType) {
    ListViewTypeExam,
    ListViewTypeQuestionnaire,
    ListViewTypeRegistration,
    ListViewTypeLecture,
    ListViewTypeNotification
};

typedef NS_ENUM(NSUInteger, ExamTypes) {
    ExamTypesPractice = 0,
    ExamTypesFormal,
};

typedef NS_ENUM(NSUInteger, ExamLocations) {
    ExamLocationsOnline = 0,
    ExamLocationsOnsite,
};

typedef NS_ENUM(NSUInteger, ExamSubjectType) {
    ExamSubjectTypeTrueFalse = 1,
    ExamSubjectTypeSingle,
    ExamSubjectTypeMultiple,
};

typedef NS_ENUM(NSUInteger, QuestionnaireQuestionTypes) {
    QuestionnaireQuestionsTypeTrueFalse = 1,
    QuestionnaireQuestionsTypeSingle,
    QuestionnaireQuestionsTypeMultiple,
    QuestionnaireQuestionsTypeFill,
};

extern NSString *const ServiceNumber;
extern NSString *const FakeAccount;
extern NSString *const FakeId;
extern NSString *const FakeName;

extern NSString *const CacheFolder;
extern NSString *const QuestionnaireFolder;
extern NSString *const ExamFolder;

extern NSString *const CommonFileName;

// Questionnaires
extern NSString *const Questionnaires;
extern NSString *const QuestionnaireId;
extern NSString *const QuestionnaireTitle;
extern NSString *const QuestionnaireDesc;
extern NSString *const QuestionnaireBeginDate;
extern NSString *const QuestionnaireEndDate;
extern NSString *const QuestionnaireQuestionnaireStart;
extern NSString *const QuestionnaireQuestionnaireEnd;
extern NSString *const QuestionnaireStatus;
extern NSString *const QuestionnaireCached;
extern NSString *const QuestionnaireType;
extern NSString *const QuestionnaireLocation;
extern NSString *const QuestionnaireAnsType;
extern NSString *const QuestionnaireSubmitted;
extern NSString *const QuestionnaireOpened;
extern NSString *const QuestionnaireUserId;
extern NSString *const QuestionnaireFinished;

extern NSString *const QuestionnaireQuestions;
extern NSString *const QuestionnaireQuestionId;
extern NSString *const QuestionnaireQuestionTitle;
extern NSString *const QuestionnaireQuestionType;
extern NSString *const QuestionnaireQuestionNote;
extern NSString *const QuestionnaireQuestionFilledAnswer;
extern NSString *const QuestionnaireQuestionAnswered;

extern NSString *const QuestionnaireQuestionResult;
extern NSString *const QuestionnaireQuestionResultId;
extern NSString *const QuestionnaireQuestionResultType;
extern NSString *const QuestionnaireQuestionResultSelected;
extern NSString *const QuestionnaireQuestionResultFilled;

extern NSString *const QuestionnaireQuestionOptions;
extern NSString *const QuestionnaireQuestionOptionId;
extern NSString *const QuestionnaireQuestionOptionTitle;
extern NSString *const QuestionnaireQuestionOptionSeq;
extern NSString *const QuestionnaireQuestionOptionSelected;

// Exams
extern NSString *const Exams;
extern NSString *const ExamId;
extern NSString *const ExamTitle;
extern NSString *const ExamDesc;
extern NSString *const ExamBeginDate;
extern NSString *const ExamEndDate;
extern NSString *const ExamDuration;
extern NSString *const ExamExamStart;
extern NSString *const ExamExamEnd;
extern NSString *const ExamStatus;
extern NSString *const ExamSubmitted;
extern NSString *const ExamType;
extern NSString *const ExamLocation;
extern NSString *const ExamAnsType;
extern NSString *const ExamCached;
extern NSString *const ExamPassword;
extern NSString *const ExamScore;
extern NSString *const ExamOpened;
extern NSString *const ExamUserId;
extern NSString *const ExamAllowTimes;
extern NSString *const ExamSubmitTimes;
extern NSString *const ExamQualify;

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

extern NSString *const ExamQuestionResult;
extern NSString *const ExamQuestionResultId;
extern NSString *const ExamQuestionResultType;
extern NSString *const ExamQuestionResultSelected;
extern NSString *const ExamQuestionResultCorrect;
extern NSString *const ExamQuestionResultScore;

extern NSString *const ExamQuestionOptions;
extern NSString *const ExamQuestionOptionId;
extern NSString *const ExamQuestionOptionTitle;
extern NSString *const ExamQuestionOptionSeq;
extern NSString *const ExamQuestionOptionSelected;
