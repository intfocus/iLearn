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
#import "FileUtils+Course.h"
#import "Url+Param.h"
#import "ExtendNSLogFunctionality.h"
#import "ApiHelper.h"
#import "HttpResponse.h"

static NSString *const kServerAddress = @"https://tsa-china.takeda.com.cn/uat/api";

@interface ConnectionManager ()

@end

@implementation ConnectionManager

- (void)downloadExamsForUser:(NSString*)userId {
    if (userId != nil) {

        NSString *requestUrl = [NSString stringWithFormat:@"%@/v1/user/%@/exam", kServerAddress, userId];
        NSLog(@"%@", requestUrl);
        NSString *outputPath = [NSString stringWithFormat:@"%@/%@", [ExamUtil examFolderPathInDocument], @"Exam.json"];
        NSString *outputPathTmp = [NSString stringWithFormat:@"%@/%@", [ExamUtil examFolderPathInDocument], @"Exam.json.tmp"];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.requestSerializer.timeoutInterval = 10.0;

        AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

            [FileUtils removeFile:outputPath];
            [FileUtils move:outputPathTmp to:outputPath];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExamsForUser:withError:)]) {
                [_delegate connectionManagerDidDownloadExamsForUser:userId withError:nil];
            }
            
            ActionLogRecord(@"用户考卷下载", @"成功", (@{@"userID": userId, @"url": requestUrl, @"status": @"successfully"}));
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Download Exams of UserId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", userId, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            NSFileManager *fileMgr = [NSFileManager defaultManager];
            [fileMgr removeItemAtPath:outputPathTmp error:nil];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExamsForUser:withError:)]) {
                [_delegate connectionManagerDidDownloadExamsForUser:userId withError:error];
            }
            
            ActionLogRecord(@"用户考卷下载", @"失败", (@{@"userID": userId, @"url": requestUrl, @"error": [error localizedDescription]}));
        }];

        op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPathTmp append:NO];
    }
}

- (void)downloadExamWithId:(NSString*)examId {
    if (examId != nil) {

        NSString *requestUrl = [NSString stringWithFormat:@"%@/v1/exam/%@", kServerAddress, examId];
        NSLog(@"%@", requestUrl);
        NSString *outputPath = [NSString stringWithFormat:@"%@/%@.json", [ExamUtil examFolderPathInDocument], examId];
        NSString *outputPathTmp = [NSString stringWithFormat:@"%@/%@.json.tmp", [ExamUtil examFolderPathInDocument], examId];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
        manager.requestSerializer.timeoutInterval = 10.0;

        AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

            [FileUtils removeFile:outputPath];
            [FileUtils move:outputPathTmp to:outputPath];
            
            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExam:withError:)]) {
                [_delegate connectionManagerDidDownloadExam:examId withError:nil];
            }
            
            ActionLogRecord(@"考卷下载", @"成功", (@{@"examID": examId, @"url": requestUrl, @"status": @"successfully"}));
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Download ExamId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", examId, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);
            
            [FileUtils removeFile:outputPathTmp];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadExam:withError:)]) {
                [_delegate connectionManagerDidDownloadExam:examId withError:error];
            }
            
            ActionLogRecord(@"考卷下载", @"失败", (@{@"examID": examId, @"url": requestUrl, @"error": [error localizedDescription]}));
        }];

        op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPathTmp append:NO];
    }
}

- (void)downloadCourse:(NSString*)courseID Ext:(NSString *)extName {
    NSString *requestUrl    = [Url downloadCourse:courseID Ext:extName];
    NSLog(@"%@", requestUrl);
    NSString *outputPath    = [FileUtils coursePath:courseID Type:kPackageCourse Ext:extName];
    NSString *outputPathTmp = [NSString stringWithFormat:@"%@.json.tmp", outputPath];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    
    AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        
        [FileUtils removeFile:outputPath];
        [FileUtils move:outputPathTmp to:outputPath];
        
        if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadCourse:Ext:withError:)]) {
            [_delegate connectionManagerDidDownloadCourse:courseID Ext:extName withError:error];
        }
        
        ActionLogRecord(@"课件下载", @"成功", (@{@"courseID": courseID, @"extName": extName, @"url": requestUrl,  @"status": @"successfully"}));
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Download Course ID: %@ Ext: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", courseID, extName, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);
        
        [FileUtils removeFile:outputPathTmp];
        
        if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadCourse:Ext:withError:)]) {
            [_delegate connectionManagerDidDownloadCourse:courseID Ext:extName withError:error];
        }
        
        ActionLogRecord(@"课件下载", @"失败", (@{@"courseID": courseID, @"extName": extName, @"url": requestUrl,  @"error": [error localizedDescription]}));
    }];
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPathTmp append:NO];
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
            
            ActionLogRecord(@"考卷上传", @"成功", (@{@"userID": userId, @"examID": examId, @"url": requestUrl,  @"status": @"successfully"}));
//            NSString *dbPath = [ExamUtil examDBPath:examId];
//        
//            HttpResponse *response = [ApiHelper uploadFile:dbPath userID:userId type:@"question"];
//            if([response isValid]) {
//                ActionLogRecord(@"考卷db上传", @"成功", (@{@"dbPath": dbPath,  @"status": @"successfully"}));
//            }
//            else {
//                ActionLogRecord(@"考卷db上传", @"失败", (@{@"dbPath": dbPath,  @"error": response.string}));
//            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Upload result of ExamId: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", examId, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamResult:examId withError:error];
            }
            
            ActionLogRecord(@"考卷上传", @"失败", (@{@"userID": userId, @"examID": examId, @"url": requestUrl,  @"error": [error localizedDescription]}));
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
        NSLog(@"%@", requestUrl);
        NSDictionary *parameters = @{@"score": score};

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

        AFHTTPRequestOperation *op = [manager POST:requestUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamScannedResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamScannedResult:result withError:nil];
            }
            
            ActionLogRecord(@"考卷上传", @"成功", (@{@"userID": userId, @"examID": examId, @"url": requestUrl,  @"status": @"successfully"}));
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Upload Scanned Exam Result: %@ FAILED with statusCode: %lld, responseString: %@, error: %@", result, (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadExamScannedResult:withError:)]) {
                [_delegate connectionManagerDidUploadExamScannedResult:result withError:error];
            }
            
            ActionLogRecord(@"考卷上传", @"失败", (@{@"userID": userId, @"examID": examId, @"url": requestUrl,  @"error": [error localizedDescription]}));
        }];

        op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
}

- (void)downloadQuestionnaires
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/Question_Api.php", kServerAddress];
    NSLog(@"%@", requestUrl);
    NSString *outputPath = [NSString stringWithFormat:@"%@/%@", [QuestionnaireUtil questionnaireFolderPathInDocument], @"Questionnaire.json"];
    NSString *outputPathTmp = [NSString stringWithFormat:@"%@/%@", [QuestionnaireUtil questionnaireFolderPathInDocument], @"Questionnaire.json.tmp"];

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];

    AFHTTPRequestOperation *op = [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [FileUtils removeFile:outputPath];
        [FileUtils move:outputPathTmp to:outputPath];
        
        if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnairesWithError:)]) {
            [_delegate connectionManagerDidDownloadQuestionnairesWithError:nil];
        }
        
        ActionLogRecord(@"用户问卷下载", @"成功", (@{@"url": requestUrl,  @"status": @"successfully"}));
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [FileUtils removeFile:outputPathTmp];

        if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnairesWithError:)]) {
            [_delegate connectionManagerDidDownloadQuestionnairesWithError:error];
        }
        
        ActionLogRecord(@"用户问卷下载", @"失败", (@{@"url": requestUrl,  @"error": [error localizedDescription]}));
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

            [FileUtils removeFile:outputPath];
            [FileUtils move:outputPathTmp to:outputPath];
            
            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnaire:withError:)]) {
                [_delegate connectionManagerDidDownloadQuestionnaire:questionnaireId withError:nil];
            }
            
            ActionLogRecord(@"问卷下载", @"成功", (@{@"questionnaireID": questionnaireId, @"url": requestUrl,  @"status": @"successfully"}));
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            [FileUtils removeFile:outputPathTmp];

            if ([_delegate respondsToSelector:@selector(connectionManagerDidDownloadQuestionnaire:withError:)]) {
                [_delegate connectionManagerDidDownloadQuestionnaire:questionnaireId withError:error];
            }
            
            ActionLogRecord(@"问卷下载", @"失败", (@{@"questionnaireID": questionnaireId, @"url": requestUrl,  @"error": [error localizedDescription]}));
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
            
            ActionLogRecord(@"问卷上传", @"成功", (@{@"url": requestUrl,  @"status": @"successfully"}));
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Upload result of Questionnaire FAILED with statusCode: %lld, responseString: %@, error: %@", (long long)operation.response.statusCode, operation.responseString, [error localizedDescription]);

            if ([_delegate respondsToSelector:@selector(connectionManagerDidUploadQuestionnaireResult:withError:)]) {
                [_delegate connectionManagerDidUploadQuestionnaireResult:questionnaireId withError:error];
            }
            
            ActionLogRecord(@"问卷上传", @"失败", (@{@"url": requestUrl,  @"error": [error localizedDescription]}));
        }];

        op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [op start];
    }
    else {
        NSLog(@"Questionnaire result file not exist: %@", resultPath);
    }
}

@end
