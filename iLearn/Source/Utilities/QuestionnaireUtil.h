//
//  QuestionnaireUtil.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionnaireUtil : NSObject

+ (NSArray*)loadQuestionaires;
+ (NSString*)jsonStringOfContent:(NSDictionary*)content;

+ (NSString*)titleFromContent:(NSDictionary*)content;
+ (NSString*)descFromContent:(NSDictionary*)content;
+ (long long)startDateFromContent:(NSDictionary*)content;
+ (long long)endDateFromContent:(NSDictionary*)content;

+ (NSString*)questionnaireFolderPathInDocument;
+ (NSString*)questionnaireDBPathOfFile:(NSString*)fileName;
+ (void)cleanQuestionnaireFolder;

+ (void)parseContentIntoDB:(NSDictionary*)content;
+ (NSDictionary*)contentFromDBFile:(NSString*)dbPath;
+ (void)setOptionSelected:(BOOL)selected withQuestionId:(NSString*)questionId optionId:(NSString*)optionId andDBPath:(NSString*)dbPath;
+ (void)saveFilledAnswer:(NSString*)filledAnswer withQuestionId:(NSString*)questionId andDBPath:(NSString*)dbPath;

+ (void)setQuestionnaireSubmittedwithDBPath:(NSString*)dbPath;
+ (void)setQuestionnaireSubmitDateWithDBPath:(NSString*)dbPath;
+ (void)generateUploadJsonFromDBPath:(NSString*)dbPath;

+ (NSArray*)resultFiles;

@end
