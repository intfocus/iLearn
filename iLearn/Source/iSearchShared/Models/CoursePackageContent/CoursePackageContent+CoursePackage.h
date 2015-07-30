//
//  CoursePackageContent+CoursePackage.h
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageContent.h"
@class CoursePackage;

/**
 *  课程包内容需要解析父课程包信息
 */
@interface CoursePackageContent (CoursePackage)
/**
 *  直接加载课程包信息
 *
 *  @param package 父课程包
 */
- (void)loadDataFrom:(CoursePackage *)package;
@end
