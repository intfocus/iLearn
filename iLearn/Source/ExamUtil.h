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
+ (NSArray*)loadExamsFromCache;
+ (NSString*)jsonStringOfContent:(NSDictionary*)content;
+ (NSString*)titleFromContent:(NSDictionary*)content;
+ (NSString*)descFromContent:(NSDictionary*)content;
+ (NSInteger)endDateFromContent:(NSDictionary*)content;
+ (NSInteger)startDateFromContent:(NSDictionary*)content;

+ (NSString*)examSourceFolderPath;
+ (NSString*)examFolderPathInDocument;
+ (NSString*)examDBPathOfFile:(NSString*)fileName;

+ (void)parseContentIntoDB:(NSDictionary*)content;
+ (NSDictionary*)examContentFromDBFile:(NSString*)dbPath;
+ (void)setOptionSelected:(BOOL)selected withSubjectId:(NSString*)subjectId optionId:(NSString*)optionId andDBPath:(NSString*)dbPath;

+ (void)setExamSubmittedwithDBPath:(NSString*)dbPath;
+ (NSInteger)examScoreOfDBPath:(NSString*)dbPath;
+ (void)generateExamUploadJsonOfDBPath:(NSString*)dbPath;

+ (void)saveScannedResultIntoDB:(NSString*)result;
+ (void)setScannedResultSubmitted:(NSString*)result;
+ (NSArray*)unsubmittedScannedResults;

+ (NSArray*)resultFiles;

@end
