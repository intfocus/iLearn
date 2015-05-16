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
};

extern NSString *const FakeAccount;

extern NSString *const CacheFolder;
extern NSString *const QuestionnaireFolder;

extern NSString *const QuestionnaireTitle;
extern NSString *const QuestionnaireDesc;
extern NSString *const QuestionnaireExpirationDate;
extern NSString *const QuestionnaireStatus;
extern NSString *const QuestionnaireQuestions;
extern NSString *const QuestionnaireQuestionTitle;
extern NSString *const QuestionnaireQuestionAnswers;
extern NSString *const QuestionnaireQuestionAnswerTitle;
