//
//  QuestionnaireUtil.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "QuestionnaireUtil.h"
#import "Constants.h"
#import "LicenseUtil.h"
#import "FileUtils.h"
#import <FMDB.h>

static const BOOL inDeveloping = NO;

@implementation QuestionnaireUtil

+ (NSArray*)loadQuestionaires
{
    NSMutableArray *questionnaires = [NSMutableArray array];
    NSMutableArray *questionnaireIds = [NSMutableArray array];

    // Add Cached Questionnaires first
    NSArray *cachedQuestionnaires = [self loadQuestionnairesFromCache];

    [questionnaires addObjectsFromArray:cachedQuestionnaires];

    for (NSDictionary *questionnaire in cachedQuestionnaires) {
        if (questionnaire[QuestionnaireId]) {
            [questionnaireIds addObject:questionnaire[QuestionnaireId]];
        }
    }

    // Add Questionnaires from Questionnaire.json, if questionnaire's Id already added, use the cached version (may be content of DB or JSON)
    NSString *jsonPath = [NSString stringWithFormat:@"%@/%@", [self questionnaireSourceFolderPath], @"Questionnaire.json"];

    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jsonPath];

    if (fileExist) {

        NSData *contentData = [NSData dataWithContentsOfFile:jsonPath];
        NSError *jsonError;
        NSDictionary *content = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:&jsonError];

        for (NSDictionary *questionnaire in content[Questionnaires]) {

            if (![questionnaireIds containsObject:questionnaire[QuestionnaireId]]) {
                [questionnaires addObject:questionnaire];
            }
        }
    }

    // Check for questionnaire is cached or not
    for (NSMutableDictionary *questionnaire in questionnaires) {
        NSString *questionnaireId = questionnaire[QuestionnaireId];

        NSString *jsonPath = [NSString stringWithFormat:@"%@/%@.json", [self questionnaireSourceFolderPath], questionnaireId];

        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:jsonPath];

        if (fileExist) {
            [questionnaire setObject:@1 forKey:QuestionnaireCached];
        }
        else {
            [questionnaire setObject:@0 forKey:QuestionnaireCached];
        }
    }
    
    /**
     * add#sort jay@2015/08/21
     * 原因:
     *     未排序，会导致问卷列表（内容不变）每次进入app[调查问卷],显示顺序都不一致
     * 排序:
     *     以问卷结束时间降序，再以问卷标题升序
     */
    NSSortDescriptor *firstSort  = [[NSSortDescriptor alloc] initWithKey:QuestionnaireEndDate ascending:NO];
    NSSortDescriptor *secondSort = [[NSSortDescriptor alloc] initWithKey:QuestionnaireTitle ascending:YES];
    NSArray *sortQuestionnaires = [questionnaires sortedArrayUsingDescriptors:[NSArray arrayWithObjects:firstSort, secondSort,nil]];
    
    return sortQuestionnaires;
}

+ (NSArray*)loadQuestionnairesFromCache
{
    NSString *path = [self questionnaireSourceFolderPath];
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
            else if ([file isEqualToString:@"Questionnaire.json"]) {
                continue;
            }

            NSString *questionnaireName = [self fileName:file];
            NSString *dbPath = [self questionnaireDBPathOfFile:questionnaireName];

            // Use the info from DB
            if ([fileMgr fileExistsAtPath:dbPath]) {
                NSDictionary *questionnaireInfo = [self questionnaireInfoFromDBFile:dbPath];
                [contents addObject:questionnaireInfo];
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

+ (NSString*)questionnaireFolderPathInDocument
{
//    NSString *docPath = [self applicationDocumentsDirectory];
//    NSString *questionnairePath = [NSString stringWithFormat:@"%@/%@", docPath, QuestionnaireFolder];
    NSString *questionnairePath = [self questionnaireSourceFolderPath];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if (![fileMgr fileExistsAtPath:questionnairePath isDirectory:&isFolder]) {
        NSLog(@"Folder not exist, create it!");
        NSError *createFolderError;

        BOOL createFolderSucess = [fileMgr createDirectoryAtPath:questionnairePath withIntermediateDirectories:YES attributes:nil error:&createFolderError];

        if (!createFolderSucess) {
            NSLog(@"Create folder %@ failed with error: %@", questionnairePath, createFolderError);
        }
    }

    return questionnairePath;
}

+ (NSString*)questionnaireSourceFolderPath {
    return [FileUtils dirPath:QuestionnaireFolder];
//    if (inDeveloping) {
//        return [self questionnaireFolderPathInBundle];
//    }
//    else {
//        return [self questionnaireFolderPathInDocument];
//    }
}

+ (NSString*)questionnaireDBPathOfFile:(NSString*)fileName
{
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@.db", [self questionnaireFolderPathInDocument], fileName];
    return dbPath;
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
    return content[QuestionnaireTitle];
}

+ (NSString*)descFromContent:(NSDictionary*)content
{
    // questionnaire start date
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:[self startDateFromContent:content]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm"];
    NSString *beginTimeString = [formatter stringFromDate:beginDate];
    NSString *beginString = [NSString stringWithFormat:NSLocalizedString(@"LIST_BEGIN_DATE_TEMPLATE", nil), beginTimeString];

    NSString *descString = [NSString stringWithFormat:@"%@\n\n%@", beginString, content[QuestionnaireDesc]];

    return descString;
}

+ (long long)startDateFromContent:(NSDictionary*)content
{
    NSString *beginDateString = content[QuestionnaireBeginDate];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:beginDateString];

    return [date timeIntervalSince1970];
}

+ (long long)endDateFromContent:(NSDictionary*)content
{
    NSString *endDateString = content[QuestionnaireEndDate];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:endDateString];

    return [date timeIntervalSince1970];
}

+ (void)parseContentIntoDB:(NSDictionary*)content dbPath:(NSString *)dbPath
{
    //NSString *dbPath = [self questionnaireDBPathOfFile:content[CommonFileName]];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if (![fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [self parseInfoOfContent:content intoDB:db];
            [self parseQuestionsOfContent:content intoDB:db];

            [db close];
        }
        else {
            NSLog(@"Cannot open DB at the path: %@", dbPath);
        }
    }
    else {
//        NSLog(@"DB file already exist: %@", dbPath);
    }
}

+ (void)parseInfoOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (questionnaire_id INTEGER PRIMARY KEY, questionnaire_name TEXT, submit INTEGER, status INTEGER, begin TEXT, end TEXT, questionnaire_start INTEGER, questionnaire_end INTEGER, description TEXT, finished INTEGER)"];

    NSDate *now = [NSDate date];
    long long nowInteger = [now timeIntervalSince1970];

    [db executeUpdate:@"INSERT INTO info (questionnaire_id, questionnaire_name, submit, status, begin, end, questionnaire_start, description, finished) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", content[QuestionnaireId], content[QuestionnaireTitle], @0, content[QuestionnaireStatus], content[QuestionnaireBeginDate], content[QuestionnaireEndDate], @(nowInteger), content[QuestionnaireDesc], @0];
}

+ (void)parseQuestionsOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS question (id INTEGER PRIMARY KEY AUTOINCREMENT, question_id INTEGER, desc TEXT, type INTEGER, group_name TEXT, selected_answer TEXT, filled_answer TEXT)"];

    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS option (id INTEGER PRIMARY KEY AUTOINCREMENT, option_id TEXT, question_id INTEGER, seq INTEGER, desc TEXT, selected INTEGER DEFAULT 0)"];

    NSMutableArray *questions = [content[QuestionnaireQuestions] mutableCopy];

    [db beginTransaction];

    for (NSDictionary *question in questions) {
        [self parseQuestionContent:question intoDB:db];
    }

    [db commit];
}

+ (void)parseQuestionContent:(NSDictionary*)questionContent intoDB:(FMDatabase*)db
{
    NSNumber *questionId = questionContent[QuestionnaireQuestionId];

    [db executeUpdate:@"INSERT INTO question (question_id, desc, type, group_name) VALUES (?, ?, ?, ?)", questionId, questionContent[QuestionnaireQuestionTitle], questionContent[QuestionnaireQuestionType], questionContent[QuestionnaireQuestionGroup]];

    for (int i = 0; i < 9; i++) {
        [self parseQuestionContent:questionContent selectionIndex:i questionId:questionId intoDB:db];
    }
}

+ (void)parseQuestionContent:(NSDictionary*)content selectionIndex:(NSInteger)selectionIndex questionId:(NSNumber*)questionId intoDB:(FMDatabase*)db
{
    // Use ASCII to convert index into id
    NSString *selectionId = [NSString stringWithFormat:@"%c", selectionIndex+65];
    NSString *columnName = [NSString stringWithFormat:@"ProblemSelect%@", selectionId];

    if (content[columnName] != [NSNull null]) {
        [db executeUpdate:@"INSERT INTO option (option_id, question_id, seq, desc) VALUES (?, ?, ?, ?)",
         selectionId,
         questionId,
         @(selectionIndex),
         content[columnName]];
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

            [content addEntriesFromDictionary:[self questionnaireInfoFromDB:db]];
            content[QuestionnaireQuestions] = [self questionnaireQuestionsFromDB:db];
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

+ (NSDictionary*)questionnaireInfoFromDBFile:(NSString*)dbPath
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            [content addEntriesFromDictionary:[self questionnaireInfoFromDB:db]];
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

+ (NSDictionary*)questionnaireInfoFromDB:(FMDatabase*)db
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];

    FMResultSet *result = [db executeQuery:@"SELECT * FROM info LIMIT 1"];

    while ([result next]) {
        content[QuestionnaireId] = @([result intForColumn:@"questionnaire_id"]);
        content[QuestionnaireTitle] = [result stringForColumn:@"questionnaire_name"];
        content[QuestionnaireStatus] = @([result intForColumn:@"status"]);
        content[QuestionnaireBeginDate] = [result stringForColumn:@"begin"];
        content[QuestionnaireEndDate] = [result stringForColumn:@"end"];
        content[QuestionnaireQuestionnaireStart] = @([result longLongIntForColumn:@"questionnaire_start"]);
        content[QuestionnaireQuestionnaireEnd] = @([result longLongIntForColumn:@"questionnaire_end"]);
        content[QuestionnaireDesc] = [result stringForColumn:@"description"];
        content[QuestionnaireSubmitted] = @([result intForColumn:@"submit"]);
        content[QuestionnaireFinished] = @([result intForColumn:@"finished"]);
        content[QuestionnaireOpened] = @(1);
    }
    
    return content;
}

+ (NSMutableArray*)questionnaireQuestionsFromDB:(FMDatabase*)db
{
    NSMutableArray *questions = [NSMutableArray array];
    NSMutableDictionary *groupTable = [NSMutableDictionary dictionary];

    FMResultSet *result = [db executeQuery:@"SELECT * FROM question"];

    while ([result next]) {

        NSMutableDictionary *content = [NSMutableDictionary dictionary];

        NSNumber *questionId = @([result intForColumn:@"question_id"]);

        content[QuestionnaireQuestionId] = questionId;
        content[QuestionnaireQuestionTitle] = [result stringForColumn:@"desc"];
        content[QuestionnaireQuestionType] = @([result intForColumn:@"type"]);

        NSMutableArray *options = [NSMutableArray array];

        FMResultSet *optionResult = [db executeQuery:@"SELECT * FROM option WHERE question_id = ?", questionId];

        NSInteger answered = 0;

        NSString *filledAnswer = [result stringForColumn:@"filled_answer"];

        if ([filledAnswer length] > 0) {
            content[QuestionnaireQuestionFilledAnswer] = filledAnswer;
            answered = 1;
        }

        while ([optionResult next]) {

            NSMutableDictionary *option = [NSMutableDictionary dictionary];

            NSString *optionId = [optionResult stringForColumn:@"option_id"];
            option[QuestionnaireQuestionOptionId] = optionId;
            NSNumber *optionSeq = @([optionResult intForColumn:@"seq"]);
            option[QuestionnaireQuestionOptionSeq] = optionSeq;
            option[QuestionnaireQuestionOptionTitle] = [optionResult stringForColumn:@"desc"];
            option[QuestionnaireQuestionOptionSelected] = @([optionResult intForColumn:@"selected"]);

            if ([option[QuestionnaireQuestionOptionSelected] isEqualToNumber:@(1)]) {
                answered = 1;
            }

            [options addObject:option];
        }

        if ([options count]) {
            content[QuestionnaireQuestionOptions] = options;
        }
        content[QuestionnaireQuestionAnswered] = @(answered);

        // Check if the question is belong to a group
        NSString *groupName = [result stringForColumn:@"group_name"];

        if (groupName != nil) {

            NSMutableDictionary *group = groupTable[groupName];

            if (group != nil) { // The group has been located

                NSMutableArray *questions = group[QuestionnaireQuestions];
                [questions addObject:content];

                if (!answered) {
                    group[QuestionnaireQuestionAnswered] = @0;
                }
            }
            else {

                NSMutableDictionary *newGroup = [NSMutableDictionary dictionary];
                newGroup[QuestionnaireQuestionType] = @(QuestionnaireQuestionsTypeGroup);
                newGroup[QuestionnaireQuestionGroup] = groupName;

                NSMutableArray *groupQuestions = [NSMutableArray array];
                [groupQuestions addObject:content];
                newGroup[QuestionnaireQuestions] = groupQuestions;
                newGroup[QuestionnaireQuestionAnswered] = answered? @1: @0;

                groupTable[groupName] = newGroup;
                [questions addObject:newGroup];
            }
        }
        else {
            [questions addObject:content];
        }
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

            BOOL updateSuccess = [db executeUpdate:@"UPDATE option SET selected=? WHERE question_id=? AND option_id=?", @(selected), questionId, optionId];

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

+ (void)saveFilledAnswer:(NSString*)filledAnswer withQuestionId:(NSString*)questionId andDBPath:(NSString*)dbPath
{
    if (filledAnswer == nil) {
        return;
    }

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {

            BOOL updateSuccess = [db executeUpdate:@"UPDATE question SET filled_answer=? WHERE question_id=?", filledAnswer, questionId];

            if (!updateSuccess) {
                NSLog(@"UPDATE FAILED! questionId: %@, filledAnswer: %@", questionId, filledAnswer);
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

+ (void)setQuestionnaireSubmittedwithDBPath:(NSString*)dbPath
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

+ (void)setQuestionnaireSubmitDateWithDBPath:(NSString*)dbPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:dbPath isDirectory:&isFolder]) {
        FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

        if ([db open]) {
            long long nowTimeInterval = [[NSDate date] timeIntervalSince1970];
            [db executeUpdate:@"UPDATE info SET questionnaire_end=?, finished=1", @(nowTimeInterval)];
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

+ (void)updateSelectedAnswersOfQuestionsInDB:(FMDatabase*)db
{
    FMResultSet *questions = [db executeQuery:@"SELECT * FROM question"];

    [db beginTransaction];

    while ([questions next]) {

        NSString *questionId = [questions stringForColumn:@"question_id"];

        FMResultSet *options = [db executeQuery:@"SELECT * FROM option WHERE question_id=? AND selected=1", questionId];
        NSMutableArray *selectedAnswers = [NSMutableArray array];

        while ([options next]) {
            NSString *optionId = [options stringForColumn:@"option_id"];
            [selectedAnswers addObject:optionId];
        }

        [selectedAnswers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:0];
        }];

        NSString *selectedAnswerString = [selectedAnswers componentsJoinedByString:@"+"];

        [db executeUpdate:@"UPDATE question SET selected_answer=? WHERE question_id=?", selectedAnswerString, questionId];
    }
    
    [db commit];
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

            [self updateSelectedAnswersOfQuestionsInDB:db];

            NSNumber *questionnaireId = @([db intForQuery:@"SELECT questionnaire_id FROM info"]);
            NSNumber *userId = @([[LicenseUtil userId] integerValue]);

            outputPath = [NSString stringWithFormat:@"%@/%@.result", [self questionnaireFolderPathInDocument], questionnaireId];

            long questionnaireSubmitDate = [db longForQuery:@"SELECT questionnaire_end FROM info"];
            NSDate *submitDate = [NSDate dateWithTimeIntervalSince1970:questionnaireSubmitDate];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
            NSString *submitDateString = [formatter stringFromDate:submitDate];

            jsonDic[QuestionnaireResultId] = questionnaireId;
            jsonDic[QuestionnaireResultUserId] = userId;
            jsonDic[QuestionnaireResultSubmitDate] = submitDateString;

            NSMutableArray *resultArray = [NSMutableArray array];

            FMResultSet *questions = [db executeQuery:@"SELECT * FROM question"];

            while ([questions next]) {

                NSMutableDictionary *questionDic = [NSMutableDictionary dictionary];

                NSNumber *questionId = @([questions intForColumn:@"question_id"]);
                QuestionnaireQuestionTypes type = [questions intForColumn:@"type"];
                NSString *selectedAnswer = [questions stringForColumn:@"selected_answer"];
                NSString *filledAnswer = [questions stringForColumn:@"filled_answer"];

                NSString *answer = @"";

                if (type <= QuestionnaireQuestionsTypeMultiple) {
                    answer = [selectedAnswer stringByReplacingOccurrencesOfString:@"+" withString:@""];
                }
                else {
                    answer = filledAnswer;
                }

                questionDic[QuestionnaireQuestionResultId] = questionId;
                questionDic[QuestionnaireQuestionResultAnswer] = answer;

                [resultArray addObject:questionDic];
            }

            jsonDic[QuestionnaireQuestionResult] = resultArray;

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
    NSString *questionnairePath = [self questionnaireFolderPathInDocument];

    NSArray *files = [fileMgr contentsOfDirectoryAtPath:questionnairePath error:nil];
    NSMutableArray *results = [NSMutableArray array];

    for (NSString *file in files) {
        NSString *extension = [file pathExtension];
        if ([extension isEqualToString:@"result"]) {
            NSString *path = [NSString stringWithFormat:@"%@/%@", questionnairePath, file];
            [results addObject:path];
        }
    }

    return results;
}

+ (void)cleanQuestionnaireFolder
{
    NSString *questionnairePath = [self questionnaireFolderPathInDocument];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError *error;
    [fileMgr removeItemAtPath:questionnairePath error:&error];
    
    if (error) {
        NSLog(@"Delete questionnaire folder FAILED with ERROR: %@", [error localizedDescription]);
    }
}

@end
