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
#import "ExtendNSLogFunctionality.h"

static NSString *const kServerAddress = @"https://tsa-china.takeda.com.cn/uat/api/v1";

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
        NSLog(@"%@", requestUrl);
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

            NSLog(@"Download Exams of UserId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", userId, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            NSFileManager *fileMgr = [NSFileManager defaultManager];
            [fileMgr removeItemAtPath:outputPathTmp error:nil];

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

            NSLog(@"Download ExamId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", examId, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);
            
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            [fileMgr moveItemAtPath:outputPathTmp toPath:outputPath error:&error];

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

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];

        request.HTTPMethod = @"PUT";
        NSData *bodyData = [NSData dataWithContentsOfFile:resultPath];
        request.HTTPBody = bodyData;

        AFHTTPRequestOperation *op = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {

            [fileMgr removeItemAtPath:resultPath error:nil];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamResult:examId withError:nil];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Upload result of ExamId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", examId, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamResult:examId withError:error];
            }

        }];
        op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [op start];
    }
}

- (void)uploadExamScannedResult:(NSString*)result
{
    if ([result length]) {

        NSArray *components = [result componentsSeparatedByString:@"+"];
        NSString *userId = components[0];
        NSString *examId = components[1];
        NSString *score = components[2];

        NSString *requestUrl = [NSString stringWithFormat:@"%@/user/%@/result/%@/offline", kServerAddress, userId, examId];
        NSDictionary *parameters = @{@"score": score};

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

        AFHTTPRequestOperation *op = [manager POST:requestUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamScannedResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamScannedResult:result withError:nil];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Upload Scanned Exam Result: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", result, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamScannedResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamScannedResult:result withError:error];
            }
        }];

        op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
}

- (void)downloadQuestionnairesForUser:(NSString*)userId
{

}

- (void)downloadQuestionnaireWithId:(NSString*)examId
{
    
}

- (void)uploadQuestionnaireResultWithPath:(NSString*)resultPath
{

}

@end
