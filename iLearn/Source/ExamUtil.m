//
//  ExamUtil.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/28.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ExamUtil.h"
#import "Constants.h"
#import "LicenseUtil.h"
#import "FMDB.h"

static const BOOL inDeveloping = NO;

@implementation ExamUtil

+ (NSArray*)loadExams
{
    NSMutableArray *exams = [NSMutableArray array];
    NSMutableArray *examIds = [NSMutableArray array];

    // Add Cached Exams first
    NSArray *cachedExams = [self loadExamsFromCache];

    [exams addObjectsFromArray:cachedExams];

    for (NSDictionary *exam in cachedExams) {
        [examIds addObject:exam[ExamId]];
    }

    // Add Exams from Exam.json, if exam's ExamId already added, use the cached version (may be content of DB or JSON)
    NSString *jsonPath = [NSString stringWithFormat:@"%@/%@", [self examSourceFolderPath], @"Exam.json"];

    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jsonPath];

    if (fileExist) {

        NSData *contentData = [NSData dataWithContentsOfFile:jsonPath];
        NSError *jsonError;
        NSDictionary *content = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:&jsonError];

        for (NSDictionary *exam in content[Exams]) {

            if (![examIds containsObject:exam[ExamId]]) {
                [exams addObject:exam];
            }
        }
    }

    // Check for exam is cached or not
    for (NSMutableDictionary *exam in exams) {
        NSString *examId = exam[ExamId];

        NSString *jsonPath = [NSString stringWithFormat:@"%@/%@.json", [self examSourceFolderPath], examId];

        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jsonPath];

        if (fileExist) {
            [exam setObject:@1 forKey:ExamCached];
        }
        else {
            [exam setObject:@0 forKey:ExamCached];
        }
    }

//    NSLog(@"exams: %@", [self jsonStringOfContent:exams]);

    return exams;
}

+ (NSArray*)loadExamsFromCache
{
    NSString *path = [self examSourceFolderPath];
    NSError *error;

    NSFileManager *fileMgr = [NSFileManager defaultManager];

    NSArray *files = [fileMgr contentsOfDirectoryAtPath:path error:&error];

    if (!error) {
        NSMutableArray *contents = [NSMutableArray array];

        for (NSString *file in files) {

            NSString *fileExtension = [file pathExtension];
            if (![fileExtension isEqualToString:@"json"]) {
                continue;
            }
            else if ([file isEqualToString:@"Exam.json"]) {
                continue;
            }

            NSString *examName = [self fileName:file];
            NSString *dbPath = [self examDBPathOfFile:examName];

            // Use the info from DB
            if ([fileMgr fileExistsAtPath:dbPath]) {
                NSDictionary *examInfo = [self examInfoFromDBFile:dbPath];
                [contents addObject:examInfo];
                continue;
            }

            NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, file];
            NSData *contentData = [NSData dataWithContentsOfFile:filePath];
            NSError *jsonError;

            NSMutableDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:&jsonError];

            [jsonDic setObject:[self fileName:file] forKey:CommonFileName];

            if (!jsonError) {
                [contents addObject:jsonDic];
            }
        }
        return contents;
    }
    else {
        return nil;
    }
}

+ (NSString*)jsonStringOfContent:(NSDictionary*)content
{
    NSString *jsonString;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];

    if (!error) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    else {
        NSLog(@"Parse content of jsonDic failed");
    }

    return jsonString;
}

+ (NSString*)fileName:(NSString*)fullName
{
    return [[fullName lastPathComponent] stringByDeletingPathExtension];
}

+ (NSString*)titleFromContent:(NSDictionary*)content
{
    return content[ExamTitle];
}

+ (NSString*)descFromContent:(NSDictionary*)content
{
    NSNumber *start = content[ExamBeginDate];
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:[start longLongValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm"];
    NSString *beginTimeString = [formatter stringFromDate:beginDate];
    NSString *beginString = [NSString stringWithFormat:NSLocalizedString(@"LIST_BEGIN_DATE_TEMPLATE", nil), beginTimeString];
    NSString *descString = [NSString stringWithFormat:@"%@\n%@", beginString, content[ExamDesc]];

    return descString;
}

+ (long long)endDateFromContent:(NSDictionary*)content
{
    return [content[ExamEndDate] longLongValue];
}

+ (long long)startDateFromContent:(NSDictionary*)content
{
    return [content[ExamBeginDate] longLongValue];
}

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString*)examFolderPathInDocument
{
    NSString *docPath = [self applicationDocumentsDirectory];
    NSString *examPath = [NSString stringWithFormat:@"%@/%@", docPath, ExamFolder];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if (![fileMgr fileExistsAtPath:examPath isDirectory:&isFolder]) {
        NSLog(@"Folder not exist, create it!");
        NSError *createFolderError;

        BOOL createFolderSucess = [fileMgr createDirectoryAtPath:examPath withIntermediateDirectories:YES attributes:nil error:&createFolderError];

        if (!createFolderSucess) {
            NSLog(@"Create folder %@ failed with error: %@", examPath, createFolderError);
        }
    }
    
    return examPath;
}

+ (NSString*)examFolderPathInBundle
{
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@/", resPath, CacheFolder, ExamFolder];

    return path;
}

+ (NSString*)examSourceFolderPath
{
    if (inDeveloping) {
        return [self examFolderPathInBundle];
    }
    else {
        return [self examFolderPathInDocument];
    }
}

+ (NSString*)examDBPathOfFile:(NSString*)fileName
{
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@.db", [self examFolderPathInDocument], fileName];
    return dbPath;
}

+ (void)parseContentIntoDB:(NSDictionary*)content
{
    NSString *dbPath = [self examDBPathOfFile:content[CommonFileName]];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if (![fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [self parseInfoOfContent:content intoDB:db];
            [self parseSubjectsOfContent:content intoDB:db];

            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
        NSLog(@"DB file already exist: %@", dbPath);
    }
}

+ (void)parseInfoOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (exam_id INTEGER PRIMARY KEY, exam_name TEXT, submit INTEGER, status INTEGER, type INTEGER, location INTEGER, begin INTEGER, end INTEGER, duration INTEGER, exam_start INTEGER, exam_end INTEGER, ans_type INTEGER, description TEXT, score INTEGER DEFAULT -1, password TEXT)"];

    long long duration = [content[ExamDuration] longLongValue];

    NSDate *now = [NSDate date];
    NSDate *deadline = [now dateByAddingTimeInterval:duration];

    long long nowInteger = [now timeIntervalSince1970];
    long long deadlineInteger = [deadline timeIntervalSince1970];

    [db executeUpdate:@"INSERT INTO info (exam_id, exam_name, submit, status, type, location, begin, end, duration, exam_start, exam_end, ans_type, description, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", content[ExamId], content[ExamTitle], @0, content[ExamStatus], content[ExamType], content[ExamLocation], content[ExamBeginDate], content[ExamEndDate], content[ExamDuration], @(nowInteger), @(deadlineInteger), content[ExamAnsType], content[ExamDesc], content[ExamPassword]];
}

+ (void)parseSubjectsOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS subject (id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER, desc TEXT, level INTEGER, type INTEGER, score FLOAT, memo TEXT, answer TEXT, selected_answer TEXT)"];

    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS option (id INTEGER PRIMARY KEY AUTOINCREMENT, option_id INTEGER, subject_id INTEGER, seq INTEGER, desc TEXT, selected INTEGER DEFAULT 0)"];

    NSMutableArray *subjects = [content[ExamQuestions] mutableCopy];
    NSInteger subjectCount = [subjects count];

    [db beginTransaction];

    while ([subjects count]) {

        int index = arc4random_uniform([subjects count]);
        NSDictionary *subject = subjects[index];

        [self parseSubjectContent:subject count:subjectCount intoDB:db];
        [subjects removeObject:subject];
    }

    [db commit];
}

+ (void)parseSubjectContent:(NSDictionary*)subjectContent count:(NSInteger)count intoDB:(FMDatabase*)db
{
    NSNumber *subjectId = subjectContent[ExamQuestionId];
    NSNumber *scorePerSubject = @(100.0/count);

    NSArray *answers = subjectContent[ExamQuestionAnswer];
    NSString *answer = [answers componentsJoinedByString:@"+"];

    [db executeUpdate:@"INSERT INTO subject (subject_id, desc, level, type, score, memo, answer) VALUES (?, ?, ?, ?, ?, ?, ?)", subjectId, subjectContent[ExamQuestionTitle], subjectContent[ExamQuestionLevel], subjectContent[ExamQuestionType], scorePerSubject, subjectContent[ExamQuestionNote], answer];


    NSMutableArray *options = [subjectContent[ExamQuestionOptions] mutableCopy];
    int seq = 0;

    while ([options count]) {

        int index = arc4random_uniform([options count]);
        NSDictionary *option = options[index];

        [db executeUpdate:@"INSERT INTO option (option_id, subject_id, seq, desc) VALUES (?, ?, ?, ?)", option[ExamQuestionOptionId], subjectId, @(seq++), option[ExamQuestionOptionTitle]];

        [options removeObject:option];
    }
}

+ (NSDictionary*)examContentFromDBFile:(NSString*)dbPath
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [content addEntriesFromDictionary:[self examInfoFromDB:db]];
            content[ExamQuestions] = [self examSubjectsFromDB:db];
            content[CommonFileName] = [[dbPath lastPathComponent] stringByDeletingPathExtension];

            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
//        NSLog(@"No DB file at the path: %@", dbPath);
    }

    return content;
}

+ (NSDictionary*)examInfoFromDBFile:(NSString*)dbPath
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [content addEntriesFromDictionary:[self examInfoFromDB:db]];
            content[CommonFileName] = [[dbPath lastPathComponent] stringByDeletingPathExtension];

            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
//        NSLog(@"No DB file at the path: %@", dbPath);
    }
    
    return content;
}

+ (NSDictionary*)examInfoFromDB:(FMDatabase*)db
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];

    FMResultSet *result = [db executeQuery:@"SELECT * FROM info LIMIT 1"];

    while ([result next]) {
        content[ExamId] = @([result intForColumn:@"exam_id"]);
        content[ExamTitle] = [result stringForColumn:@"exam_name"];
        content[ExamStatus] = @([result intForColumn:@"status"]);
        content[ExamType] = @([result intForColumn:@"type"]);
        content[ExamLocation] = @([result intForColumn:@"location"]);
        content[ExamBeginDate] = @([result longLongIntForColumn:@"begin"]);
        content[ExamEndDate] = @([result longLongIntForColumn:@"end"]);
        content[ExamDuration] = @([result longLongIntForColumn:@"duration"]);
        content[ExamExamStart] = @([result longLongIntForColumn:@"exam_start"]);
        content[ExamExamEnd] = @([result longLongIntForColumn:@"exam_end"]);
        content[ExamAnsType] = @([result intForColumn:@"ans_type"]);
        content[ExamDesc] = [result stringForColumn:@"description"];
        content[ExamPassword] = [result stringForColumn:@"password"];
        content[ExamScore] = @([result intForColumn:@"score"]);
        content[ExamSubmitted] = @([result intForColumn:@"submit"]);
        content[ExamOpened] = @(1);
    }

    return content;
}

+ (NSMutableArray*)examSubjectsFromDB:(FMDatabase*)db
{
    NSMutableArray *questions = [NSMutableArray array];

    FMResultSet *result = [db executeQuery:@"SELECT * FROM subject"];

    while ([result next]) {

        NSMutableDictionary *content = [NSMutableDictionary dictionary];

        NSNumber *subjectId = @([result intForColumn:@"subject_id"]);

        content[ExamQuestionId] = subjectId;
        content[ExamQuestionTitle] = [result stringForColumn:@"desc"];
        content[ExamQuestionLevel] = @([result intForColumn:@"level"]);
        content[ExamQuestionType] = @([result intForColumn:@"type"]);
        content[ExamQuestionNote] = [result stringForColumn:@"memo"];

        NSString *selecteAnswer = [result stringForColumn:@"selected_answer"];

        if (selecteAnswer != nil) {
            content[ExamQuestionCorrect] = [selecteAnswer isEqualToString:[result stringForColumn:@"answer"]]? @1: @0;
        }

        NSArray *answers = [[result stringForColumn:@"answer"] componentsSeparatedByString:@"+"];
        NSMutableArray *answersBySeq = [NSMutableArray array];
        content[ExamQuestionAnswer] = answers;

        NSMutableArray *options = [NSMutableArray array];

        FMResultSet *optionResult = [db executeQuery:@"SELECT * FROM option WHERE subject_id = ?", subjectId];

        NSInteger answered = 0;

        while ([optionResult next]) {

            NSMutableDictionary *option = [NSMutableDictionary dictionary];

            NSString *optionId = [optionResult stringForColumn:@"option_id"];
            option[ExamQuestionOptionId] = optionId;
            NSNumber *optionSeq = @([optionResult intForColumn:@"seq"]);
            option[ExamQuestionOptionSeq] = optionSeq;
            option[ExamQuestionOptionTitle] = [optionResult stringForColumn:@"desc"];
            option[ExamQuestionOptionSelected] = @([optionResult intForColumn:@"selected"]);

            if ([option[ExamQuestionOptionSelected] isEqualToNumber:@(1)]) {
                answered = 1;
            }

            if ([answers containsObject:optionId]) {
                [answersBySeq addObject:optionSeq];
            }

            [options addObject:option];
        }

        content[ExamQuestionOptions] = options;
        content[ExamQuestionAnswerBySeq] = answersBySeq;
        content[ExamQuestionAnswered] = @(answered);

        [questions addObject:content];
    }

    return questions;
}

+ (void)setOptionSelected:(BOOL)selected withSubjectId:(NSString*)subjectId optionId:(NSString*)optionId andDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            BOOL updateSuccess = [db executeUpdate:@"UPDATE option SET selected=? WHERE subject_id=? AND option_id=?", @(selected), subjectId, optionId];

            if (!updateSuccess) {
                NSLog(@"UPDATE FAILED! optionId: %@, subjectId: %@, selected: %d", optionId, subjectId, selected);
            }

            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
        NSLog(@"No DB file at the path: %@", dbPath);
    }
}

+ (void)setExamSubmittedwithDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [db executeUpdate:@"UPDATE info SET submit=1"];

            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
        NSLog(@"No DB file at the path: %@", dbPath);
    }
}

+ (NSInteger)examScoreOfDBPath:(NSString*)dbPath
{
    NSInteger score = -1;

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            score = [db intForQuery:@"SELECT score FROM info LIMIT 1"];

            if (score == -1) {
                score = [self calculateExamScoreOfDB:db];
            }

            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
//        NSLog(@"No DB file at the path: %@", dbPath);
    }
    return score;
}

+ (NSInteger)calculateExamScoreOfDB:(FMDatabase*)db
{
    [self updateSelectedAnswersOfSubjectsInDB:db];

    NSInteger nowInteger = [[NSDate date] timeIntervalSince1970];

    NSInteger totalSubjectCount = [db intForQuery:@"SELECT COUNT(*) FROM subject"];
    NSInteger correctCount = [db intForQuery:@"SELECT COUNT(*) FROM subject WHERE answer=selected_answer"];

    NSInteger score = (float)correctCount/(float)totalSubjectCount * 100.0 + 0.5;

    [db executeUpdate:@"UPDATE info SET score=?, end=?", @(score), @(nowInteger)];

    return score;
}

+ (void)updateSelectedAnswersOfSubjectsInDB:(FMDatabase*)db
{
    FMResultSet *subjects = [db executeQuery:@"SELECT * FROM subject"];

    [db beginTransaction];

    while ([subjects next]) {

        NSString *subjectId = [subjects stringForColumn:@"subject_id"];

        FMResultSet *options = [db executeQuery:@"SELECT * FROM option WHERE subject_id=? AND selected=1", subjectId];
        NSMutableArray *selectedAnswers = [NSMutableArray array];

        while ([options next]) {
            NSString *optionId = [options stringForColumn:@"option_id"];
            [selectedAnswers addObject:optionId];
        }

        [selectedAnswers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:0];
        }];

        NSString *selectedAnswerString = [selectedAnswers componentsJoinedByString:@"+"];

        [db executeUpdate:@"UPDATE subject SET selected_answer=? WHERE subject_id=?", selectedAnswerString, subjectId];
    }

    [db commit];
}

+ (NSString*)scanResultDBPath
{
    NSString *dbPath = [NSString stringWithFormat:@"%@/scan.db", [self examFolderPathInDocument]];
    return dbPath;
}

+ (void)saveScannedResultIntoDB:(NSString*)result
{
    NSString *dbPath = [self scanResultDBPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

    if ([db open]) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS result(result TEXT PRIMARY KEY, submit INTEGER DEFAULT 0)"];

        if (![self scanResultSaved:result inDB:db]) {
            [db executeUpdate:@"INSERT INTO result (result) VALUES (?)", result];
        }
        else {
            NSLog(@"Scanned result: %@ has been saved", result);
        }

        [db close];
    }
}

+ (BOOL)scanResultSaved:(NSString*)result inDB:(FMDatabase*)db
{
    NSString *savedResult = [db stringForQuery:@"SELECT result FROM result WHERE result=?", result];
    BOOL saved = [savedResult length]? YES: NO;
    return saved;
}

+ (void)setScannedResultSubmitted:(NSString*)result
{
    NSString *dbPath = [self scanResultDBPath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

    if ([db open]) {
        [db executeUpdate:@"UPDATE result SET submit=1 WHERE result=?", result];
        [db close];
    }
}

+ (NSArray*)unsubmittedScannedResults
{
    NSMutableArray *unsubmittedResults = [NSMutableArray array];

    NSString *dbPath = [self scanResultDBPath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {
            FMResultSet *unsubmitted = [db executeQuery:@"SELECT result FROM result WHERE submit = 0"];

            while ([unsubmitted next]) {
                [unsubmittedResults addObject:[unsubmitted stringForColumn:@"result"]];
            }
            
            [db close];
        }
    }

    return unsubmittedResults;
}

+ (void)generateExamUploadJsonOfDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {

        NSString *outputPath;
        NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            NSNumber *examId = @([db intForQuery:@"SELECT exam_id FROM info"]);
            NSNumber *userId = @([[LicenseUtil userId] integerValue]);
            NSNumber *score = @([db intForQuery:@"SELECT score FROM info"]);

            outputPath = [NSString stringWithFormat:@"%@/%@.result", [self examFolderPathInDocument], examId];

            jsonDic[ExamId] = examId;
            jsonDic[ExamUserId] = userId;
            jsonDic[ExamScore] = score;

            NSMutableArray *resultArray = [NSMutableArray array];

            FMResultSet *subjects = [db executeQuery:@"SELECT * FROM subject"];

            while ([subjects next]) {

                NSMutableDictionary *subjectDic = [NSMutableDictionary dictionary];

                NSNumber *subjectId = @([subjects intForColumn:@"subject_id"]);
                NSNumber *subjectType = @([subjects intForColumn:@"type"]);
                NSString *answer = [subjects stringForColumn:@"answer"];
                NSString *selectedAnswer = [subjects stringForColumn:@"selected_answer"];
                NSNumber *subjectResult = [answer isEqualToString:selectedAnswer]? @1: @0;
                NSArray *selectedAnsArray = [selectedAnswer componentsSeparatedByString:@"+"];
                NSNumber *score = @([subjects doubleForColumn:@"score"]);

                subjectDic[ExamQuestionResultId] = subjectId;
                subjectDic[ExamQuestionResultType] = subjectType;
                subjectDic[ExamQuestionResultSelected] = selectedAnsArray;
                subjectDic[ExamQuestionResultCorrect] = subjectResult;
                subjectDic[ExamQuestionResultScore] = score;

                [resultArray addObject:subjectDic];
            }

            jsonDic[ExamQuestionResult] = resultArray;

            [db close];
        }

        NSLog(@"jsonDic: %@", jsonDic);

        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:0 error:&jsonError];

        if (!jsonError) {

            NSError *error;
            [fileMgr removeItemAtPath:outputPath error:&error];
            [jsonData writeToFile:outputPath atomically:YES];
        }
        else {
            NSLog(@"Error in serialize jsonDic, ERROR: %@", jsonError);
        }

    }
}

+ (NSArray*)resultFiles
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *examPath = [self examFolderPathInDocument];

    NSArray *files = [fileMgr contentsOfDirectoryAtPath:examPath error:nil];
    NSMutableArray *results = [NSMutableArray array];

    for (NSString *file in files) {
        NSString *extension = [file pathExtension];
        if ([extension isEqualToString:@"result"]) {
            NSString *path = [NSString stringWithFormat:@"%@/%@", examPath, file];
            [results addObject:path];
        }
    }

    return results;
}

+ (void)cleanExamFolder
{
    NSString *examPath = [self examFolderPathInDocument];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    [fileMgr removeItemAtPath:examPath error:&error];

    if (error) {
        NSLog(@"Delete exam folder FAILED with ERROR: %@", [error localizedDescription]);
    }
}

@end
