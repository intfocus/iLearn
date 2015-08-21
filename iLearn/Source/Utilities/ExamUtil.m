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
#import <FMDB.h>
#import "FileUtils.h"
#import "ExtendNSLogFunctionality.h"

static const BOOL inDeveloping = NO;

@implementation ExamUtil

+ (NSArray*)loadExams
{
    NSMutableArray *exams   = [NSMutableArray array];
    NSMutableArray *examIds = [NSMutableArray array];

    // Add Cached Exams first
    NSArray *cachedExams = [self loadExamsFromCache];

    [exams addObjectsFromArray:cachedExams];

    for (NSDictionary *exam in cachedExams) {
        if (exam[ExamId]) {
            [examIds addObject:exam[ExamId]];
        }
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
        
        if ([self isExamDownloaded:examId]) {
            [exam setObject:@1 forKey:ExamCached];
        }
        else {
            [exam setObject:@0 forKey:ExamCached];
        }
    }

//    NSLog(@"exams: %@", [self jsonStringOfContent:exams]);

    /**
     * add#sort jay@2015/07/11
     * 原因:
     *     未排序，会导致考试列表（内容不变）每次进入app[考试中心],显示顺序都不一致
     * 排序:
     *     以考试结束时间降序，再以考试标题升序
     */
    NSSortDescriptor *firstSort  = [[NSSortDescriptor alloc] initWithKey:ExamEndDate ascending:NO];
    NSSortDescriptor *secondSort = [[NSSortDescriptor alloc] initWithKey:ExamTitle ascending:YES];
    NSArray *sortExams = [exams sortedArrayUsingDescriptors:[NSArray arrayWithObjects:firstSort, secondSort,nil]];
    return sortExams;
}

+ (NSString *)examPath:(NSString *)examID {
    return [self examBasePath:examID Ext:@"json"];
}
+ (NSString *)examDBPath:(NSString *)examID {
    return [self examBasePath:examID Ext:@"db"];
}
+ (NSString *)examBasePath:(NSString *)examID Ext:(NSString *)extName {
    return [NSString stringWithFormat:@"%@/%@.%@", [self examSourceFolderPath], examID, extName];
}

+ (BOOL)isExamDownloaded:(NSString *)examID {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self examPath:examID]];
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
            NSString *dbPath = [self examDBPath:examName];

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
    // Exam start date
    NSNumber *start = content[ExamBeginDate];
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:[start longLongValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm"];
    NSString *beginTimeString = [formatter stringFromDate:beginDate];
    NSString *beginString = [NSString stringWithFormat:NSLocalizedString(@"LIST_BEGIN_DATE_TEMPLATE", nil), beginTimeString];

    // Exam duration
    //TODO: 确认服务器使用单位为分钟
    long long duration = [content[ExamDuration] longLongValue] * 60.0;

    if (duration < 0) {
        duration = 0;
    }

    long long minute = duration / 60;
    long long second = duration % 60;

    NSString *durationString = [NSString stringWithFormat:NSLocalizedString(@"LIST_DURATION_TEMPLATE", nil), minute, second];

    // Show exam duration for formal exam
    ExamTypes examType = [content[ExamType] integerValue];

    NSString *descString;

    if (examType == ExamTypesFormal) {
        descString = [NSString stringWithFormat:@"%@\n%@\n\n%@", beginString, durationString, content[ExamDesc]];
    }
    else {
        descString = [NSString stringWithFormat:@"%@\n\n%@", beginString, content[ExamDesc]];
    }

    return descString;
}

+ (long long)startDateFromContent:(NSDictionary*)content
{
    return [content[ExamBeginDate] longLongValue];
}

+ (long long)endDateFromContent:(NSDictionary*)content
{
    return [content[ExamEndDate] longLongValue];
}

+ (NSString*)examFolderPathInDocument
{
    //NSString *docPath = [self applicationDocumentsDirectory];
    //NSString *examPath = [NSString stringWithFormat:@"%@/%@", docPath, ExamFolder];
//    NSString *examPath = [self examSourceFolderPath];
//
//    NSFileManager *fileMgr = [NSFileManager defaultManager];
//    BOOL isFolder;
//
//    if (![fileMgr fileExistsAtPath:examPath isDirectory:&isFolder]) {
//        NSLog(@"Folder not exist, create it!");
//        NSError *createFolderError;
//
//        BOOL createFolderSucess = [fileMgr createDirectoryAtPath:examPath withIntermediateDirectories:YES attributes:nil error:&createFolderError];
//
//        if (!createFolderSucess) {
//            NSLog(@"Create folder %@ failed with error: %@", examPath, createFolderError);
//        }
//    }
//    
    return [FileUtils dirPath:ExamFolder];
}

+ (NSString*)examSourceFolderPath {
    return [FileUtils dirPath:ExamFolder];
//    if (inDeveloping) {
//        return [self examFolderPathInBundle];
//    }
//    else {
//        return [self examFolderPathInDocument];
//    }
}

+ (void)parseContentIntoDB:(NSDictionary*)content {
    NSString *dbPath = [self examDBPath:content[CommonFileName]];
    [self parseContentIntoDB:content Path:dbPath];
}

+ (void)parseContentIntoDB:(NSDictionary*)content Path:(NSString *)dbPath {

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
//        NSLog(@"DB file already exist: %@", dbPath);

        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            FMResultSet *result = [db executeQuery:@"SELECT * FROM info LIMIT 1"];

            if ([result next]) {

                NSDate *now = [NSDate date];

                if ([result columnIsNull:@"exam_start"]) {
                    long long nowInteger = [now timeIntervalSince1970];
                    [db executeUpdate:@"UPDATE info SET exam_start=?", @(nowInteger)];
                }

                if ([result columnIsNull:@"exam_end"]) {

                    //TODO: 确认服务器使用单位为分钟
                    long long duration = [result longLongIntForColumn:@"duration"] * 60.0;
                    NSDate *deadline = [now dateByAddingTimeInterval:duration];

                    long long deadlineInteger = [deadline timeIntervalSince1970];
                    [db executeUpdate:@"UPDATE info SET exam_end=?", @(deadlineInteger)];
                }
            }

            [db close];
        }
    }
}

+ (void)parseInfoOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (exam_id INTEGER PRIMARY KEY, exam_name TEXT, submit INTEGER, status INTEGER, type INTEGER, location INTEGER, begin INTEGER, end INTEGER, duration INTEGER, exam_start INTEGER, exam_end INTEGER, ans_type INTEGER, description TEXT, score INTEGER DEFAULT -1, password TEXT, allow_times INTEGER DEFAULT 1, submit_times INTEGER DEFAULT 0, qualify_percent INTEGER DEFAULT -1)"];

    //TODO: 确认服务器使用分钟
    long long duration = [content[ExamDuration] longLongValue] * 60.0;

    NSDate *now = [NSDate date];
    NSDate *deadline = [now dateByAddingTimeInterval:duration];

    long long nowInteger = [now timeIntervalSince1970];
    long long deadlineInteger = [deadline timeIntervalSince1970];

    [db executeUpdate:@"INSERT INTO info (exam_id, exam_name, submit, status, type, location, begin, end, duration, exam_start, exam_end, ans_type, description, password, allow_times, qualify_percent) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", content[ExamId], content[ExamTitle], @0, content[ExamStatus], content[ExamType], content[ExamLocation], content[ExamBeginDate], content[ExamEndDate], content[ExamDuration], @(nowInteger), @(deadlineInteger), content[ExamAnsType], content[ExamDesc], content[ExamPassword], content[ExamAllowTimes], content[ExamQualify]];
}

+ (void)parseSubjectsOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS subject (id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER, desc TEXT, level INTEGER, type INTEGER, score FLOAT, memo TEXT default '', answer TEXT, selected_answer TEXT)"];

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
//    NSNumber *scorePerSubject = @(100.0/count);

    NSArray *answers = subjectContent[ExamQuestionAnswer];
    NSString *answer = [answers componentsJoinedByString:@"+"];

    /**
     *  bug#fix jay@2015/07/11
     *  起因:
     *      服务器端创建考题，memo字段为空时，app加载考试界面时，会因NSDictionary#memo赋值nil而crash
     *  尝试:
     *      数据库表subject#memo默认值为空字符串，无效，因为insert时赋值为nil起效
     *  解决:
     *      只能在insert时判断是否为nil,才能避免crash
     */
    //TODO: 确认每道题分值使用服务器设置的吗？
    [db executeUpdate:@"INSERT INTO subject (subject_id, desc, level, type, score, memo, answer) VALUES (?, ?, ?, ?, ?, ?, ?)", subjectId,
     (NSString *)psd(subjectContent[ExamQuestionTitle], @"NoSet"),
     subjectContent[ExamQuestionLevel],
     subjectContent[ExamQuestionType],
     subjectContent[ExamQuestionScore],
     (NSString *)psd(subjectContent[ExamQuestionNote], @""),
     answer];


    NSMutableArray *options = [subjectContent[ExamQuestionOptions] mutableCopy];
    int seq = 0;

    while ([options count]) {

        int index = arc4random_uniform([options count]);
        NSDictionary *option = options[index];

        [db executeUpdate:@"INSERT INTO option (option_id, subject_id, seq, desc) VALUES (?, ?, ?, ?)", option[ExamQuestionOptionId], subjectId, @(seq++), option[ExamQuestionOptionTitle]];

        [options removeObject:option];
    }
}

+ (NSDictionary*)contentFromDBFile:(NSString*)dbPath
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
        if (![result columnIsNull:@"exam_start"]) {
            content[ExamExamStart] = @([result longLongIntForColumn:@"exam_start"]);
        }
        if (![result columnIsNull:@"exam_end"]) {
            content[ExamExamEnd] = @([result longLongIntForColumn:@"exam_end"]);
        }
        content[ExamAnsType] = @([result intForColumn:@"ans_type"]);
        content[ExamDesc] = [result stringForColumn:@"description"];
        content[ExamPassword] = [result stringForColumn:@"password"];
        content[ExamScore] = @([result intForColumn:@"score"]);
        content[ExamSubmitted] = @([result intForColumn:@"submit"]);
        content[ExamOpened] = @(1);
        content[ExamAllowTimes] = @([result intForColumn:@"allow_times"]);
        content[ExamSubmitTimes] = @([result intForColumn:@"submit_times"]);
        content[ExamQualify] = @([result intForColumn:@"qualify_percent"]);
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

        content[ExamQuestionId]    = subjectId;
        content[ExamQuestionTitle] = [result stringForColumn:@"desc"];
        content[ExamQuestionLevel] = @([result intForColumn:@"level"]);
        content[ExamQuestionType]  = @([result intForColumn:@"type"]);
        content[ExamQuestionNote]  = [result stringForColumn:@"memo"];
        

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

+ (void)setOptionSelected:(BOOL)selected withQuestionId:(NSString*)questionId optionId:(NSString*)optionId andDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            BOOL updateSuccess = [db executeUpdate:@"UPDATE option SET selected=? WHERE subject_id=? AND option_id=?", @(selected), questionId, optionId];

            if (!updateSuccess) {
                NSLog(@"UPDATE FAILED! optionId: %@, questionId: %@, selected: %d", optionId, questionId, selected);
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

+ (void)resetExamStatusOfDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [db beginTransaction];
            [db executeUpdate:@"UPDATE info SET exam_start=NULL, exam_end=NULL, score=-1"];
            [db executeUpdate:@"UPDATE subject SET selected_answer=NULL"];
            [db executeUpdate:@"UPDATE option SET selected=0"];
            [db commit];

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

+ (void)updateExamScore:(NSInteger)score ofDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [db executeUpdate:@"UPDATE info SET score=?", @(score)];
            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
        //        NSLog(@"No DB file at the path: %@", dbPath);
    }
}

+ (NSInteger)calculateExamScoreOfDB:(FMDatabase*)db
{
    [self updateSelectedAnswersOfSubjectsInDB:db];

    //TODO: 得分其实得分率，按每道题分值计算
    //NSInteger totalSubjectCount = [db intForQuery:@"SELECT COUNT(*) FROM subject"];
    //NSInteger correctCount = [db intForQuery:@"SELECT COUNT(*) FROM subject WHERE answer=selected_answer"];
    NSInteger totalSubjectCount = [db intForQuery:@"SELECT SUM(score) FROM subject"];
    NSInteger correctCount = [db intForQuery:@"SELECT SUM(score) FROM subject WHERE answer=selected_answer"];

    NSInteger score = (float)correctCount/(float)totalSubjectCount * 100.0 + 0.5;

    [db executeUpdate:@"UPDATE info SET score=?", @(score)];

    return score;
}

+ (void)updateSubmitTimes:(NSInteger)submitTimes ofDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [db executeUpdate:@"UPDATE info SET submit_times=?", @(submitTimes)];
            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
        //        NSLog(@"No DB file at the path: %@", dbPath);
    }
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

+ (void)generateUploadJsonFromDBPath:(NSString*)dbPath
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
