//
//  Constants.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#include "Constants.h"

NSString *const ServiceNumber = @"400 882 2731";
NSString *const FakeAccount = @"A1234567";
NSString *const FakeId = @"1";
NSString *const FakeName = @"张三";

NSString *const CacheFolder = @"JsonTemplate";
NSString *const QuestionnaireFolder = @"Questionnaire";
NSString *const ExamFolder = @"Exam";

NSString *const CommonFileName = @"filename";

// Questionnaires
NSString *const Questionnaires = @"exams";
NSString *const QuestionnaireId = @"exam_id";
NSString *const QuestionnaireTitle = @"exam_name";
NSString *const QuestionnaireDesc = @"description";
NSString *const QuestionnaireBeginDate = @"begin";
NSString *const QuestionnaireEndDate = @"end";
NSString *const QuestionnaireQuestionnaireStart = @"questionnaire_start";;
NSString *const QuestionnaireQuestionnaireEnd = @"questionnaire_end";;
NSString *const QuestionnaireStatus = @"status";
NSString *const QuestionnaireCached = @"exist_in_local";
NSString *const QuestionnaireType = @"type";
NSString *const QuestionnaireLocation = @"location";
NSString *const QuestionnaireAnsType = @"ans_type";
NSString *const QuestionnaireSubmitted = @"submit";
NSString *const QuestionnaireOpened = @"opened";
NSString *const QuestionnaireUserId = @"user_id";
NSString *const QuestionnaireFinished = @"finished";

NSString *const QuestionnaireQuestions = @"questions";
NSString *const QuestionnaireQuestionId = @"id";
NSString *const QuestionnaireQuestionTitle = @"description";
NSString *const QuestionnaireQuestionType = @"type";
NSString *const QuestionnaireQuestionNote = @"memo";
NSString *const QuestionnaireQuestionFilledAnswer = @"filled_answer";
NSString *const QuestionnaireQuestionAnswered = @"answered";

NSString *const QuestionnaireQuestionResult = @"result";
NSString *const QuestionnaireQuestionResultId = @"problem_id";
NSString *const QuestionnaireQuestionResultType = @"type";
NSString *const QuestionnaireQuestionResultSelected = @"selected_answer";
NSString *const QuestionnaireQuestionResultFilled = @"filled_answer";

NSString *const QuestionnaireQuestionOptions = @"selectors";
NSString *const QuestionnaireQuestionOptionId = @"id";
NSString *const QuestionnaireQuestionOptionTitle = @"content";
NSString *const QuestionnaireQuestionOptionSeq = @"seq";
NSString *const QuestionnaireQuestionOptionSelected = @"selected";

// Exams
NSString *const Exams = @"exams";
NSString *const ExamId = @"exam_id";
NSString *const ExamTitle = @"exam_name";
NSString *const ExamDesc = @"description";
NSString *const ExamBeginDate = @"begin";
NSString *const ExamEndDate = @"end";
NSString *const ExamDuration = @"duration";
NSString *const ExamExamStart = @"exam_start";
NSString *const ExamExamEnd = @"exam_end";
NSString *const ExamStatus = @"status";
NSString *const ExamSubmitted = @"submit";
NSString *const ExamType = @"type";
NSString *const ExamLocation = @"location";
NSString *const ExamAnsType = @"ans_type";
NSString *const ExamCached = @"exist_in_local";
NSString *const ExamPassword = @"password";
NSString *const ExamScore = @"score";
NSString *const ExamOpened = @"opened";
NSString *const ExamUserId = @"user_id";
NSString *const ExamAllowTimes = @"allow_times";
NSString *const ExamSubmitTimes = @"submit_times";
NSString *const ExamQualify = @"qualify_percent";

NSString *const ExamQuestions = @"questions";
NSString *const ExamQuestionId = @"id";
NSString *const ExamQuestionTitle = @"description";
NSString *const ExamQuestionLevel = @"level";
NSString *const ExamQuestionType = @"type";
NSString *const ExamQuestionScore = @"score";
NSString *const ExamQuestionAnswer = @"answer";
NSString *const ExamQuestionAnswerBySeq = @"answer_by_seq";
NSString *const ExamQuestionNote = @"memo";
NSString *const ExamQuestionAnswered = @"answered";
NSString *const ExamQuestionCorrect = @"correct";

NSString *const ExamQuestionResult = @"result";
NSString *const ExamQuestionResultId = @"problem_id";
NSString *const ExamQuestionResultType = @"type";
NSString *const ExamQuestionResultSelected = @"selected_answer";
NSString *const ExamQuestionResultCorrect = @"result";
NSString *const ExamQuestionResultScore = @"score";

NSString *const ExamQuestionOptions = @"selectors";
NSString *const ExamQuestionOptionId = @"id";
NSString *const ExamQuestionOptionTitle = @"content";
NSString *const ExamQuestionOptionSeq = @"seq";
NSString *const ExamQuestionOptionSelected = @"selected";
