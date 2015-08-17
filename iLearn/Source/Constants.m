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
NSString *const Questionnaires = @"data";
NSString *const QuestionnaireId = @"Id";
NSString *const QuestionnaireTitle = @"Name";
NSString *const QuestionnaireDesc = @"Desc";
NSString *const QuestionnaireBeginDate = @"StartTime";
NSString *const QuestionnaireEndDate = @"EndTime";
NSString *const QuestionnaireQuestionnaireStart = @"questionnaire_start";
NSString *const QuestionnaireQuestionnaireEnd = @"questionnaire_end";
NSString *const QuestionnaireStatus = @"status";
NSString *const QuestionnaireCached = @"exist_in_local";
NSString *const QuestionnaireType = @"type";
NSString *const QuestionnaireSubmitted = @"submit";
NSString *const QuestionnaireOpened = @"opened";
NSString *const QuestionnaireFinished = @"finished";

NSString *const QuestionnaireQuestions = @"data";
NSString *const QuestionnaireQuestionId = @"ProblemId";
NSString *const QuestionnaireQuestionTitle = @"ProblemDesc";
NSString *const QuestionnaireQuestionType = @"ProblemType";
NSString *const QuestionnaireQuestionFilledAnswer = @"ProblemFilled";
NSString *const QuestionnaireQuestionSelectedAnswer = @"ProblemSelected";
NSString *const QuestionnaireQuestionAnswered = @"answered";
NSString *const QuestionnaireQuestionGroup = @"GroupName";

NSString *const QuestionnaireResultUserId = @"UserId";
NSString *const QuestionnaireResultId = @"QuestionId";
NSString *const QuestionnaireResultSubmitDate = @"SubmitDate";

NSString *const QuestionnaireQuestionResult = @"Results";
NSString *const QuestionnaireQuestionResultId = @"ProblemId";
NSString *const QuestionnaireQuestionResultAnswer = @"SubmitAnswer";

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
