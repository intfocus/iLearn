//
//  QuestionnaireUtil.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "QuestionnaireUtil.h"
#import "Constants.h"

@implementation QuestionnaireUtil

+ (NSArray*)loadQuestionaires
{
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@/", resPath, CacheFolder, QuestionnaireFolder];
    NSError *error;

    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];

    if (!error) {
        NSMutableArray *contents = [NSMutableArray array];

        for (NSString *file in files) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, file];
            NSData *contentData = [NSData dataWithContentsOfFile:filePath];
            NSError *jsonError;

            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:contentData options:0 error:&jsonError];

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

+ (NSString*)titleFromContent:(NSDictionary*)content
{
    return content[QuestionnaireTitle];
}

+ (NSString*)descFromContent:(NSDictionary*)content
{
    return content[QuestionnaireDesc];
}

+ (NSInteger)expirationDateFromContent:(NSDictionary*)content
{
    return [content[QuestionnaireExpirationDate] integerValue];
}

@end
