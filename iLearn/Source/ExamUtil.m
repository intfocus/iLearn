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

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

    if ([db open]) {

        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS info (exam_id TEXT, exam_name TEXT, submit INTEGER, status INTEGER, type INTEGER, begin INTEGER, end INTEGER, expire_time INTEGER, ans_type INTEGER, description TEXT)"];

        NSDate *now = [NSDate date];

        [db executeUpdate:@"INSERT INTO info (exam_id, exam_name, submit, status, type, begin, expire_time, ans_type, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", content[ExamId], content[ExamTitle], @0, content[ExamStatus], content[ExamType], @((int)[now timeIntervalSince1970]), content[ExamExpirationDate], content[ExamAnsType], content[ExamDesc]];



        [db close];
    }
}

@end
