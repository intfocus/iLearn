//
//  FileUtils+Course.h
//  iLearn
//
//  Created by lijunjie on 15/8/21.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "FileUtils.h"

@interface FileUtils (Course)

/**
 *  课件文件路径
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *  @param UseExt   是否使用扩展名
 *
 *  @return 课件文件路径
 */
+ (NSString *)coursePath:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName UseExt:(BOOL)useExt;
/**
 *  课件文件路径
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return 课件文件路径
 */
+ (NSString *)coursePath:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName;

/**
 *  课件内容是否下载
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return BOOL
 */
+ (BOOL)isCourseDownloaded:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName;

/**
 *  课件学习进度
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return BOOL
 */
+ (NSString *)courseProgressPath:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName;
/**
 *  课件内容是否被阅读
 *
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 *
 *  @return BOOL
 */
+ (BOOL)isCourseReaded:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName;

/**
 *  记录学习进度
 *
 *  @param dict     学习进度配置档
 *  @param courseID 课程名称 ID
 *  @param extName  课件文件扩展名
 */
+ (void)recordProgress:(NSDictionary *)dict CourseID:(NSString *)courseID Type:(NSString *)typeName Ext:(NSString *)extName;

@end
