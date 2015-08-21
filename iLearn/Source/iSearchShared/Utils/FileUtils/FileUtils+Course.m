//
//  FileUtils+Course.m
//  iLearn
//
//  Created by lijunjie on 15/8/21.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "FileUtils+Course.h"
#import "const.h"

@implementation FileUtils (Course)

/**
 *  课件文件路径
 *
 *  @param courseID 课程名称 ID
 *  @param typeName 类型: 考试/问卷 ID可能冲突，所以分别使用文件夹
 *  @param extName  课件文件扩展名
 *  @param UseExt   是否使用扩展名
 *
 *  @return 课件文件路径
 */
+ (NSString *)coursePath:(NSString *)courseID
                    Type:(NSString *)typeName
                     Ext:(NSString *)extName
                  UseExt:(BOOL)useExt {
    NSString *courseName;
    if(useExt) {
        courseName = [NSString stringWithFormat:@"%@.%@", courseID, extName];
    }
    else {
        courseName = courseID;
    }
    NSString *typePath = [self dirPath:COURSE_DIRNAME FileName:typeName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![FileUtils checkFileExist:typePath isDir:YES]) {
        [fileManager createDirectoryAtPath:typePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [typePath stringByAppendingPathComponent:courseName];
}

+ (NSString *)coursePath:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName {
    return [self coursePath:courseID Type:typeName Ext:extName UseExt:YES];
}
/**
 *  课件内容是否下载
 *
 *  @param courseID 课程名称 ID
 *  @param typeName 类型: 考试/问卷 ID可能冲突，所以分别使用文件夹
 *  @param extName  课件文件扩展名
 *
 *  @return BOOL
 */
+ (BOOL)isCourseDownloaded:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName {
    NSString *coursePath = [self coursePath:courseID Type:typeName Ext:extName];
    
    if([extName isEqualToString:@"zip"]) {
        coursePath = [coursePath stringByDeletingPathExtension];
        return [self checkFileExist:coursePath isDir:YES];
    }
    
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
+ (NSString *)courseProgressPath:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName {
    NSString *coursePath = [self coursePath:courseID Type:typeName Ext:extName];
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
+ (BOOL)isCourseReaded:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName {
    return [self checkFileExist:[self courseProgressPath:courseID Type:typeName Ext:extName] isDir:NO];
}

/**
 *  记录学习进度
 *
 *  @param dict     学习进度配置档
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 */
+ (void)recordProgress:(NSDictionary *)dict CourseID:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName {
    [dict writeToFile:[self courseProgressPath:courseID Type:(NSString *)typeName Ext:extName] atomically:YES];
}
@end
