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
    NSString *filepath = @"/Users/lijunjie/Documents/21.db.zip";
    NSString *urlString = @"http://demo.solife.us/uploadfile";
    NSURL *url = [NSURL URLWithString:urlString];
    [HttpUtils uploadFileWithURL:url filePath:filepath mimeType:@"application/zip" block:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            NSLog(@"error: %@", [connectionError localizedDescription]);
        }
        else {
            NSLog(@"response: %@, data: %@", response, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
}
@end
