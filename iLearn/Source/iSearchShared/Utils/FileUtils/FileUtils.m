//
//  FileUtils.m
//  iContent
//
//  Created by lijunjie on 15/5/11.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileUtils.h"
#import "const.h"
#import "ExtendNSLogFunctionality.h"

@interface FileUtils()
@end

@implementation FileUtils

+ (NSString *)basePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    return [paths objectAtIndex:0];
}
/**
 *  传递目录名取得沙盒中的绝对路径(一级),不存在则创建，请慎用！
 *
 *  @param dirName  目录名称，不存在则创建
 *
 *  @return 沙盒中的绝对路径
 */
+ (NSString *)dirPath: (NSString *)dirName {
    //获取应用程序沙盒的Documents目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [FileUtils basePath];
    BOOL isDir = true, existed;
    
    NSString *configPath = [basePath stringByAppendingPathComponent:LOGIN_CONFIG_FILENAME];
    NSMutableDictionary *configDict = [FileUtils readConfigFile:configPath];
    NSString *userSpaceName = [NSString stringWithFormat:@"%@-%@", configDict[USER_DEPTID], configDict[USER_EMPLOYEEID]];
    NSString *userSpacePath = [basePath stringByAppendingPathComponent:userSpaceName];
    
    // 一级目录路径， 不存在则创建
    NSString *pathName = [userSpacePath stringByAppendingPathComponent:dirName];
    existed = [fileManager fileExistsAtPath:pathName isDirectory:&isDir];
    if ( !(isDir == true && existed == YES) ) {
        [fileManager createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return pathName;
}

/**
 *  传递目录名取得沙盒中的绝对路径(二级)
 *
 *  @param dirName  目录名称，不存在则创建
 *  @param fileName 文件名称或二级目录名称
 *
 *  @return 沙盒中的绝对路径
 */
+ (NSString *)dirPath: (NSString *)dirName FileName:(NSString*) fileName {
    // 一级目录路径， 不存在则创建
    NSString *pathname = [self dirPath:dirName];
    // 二级文件名称或二级目录名称
    pathname = [pathname stringByAppendingPathComponent:fileName];
    
    return pathname;
}

/**
 *  检测目录路径、文件路径是否存在
 *
 *  @param pathname 沙盒中的绝对路径
 *  @param isDir    是否是文件夹类型
 *
 *  @return 布尔类型，存在即TRUE，否则为FALSE
 */
+ (BOOL)checkFileExist:(NSString*)pathname isDir:(BOOL)isDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:pathname isDirectory:&isDir];
    return isExist;
}

/**
 *  课件文件路径
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return 课件文件路径
 */
+ (NSString *)coursePath:(NSString *)courseID Ext:(NSString *)extName {
    NSString *courseName = [NSString stringWithFormat:@"%@.%@", courseID, extName];
    return [self dirPath:COURSE_DIRNAME FileName:courseName];
}
/**
 *  课件内容是否下载
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return BOOL
 */
+ (BOOL)isCourseDownloaded:(NSString *)courseID Ext:(NSString *)extName {
    NSString *coursePath = [self coursePath:courseID Ext:extName];
    return [self checkFileExist:coursePath isDir:NO];
}

/**
 *  课件学习进度
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return BOOL
 */
+ (NSString *)courseProgressPath:(NSString *)courseID Ext:(NSString *)extName {
    NSString *coursePath = [self coursePath:courseID Ext:extName];
    return [NSString stringWithFormat:@"%@.read-progress", coursePath];
}

/**
 *  课件内容是否被阅读
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return BOOL
 */
+ (BOOL)isCourseReaded:(NSString *)courseID Ext:(NSString *)extName {
    return [self checkFileExist:[self courseProgressPath:courseID Ext:extName] isDir:NO];
}

/**
 *  记录学习进度
 *
 *  @param dict     学习进度配置档
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 */
+ (void)recordProgress:(NSDictionary *)dict CourseID:(NSString *)courseID Ext:(NSString *)extName {
    [dict writeToFile:[self courseProgressPath:courseID Ext:extName] atomically:YES];
}
/**
 *  读取配置档，有则读取。
 *  默认为NSMutableDictionary，若读取后为空，则按JSON字符串转NSMutableDictionary处理。
 *
 *  @param pathname 配置档路径
 *
 *  @return 返回配置信息NSMutableDictionary
 */
+ (NSMutableDictionary*)readConfigFile:(NSString*) pathName {
    NSMutableDictionary *dict = [NSMutableDictionary alloc];
    //NSLog(@"pathname: %@", pathname);
    if([self checkFileExist:pathName isDir:false]) {
        dict = [dict initWithContentsOfFile:pathName];
        // 若为空，则为JSON字符串
        if(!dict) {
            NSError *error;
            BOOL isSuccessfully;
            NSString *descContent = [NSString stringWithContentsOfFile:pathName encoding:NSUTF8StringEncoding error:&error];
            isSuccessfully = NSErrorPrint(error, @"read desc file: %@", pathName);
            if(isSuccessfully) {
                dict= [NSJSONSerialization JSONObjectWithData:[descContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                NSErrorPrint(error, @"convert string into json: \n%@", descContent);
            }
        }
    } else {
        dict = [dict init];
    }
    return dict;
}
/**
 *  打印沙盒目录列表, 相当于`tree ./`， 测试时可以用到
 */
+ (void) printDir: (NSString *)dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    if(dirName.length) documentsDirectory = [documentsDirectory stringByAppendingPathComponent:dirName];
    
    NSFileManager *fileManage = [NSFileManager defaultManager];
    
    NSArray *files = [fileManage subpathsAtPath: documentsDirectory];
    NSLog(@"%@",files);
}

/**
 *  物理删除文件，并返回是否删除成功的布尔值。
 *
 *  @param filePath 待删除的文件路径
 *
 *  @return 是否删除成功的布尔值
 */
+ (BOOL)removeFile:(NSString *)filePath {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL removed = [fileManager removeItemAtPath: filePath error: &error];
    if(error)
        NSLog(@"<# remove file %@ failed: %@", filePath, [error localizedDescription]);
    
    return removed;
}


+ (BOOL)move:(NSString *)source to:(NSString *)target {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL moved = [fileManager moveItemAtPath:source toPath:target error:&error];
    if(error)
        NSLog(@"<# move %@ => %@ failed for %@", source, target, [error localizedDescription]);
    
    return moved;
}

/**
 *  文件体积大小转化为可读文字；
 *
 *  831106     => 811.6K
 *  8311060    =>   7.9M
 *  83110600   =>  79.3M
 *  831106000  =>  792.6M
 *
 *  @param fileSize 文件体积大小
 *
 *  @return 可读数字，保留一位小数，追加单位
 */
+ (NSString *)humanFileSize:(NSString *)fileSize {
    NSString *humanSize = [[NSString alloc] init];
    
    @try {
        double convertedValue = [fileSize doubleValue];
        int multiplyFactor = 0;
        
        NSArray *tokens = [NSArray arrayWithObjects:@"B",@"K",@"M",@"G",@"T",nil];
        
        while (convertedValue > 1024) {
            convertedValue /= 1024;
            multiplyFactor++;
        }
        humanSize = [NSString stringWithFormat:@"%4.1f%@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
    } @catch(NSException *e) {
        NSLog(@"convert [%@] into human readability failed for %@", fileSize, [e description]);
        humanSize = fileSize;
    }
    
    return humanSize;
}

/**
 *  NSMutableDictionary写入本地文件
 *
 *  @param data     JSON
 *  @param filePath 目标文件
 */
+ (void) writeJSON:(NSMutableDictionary *)data
              Into:(NSString *)slidePath {
    NSError *error;
    if ([NSJSONSerialization isValidJSONObject:data]) {
        // NSMutableDictionary convert to JSON Data
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSErrorPrint(error, @"NsMutableDict convert to json");
        // JSON Data convert to NSString
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(!error) {
            [jsonStr writeToFile:slidePath atomically:true encoding:NSUTF8StringEncoding error:&error];
            NSErrorPrint(error, @"json string write into desc file#%@", slidePath);
        }
    }
}
/**
 *  计算指定文件路径的文件大小
 *
 *  @param filePath 文件绝对路径
 *
 *  @return 文件体积
 */
+ (NSString *)fileSize:(NSString *)filePath {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]) {
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
        NSErrorPrint(error, @"caculate file size - %@", filePath);
        return [NSString stringWithFormat:@"%lld", [[fileAttributes objectForKey:NSFileSize] longLongValue]];
    }
    return @"0";
}

/**
 *  计算指定文件夹路径的文件体积
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 文件夹体积
 */
+ (NSString *)folderSize:(NSString *)folderPath {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager subpathsOfDirectoryAtPath:folderPath error:&error];
    NSEnumerator *filesEnumerator = [filesArray objectEnumerator];
    NSString *fileName, *filePath;
    unsigned long long int folderSize = 0;
    
    while (fileName = [filesEnumerator nextObject]) {
        filePath = [folderPath stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
        NSErrorPrint(error, @"caculate file size - %@", filePath);
        folderSize +=  [[fileAttributes objectForKey:NSFileSize] longLongValue];
    }
    return [NSString stringWithFormat:@"%lld", folderSize];
}
@end