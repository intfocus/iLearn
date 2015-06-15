//
//  ConnectionManager.m
//  iLearn
//
//  Created by Charlie Hung on 2015/6/15.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ConnectionManager.h"
#import "ExamUtil.h"
#import "LicenseUtil.h"
#import <AFNetworking.h>

static NSString *const kServerAddress = @"http://elnprd.chinacloudapp.cn/phptest/api/v1";

@interface ConnectionManager ()

@end

@implementation ConnectionManager

//+ (ConnectionManager*)sharedManager
//{
//    static ConnectionManager *sharedManager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedManager = [[self alloc] init];
//    });
//    return sharedManager;
//}

//- (id)init
//{
//    if (self = [super init]) {
//
//    }
//    return self;
//}

- (void)downloadExamsForUser:(NSString*)userId
{
    if (userId != nil) {

        NSString *requestUrl = [NSString stringWithFormat:@"%@/user/%@/exam", kServerAddress, userId];
        NSString *outputPath = [NSString stringWithFormat:@"%@/%@", [ExamUtil examFolderPathInDocument], @"Exam.json"];
        NSString *outputPathTmp = [NSString stringWithFormat:@"%@/%@", [ExamUtil examFolderPathInDocument], @"Exam.json.tmp"];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

        AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *error;

            [fileMgr removeItemAtPath:outputPath error:nil];
            [fileMgr moveItemAtPath:outputPathTmp toPath:outputPath error:&error];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExamsForUser:withError:)]) {
                [_delegate connectionManagerDidDownloadExamsForUser:userId withError:error];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Download Exams of UserId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", userId, (long long)operation.response.statusCode, operation.responseString, error);
            
            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExamsForUser:withError:)]) {
                [_delegate connectionManagerDidDownloadExamsForUser:userId withError:error];
            }
        }];

        op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPathTmp append:NO];
    }
}

- (void)downloadExamWithId:(NSString*)examId
{
    if (examId != nil) {

        NSString *requestUrl = [NSString stringWithFormat:@"%@/exam/%@", kServerAddress, examId];
        NSString *outputPath = [NSString stringWithFormat:@"%@/%@.json", [ExamUtil examFolderPathInDocument], examId];
        NSString *outputPathTmp = [NSString stringWithFormat:@"%@/%@.json.tmp", [ExamUtil examFolderPathInDocument], examId];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

        AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *error;

            [fileMgr removeItemAtPath:outputPath error:nil];
            [fileMgr moveItemAtPath:outputPathTmp toPath:outputPath error:&error];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExam:withError:)]) {
                [_delegate connectionManagerDidDownloadExam:examId withError:error];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Download ExamId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", examId, (long long)operation.response.statusCode, operation.responseString, error);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExam:withError:)]) {
                [_delegate connectionManagerDidDownloadExam:examId withError:error];
            }
        }];

        op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPathTmp append:NO];
    }
}

- (void)uploadExamResultWithPath:(NSString*)resultPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:resultPath isDirectory:&isFolder]) {

        NSString *examId = [[[resultPath pathComponents] lastObject] stringByDeletingPathExtension];

        NSString *userId = [LicenseUtil userId];
        NSString *requestUrl = [NSString stringWithFormat:@"%@/user/%@/result/%@", kServerAddress, userId, examId];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

        AFHTTPRequestOperation *op = [manager PUT:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

            [fileMgr removeItemAtPath:resultPath error:nil];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamResult:examId withError:nil];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Upload result of ExamId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", examId, (long long)operation.response.statusCode, operation.responseString, error);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamResult:examId withError:error];
            }

        }];

        op.inputStream = [NSInputStream inputStreamWithFileAtPath:resultPath];
    }

}

@end
