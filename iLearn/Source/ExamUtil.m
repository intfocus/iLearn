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

+ (NSString*)fileName:(NSString*)fullName
{
    NSRange range = [fullName rangeOfString:@"."];
    if (range.location != NSNotFound) {
        return [fullName substringToIndex:range.location];
    }
    else {
        return fullName;
    }
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

+ (void)parseContentIntoDB:(NSDictionary*)content
{
    NSString *docPath = [self applicationDocumentsDirectory];
    NSString *examPath = [NSString stringWithFormat:@"%@/%@", docPath, ExamFolder];
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@/%@.db", docPath, ExamFolder, content[CommonFileName]];

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
    }
}

+ (void)parseInfoOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (exam_id INTEGER PRIMARY KEY, exam_name TEXT, submit INTEGER, status INTEGER, type INTEGER, begin INTEGER, end INTEGER, expire_time INTEGER, ans_type INTEGER, description TEXT)"];

    NSDate *now = [NSDate date];

    [db executeUpdate:@"INSERT INTO info (exam_id, exam_name, submit, status, type, begin, expire_time, ans_type, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", content[ExamId], content[ExamTitle], @0, content[ExamStatus], content[ExamType], @((int)[now timeIntervalSince1970]), content[ExamExpirationDate], content[ExamAnsType], content[ExamDesc]];
}

+ (void)parseSubjectsOfContent:(NSDictionary*)content intoDB:(FMDatabase*)db
{
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS subject (id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER, desc TEXT, level INTEGER, type INTEGER, memo TEXT, answer TEXT, selected_answer TEXT)"];

    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS option (id INTEGER PRIMARY KEY AUTOINCREMENT, option_id INTEGER, subject_id INTEGER, seq INTEGER, desc TEXT)"];

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
    NSMutableString *answer = [NSMutableString string];

    for (NSString *answerId in answers) {

        [answer appendString:answerId];
        if (![answerId isEqualToString:[answers lastObject]]) {
            [answer appendString:@"+"];
        }
    }

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

@end
