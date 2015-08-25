//
//  testPostActionLog.m
//  iLearn
//
//  Created by lijunjie on 15/8/24.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HttpResponse.h"
#import "ApiHelper.h"
#import "HttpUtils.h"
#import "Constants.h"
#import "QuestionnaireUtil.h"
#import "LicenseUtil.h"
#import "User.h"
#import "HttpResponse.h"
#import "FileUtils.h"

@interface testPostActionLog : XCTestCase

@end

@implementation testPostActionLog

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPost {
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"AppName"]              = @"iLearn";
//    params[ACTIONLOG_FIELD_UID]     = @"1";
//    params[ACTIONLOG_FIELD_FUNNAME] = @"function-name";
//    params[ACTIONLOG_FIELD_ACTNAME] = @"act-name";
//    params[ACTIONLOG_FIELD_ACTOBJ]  = @"act-obj";
//    params[ACTIONLOG_FIELD_ACTRET]  = @"act-ret";
//    params[ACTIONLOG_FIELD_ACTTIME] = @"2015-08-24 11:02:01";
//    
//    NSString *url = @"https://tsa-china.takeda.com.cn/uat/api/logjson.php";
//    url = @"http://demo.solife.us";
//    HttpResponse *httpResponse = [HttpUtils httpPost:url Params:params];
//    
//    XCTAssertEqual([httpResponse.statusCode intValue], 200);
//    XCTAssertTrue([httpResponse isValid]);
}

- (void)testUploadFile {
//    NSString *filepath = @"/Users/lijunjie/Documents/21.db.zip";
//    NSString *urlString = @"http://demo.solife.us";
//    //urlString = @"http://tsa-china.takeda.com.cn/uat/api/FileUpload_Api.php?ftype=images";
//    NSURL *url = [NSURL URLWithString:urlString];
//    [HttpUtils uploadFileWithURL:url filePath:filepath mimeType:@"application/zip" block:nil];
//    [HttpUtils uploadFileWithURL:url filePath:filepath mimeType:@"application/zip" block:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if(connectionError) {
//            NSLog(@"error: %@", [connectionError localizedDescription]);
//        }
//        else {
//            NSLog(@"response: %@, data: %@", response, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        }
//    }];
}

- (void)testAFNetworking {
//    NSString *dbPath = [QuestionnaireUtil questionnaireDBPathOfFile:@"4"];
//
//    HttpResponse *response = [ApiHelper uploadFile:dbPath userID:[User userID] type:@"question"];
//    if([response isValid]) {
//        ActionLogRecord(@"问卷db文件上传", @"成功", (@{@"dbPath": dbPath,  @"status": @"successfully"}));
//    }
//    else {
//        ActionLogRecord(@"问卷db文件上传", @"失败", (@{@"dbPath": dbPath,  @"error": response.string}));
//    }
}

- (void)testDownload {
    NSString *userID = [User userID];
    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@.db.zip", userID, @"question", @"4"];
    BOOL state = [ApiHelper downloadFile:fileName userID:userID destDir:[FileUtils dirPath:QuestionnaireFolder]];
    NSLog(@"%i", state);
}
@end
