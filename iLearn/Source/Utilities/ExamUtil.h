//
//  ExamUtil.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/28.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExamUtil : NSObject

+ (NSArray*)loadExams;
+ (NSString*)jsonStringOfContent:(NSDictionary*)content;

+ (NSString*)titleFromContent:(NSDictionary*)content;
+ (NSString*)descFromContent:(NSDictionary*)content;
+ (long long)startDateFromContent:(NSDictionary*)content;
+ (long long)endDateFromContent:(NSDictionary*)content;

+ (NSString*)examFolderPathInDocument;
+ (NSString*)examDBPathOfFile:(NSString*)fileName;
+ (void)cleanExamFolder;

+ (void)parseContentIntoDB:(NSDictionary*)content;
+ (NSDictionary*)contentFromDBFile:(NSString*)dbPath;
+ (void)setOptionSelected:(BOOL)selected withQuestionId:(NSString*)questionId optionId:(NSString*)optionId andDBPath:(NSString*)dbPath;

+ (void)setExamSubmittedwithDBPath:(NSString*)dbPath;
+ (NSInteger)examScoreOfDBPath:(NSString*)dbPath;
+ (void)generateUploadJsonFromDBPath:(NSString*)dbPath;

+ (void)saveScannedResultIntoDB:(NSString*)result;
+ (void)setScannedResultSubmitted:(NSString*)result;
+ (NSArray*)unsubmittedScannedResults;

+ (NSArray*)resultFiles;

@end
