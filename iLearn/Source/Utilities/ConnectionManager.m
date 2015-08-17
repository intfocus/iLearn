//
//  ConnectionManager.m
//  iLearn
//
//  Created by Charlie Hung on 2015/6/15.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ConnectionManager.h"
#import "ExamUtil.h"
#import "QuestionnaireUtil.h"
#import "LicenseUtil.h"
#import <AFNetworking.h>
#import "const.h"
#import "ExtendNSLogFunctionality.h"

static NSString *const kServerAddress = @"https://tsa-china.takeda.com.cn/uat/api";


@interface ConnectionManager ()

@end

@implementation ConnectionManager

- (void)downloadExamsForUser:(NSString*)userId
{
    if (userId != nil) {

        NSString *requestUrl = [NSString stringWithFormat:@"%@/v1/user/%@/exam", kServerAddress, userId];
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

        NSString *requestUrl = [NSString stringWithFormat:@"%@/v1/exam/%@", kServerAddress, examId];
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
        NSString *requestUrl = [NSString stringWithFormat:@"%@/v1/user/%@/result/%@", kServerAddress, userId, examId];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];

        request.HTTPMethod = @"PUT";
        NSData *bodyData = [NSData dataWithContentsOfFile:resultPath];
        request.HTTPBody = bodyData;
        request.timeoutInterval = 10.0;

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
    else {
        NSLog(@"exam result file not exist: %@", resultPath);
    }
}

- (void)uploadExamScannedResult:(NSString*)result
{
    if ([result length]) {

        NSArray *components = [result componentsSeparatedByString:@"+"];
        NSString *userId = components[0];
        NSString *examId = components[1];
        NSString *score = components[2];

        NSString *requestUrl = [NSString stringWithFormat:@"%@/v1/user/%@/result/%@/offline", kServerAddress, userId, examId];
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

- (void)downloadQuestionnaires
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/Question_Api.php", kServerAddress];
    NSString *outputPath = [NSString stringWithFormat:@"%@/%@", [QuestionnaireUtil questionnaireFolderPathInDocument], @"Questionnaire.json"];
    NSString *outputPathTmp = [NSString stringWithFormat:@"%@/%@", [ExamUtil examFolderPathInDocument], @"Questionnaire.json.tmp"];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

    AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error;

        [fileMgr removeItemAtPath:outputPath error:nil];
        [fileMgr moveItemAtPath:outputPathTmp toPath:outputPath error:&error];

        if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnairesWithError:)]) {
            [_delegate connectionManagerDidDownloadQuestionnairesWithError:error];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"Download Questionnaires FAILED with statusCode: %lld, responseString: %@, error: %@", (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:outputPathTmp error:nil];

        if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnairesWithError:)]) {
            [_delegate connectionManagerDidDownloadQuestionnairesWithError:error];
        }
    }];

    op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPathTmp append:NO];
}

- (void)downloadQuestionnaireWithId:(NSString*)questionnaireId
{
    if (questionnaireId != nil) {

        NSString *requestUrl = [NSString stringWithFormat:@"%@/QuestionT_Api.php?qid=%@", kServerAddress, questionnaireId];
        NSString *outputPath = [NSString stringWithFormat:@"%@/%@.json", [QuestionnaireUtil questionnaireFolderPathInDocument], questionnaireId];
        NSString *outputPathTmp = [NSString stringWithFormat:@"%@/%@.json.tmp", [QuestionnaireUtil questionnaireFolderPathInDocument], questionnaireId];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

        AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *error;

            [fileMgr removeItemAtPath:outputPath error:nil];
            [fileMgr moveItemAtPath:outputPathTmp toPath:outputPath error:&error];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnaire:withError:)]) {
                [_delegate connectionManagerDidDownloadQuestionnaire:questionnaireId withError:error];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Download QuestionnaireId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", questionnaireId, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            NSFileManager *fileMgr = [NSFileManager defaultManager];
            [fileMgr moveItemAtPath:outputPathTmp toPath:outputPath error:&error];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnaire:withError:)]) {
                [_delegate connectionManagerDidDownloadQuestionnaire:questionnaireId withError:error];
            }
        }];

        op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPathTmp append:NO];
    }
}

- (void)uploadQuestionnaireResultWithPath:(NSString*)resultPath
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isFolder;

    if ([fileMgr fileExistsAtPath:resultPath isDirectory:&isFolder]) {

        NSString *questionnaireId = [[[resultPath pathComponents] lastObject] stringByDeletingPathExtension];
        NSString *requestUrl = [NSString stringWithFormat:@"%@/QuestionReply_Api.php", kServerAddress];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];

        request.HTTPMethod = @"POST";
        NSData *bodyData = [NSData dataWithContentsOfFile:resultPath];
        request.HTTPBody = bodyData;
        request.timeoutInterval = 10.0;

        AFHTTPRequestOperation *op = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {

            [fileMgr removeItemAtPath:resultPath error:nil];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadQuestionnaireResult:withError:)]) {
                [_delegate connectionManagerDidUploadQuestionnaireResult:questionnaireId withError:nil];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Upload result of Questionnaire FAILED with statusCode: %lld, responseString: %@, error: %@", (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadQuestionnaireResult:withError:)]) {
                [_delegate connectionManagerDidUploadQuestionnaireResult:questionnaireId withError:error];
            }
        }];

        op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [op start];
    }
    else {
        NSLog(@"Questionnaire result file not exist: %@", resultPath);
    }
}

@end
