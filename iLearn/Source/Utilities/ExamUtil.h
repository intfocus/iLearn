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
+ (long long)endDateFromContent:(NSDictionary*)content;
+ (long long)startDateFromContent:(NSDictionary*)content;

+ (NSString*)examSourceFolderPath;
+ (NSString*)examFolderPathInDocument;
+ (void)cleanExamFolder;

+ (void)parseContentIntoDB:(NSDictionary*)content;
+ (void)parseContentIntoDB:(NSDictionary*)content Path:(NSString *)dbPath;
+ (NSDictionary*)examContentFromDBFile:(NSString*)dbPath;
+ (void)setOptionSelected:(BOOL)selected withSubjectId:(NSString*)subjectId optionId:(NSString*)optionId andDBPath:(NSString*)dbPath;

+ (void)setExamSubmittedwithDBPath:(NSString*)dbPath;
+ (void)resetExamStatusOfDBPath:(NSString*)dbPath;
+ (NSInteger)examScoreOfDBPath:(NSString*)dbPath;
+ (void)updateExamScore:(NSInteger)score ofDBPath:(NSString*)dbPath;
+ (void)updateSubmitTimes:(NSInteger)submitTimes ofDBPath:(NSString*)dbPath;
+ (void)generateExamUploadJsonOfDBPath:(NSString*)dbPath;

+ (void)saveScannedResultIntoDB:(NSString*)result;
+ (void)setScannedResultSubmitted:(NSString*)result;
+ (NSArray*)unsubmittedScannedResults;

+ (NSArray*)resultFiles;

+ (NSString *)examPath:(NSString *)examID;
+ (BOOL)isExamDownloaded:(NSString *)examID;
+ (NSString *)examDBPath:(NSString *)examID;
+ (NSString *)examBasePath:(NSString *)examID Ext:(NSString *)extName;

@end
