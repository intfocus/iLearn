//
//  HttpUtils.m
//  iLogin
//
//  Created by lijunjie on 15/5/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sys/utsname.h"
#import "HttpUtils.h"
#import "const.h"
#import "HttpResponse.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "AFNetworking.h"
#import "ExtendNSLogFunctionality.h"

@interface HttpUtils()

@end

@implementation HttpUtils

/**
 *  考试/问卷结果db文件上传
 *
 *  @param filePath 文件路径
 *  @param userID   用户ID
 */
+ (HttpResponse *)uploadFile:(NSString *)filePath userID:(NSString *)userID {
    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath]; //@"/Users/lijunjie/Documents/21.db.zip"
    NSString *urlStr = @"http://demo.solife.us/upload";
    
    urlStr = @"http://tsa-china.takeda.com.cn/uat/api/FileUpload_Api.php";
                                         
    //创建Request对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    NSMutableData *body = [NSMutableData data];
    
    //设置表单项分隔符
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    //设置内容类型
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //写入文件的内容
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"21.db.zip\"\r\n",@"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/zip\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithContentsOfURL:filePathUrl]];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 写入 INFO 的内容
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"UserId"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[userID dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"FileType"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[filePath pathExtension] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    //写入尾部内容
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    HttpResponse *httpResonse = [[HttpResponse alloc] init];
    httpResonse.received = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponese error:&error];
    httpResonse.response = urlResponese;
    //NSLog(@"%@", [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
//    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:nil];
//    NSLog(@"%@", responseDic);
    return httpResonse;
}

/**
 *  Http#Get功能代码封装
 *
 *  服务器响应处理:
 *  dict{HTTP_ERRORS, HTTP_RESPONSE, HTTP_RESONSE_DATA}
 *  HTTP_ERRORS: 与服务器交互中出现错误，此值不空时，不需再使用其他值
 *  HTTP_RESPONSE: 服务器响应的内容
 *  HTTP_RESPOSNE_DATA: 服务器响应内容转化为NSDictionary
 *
 *  @return Http#Get HttpResponse
 */
+ (HttpResponse *)httpGet:(NSString *)urlString timeoutInterval:(NSTimeInterval)timeoutInterval {
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    HttpResponse *httpResponse = [[HttpResponse alloc] init];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:timeoutInterval];
    NSError *error;
    NSURLResponse *response;
    httpResponse.received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    httpResponse.response = (NSHTTPURLResponse*)response;
    BOOL isOK   = NSErrorPrint(error, @"Http#get %@", urlString);
    if(!isOK) {
        [httpResponse.errors addObject:(NSString *)psd([error localizedDescription], @"http get未知错误")];
    }
    
    return httpResponse;
}


/**
 *  应用从服务器获取数据，设置超时时间为: 15.0秒
 *
 *  @param urlString 服务器链接
 *
 *  @return Http#Get HttpResponse
 */
+ (HttpResponse *)httpGet:(NSString *)urlString {
    return [HttpUtils httpGet:urlString timeoutInterval:15.0];
}

/**
 *  Http#Post功能代码封装
 *  application/x-www-form-urlencoded
 *
 *  @param urlString URL
 *  @param Params    参数，格式param1=value1&param2=value2
 *
 *  @return Http#Post 响应内容
 */
+ (HttpResponse *)httpPost:(NSString *)urlString Params:(NSMutableDictionary *)params {
    urlString  = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    //params     = [params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                           timeoutInterval:3.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error: &error];
    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
    [request setHTTPBody:tempJsonData];
    
    NSURLResponse *response;
    HttpResponse *httpResponse = [[HttpResponse alloc] init];
    httpResponse.received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    httpResponse.response = (NSHTTPURLResponse *)response;
    BOOL isOK   = NSErrorPrint(error, @"Http#post %@", urlString);
    if(!isOK) {
        [httpResponse.errors addObject:(NSString *)psd([error localizedDescription], @"http get未知错误")];
    }

    return httpResponse;
}

/**
 *  动态设置
 *
 *  @return 有网络则为true
 */
+ (BOOL)isNetworkAvailable {
    return [self isNetworkAvailable:1.0];
}

+ (BOOL)isNetworkAvailable:(NSTimeInterval)timeoutInterval {
    HttpResponse *httpResponse = [HttpUtils httpGet:@"http://www.apple.com" timeoutInterval:timeoutInterval];
    
    return (httpResponse.statusCode && ([httpResponse.statusCode intValue] == 200));
}

/**
 *  检测当前app网络环境
 *
 *  @return 有网络则为true
 */
+ (BOOL) isNetworkAvailable2 {
    BOOL isExistenceNetwork = NO;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            break;
    }
    
    return isExistenceNetwork;
}
/**
 *  有网络环境时的网络类型
 *
 *  @return 网络类型字符串
 */
+ (NSString *)networkType {
    NSString *_netWorkType = @"无";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            break;
        case ReachableViaWiFi:
            _netWorkType = @"wifi";
            break;
        case ReachableViaWWAN:
            _netWorkType = @"3g";
            break;
    }
    
    return _netWorkType;
}


#pragma mark - upload file

static NSString *boundaryStr = @"--"; // 分隔字符串
static NSString *randomIDStr = @"iLearn_iSearch"; // 本次上传标示字符串
static NSString *uploadID = @"uploadFile"; // 上传(php)脚本中，接收文件字段


#pragma mark - 私有方法
+ (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", uploadID, uploadFile];
    [strM appendFormat:@"Content-Type: %@\n\n", mimeType];
    
    return [strM copy];
}

+ (NSString *)bottomString
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendString:@"Content-Disposition: form-data; name=\"submit\"\n\n"];
    [strM appendString:@"Submit\n"];
    [strM appendFormat:@"%@%@--\n", boundaryStr, randomIDStr];
    
    NSLog(@"%@", strM);
    return [strM copy];
}

#pragma mark - 上传文件
+ (void)uploadFileWithURL:(NSURL *)url
                 filePath:(NSString *)filePath
                 mimeType:(NSString *)mimeType
                    block:(void(^)(NSURLResponse *response, NSData *data, NSError *connectionError))completeBlock {
    // 1> 数据体
    NSString *topStr = [self topStringWithMimeType:mimeType uploadFile:[filePath lastPathComponent]];
    NSString *bottomStr = [self bottomString];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableData *dataM = [NSMutableData data];
    [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:data];
    [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 1. Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:6.0f];
    
    // dataM出了作用域就会被释放,因此不用copy
    request.HTTPBody = dataM;
    
    // 2> 设置Request的头属性
    request.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    // 3> 连接服务器发送请求
    NSError *error;
    NSHTTPURLResponse *response;
    HttpResponse *httpResponse = [[HttpResponse alloc] init];
    httpResponse.received = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    httpResponse.response = (NSHTTPURLResponse *)response;
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[[NSOperationQueue alloc] init]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        completeBlock(response, data, connectionError);
//    }];
}

@end