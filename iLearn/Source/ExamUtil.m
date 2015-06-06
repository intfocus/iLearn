//
//  ExamUtil.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/28.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ExamUtil.h"
#import "Constants.h"
#import "FMDB.h"

@implementation ExamUtil

+ (NSArray*)loadExams
{
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@/", resPath, CacheFolder, ExamFolder];
    NSError *error;

    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];

    if (!error) {
        NSMutableArray *contents = [NSMutableArray array];

        for (NSString *file in files) {
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
    return content[ExamDesc];
}

+ (NSInteger)expirationDateFromContent:(NSDictionary*)content
{
    return [content[ExamExpirationDate] integerValue];
}

+ (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString*)examFolderPath
{
    NSString *docPath = [self applicationDocumentsDirectory];
    NSString *examPath = [NSString stringWithFormat:@"%@/%@", docPath, ExamFolder];

    return examPath;
}

+ (NSString*)examDBPathOfFile:(NSString*)fileName
{
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@.db", [self examFolderPath], fileName];
    return dbPath;
}

+ (void)parseContentIntoDB:(NSDictionary*)content
{
    NSString *examPath = [self examFolderPath];
    NSString *dbPath = [self examDBPathOfFile:content[CommonFileName]];

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
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (exam_id INTEGER PRIMARY KEY, exam_name TEXT, submit INTEGER, status INTEGER, type INTEGER, begin INTEGER, end INTEGER, expire_time INTEGER, ans_type INTEGER, description TEXT, score INTEGER DEFAULT -1)"];

    NSDate *now = [NSDate date];

    [db executeUpdate:@"INSERT INTO info (exam_id, exam_name, submit, status, type, begin, expire_time, ans_type, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", content[ExamId], content[ExamTitle], @0, content[ExamStatus], content[ExamType], @((int)[now timeIntervalSince1970]), content[ExamExpirationDate], content[ExamAnsType], content[ExamDesc]];
}

+ (void)parseSubjectsOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS subject (id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER, desc TEXT, level INTEGER, type INTEGER, memo TEXT, answer TEXT, selected_answer TEXT)"];

    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS option (id INTEGER PRIMARY KEY AUTOINCREMENT, option_id INTEGER, subject_id INTEGER, seq INTEGER, desc TEXT, selected INTEGER DEFAULT 0)"];

    NSMutableArray *subjects = [content[ExamQuestions] mutableCopy];

    while ([subjects count]) {

        int index = arc4random_uniform([subjects count]);
        NSDictionary *subject = subjects[index];

        [self parseSubjectContent:subject intoDB:db];
        [subjects removeObject:subject];
    }

}

+ (void)parseSubjectContent:(NSDictionary*)subjectContent intoDB:(FMDatabase*)db
{
    NSNumber *subjectId = subjectContent[ExamQuestionId];

    NSArray *answers = subjectContent[ExamQuestionAnswer];
    NSString *answer = [answers componentsJoinedByString:@"+"];

    [db executeUpdate:@"INSERT INTO subject (subject_id, desc, level, type, memo, answer) VALUES (?, ?, ?, ?, ?, ?)", subjectId, subjectContent[ExamQuestionTitle], subjectContent[ExamQuestionLevel], subjectContent[ExamQuestionType], subjectContent[ExamQuestionNote], answer];


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
        NSLog(@"No DB file at the path: %@", dbPath);
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
        content[ExamBeginDate] = @([result intForColumn:@"begin"]);
        content[ExamExpirationDate] = @([result intForColumn:@"expire_time"]);
        content[ExamAnsType] = @([result intForColumn:@"ans_type"]);
        content[ExamDesc] = [result stringForColumn:@"description"];
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
        NSLog(@"Not DB file at the path: %@", dbPath);
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
        NSLog(@"Not DB file at the path: %@", dbPath);
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
        NSLog(@"Not DB file at the path: %@", dbPath);
    }
    return score;
}

+ (NSInteger)calculateExamScoreOfDB:(FMDatabase*)db
{
    [self updateSelectedAnswersOfSubjectsInDB:db];

    NSInteger totalSubjectCount = [db intForQuery:@"SELECT COUNT(*) FROM subject"];
    NSInteger correctCount = [db intForQuery:@"SELECT COUNT(*) FROM subject WHERE answer=selected_answer"];

    NSInteger score = (float)correctCount/(float)totalSubjectCount * 100.0;

    [db executeUpdate:@"UPDATE info SET score=?", @(score)];

    return score;
}

+ (void)updateSelectedAnswersOfSubjectsInDB:(FMDatabase*)db
{
    FMResultSet *subjects = [db executeQuery:@"SELECT * FROM subject"];

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
}

@end
