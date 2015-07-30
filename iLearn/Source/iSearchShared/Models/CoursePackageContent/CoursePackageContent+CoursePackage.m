//
//  CoursePackageContent+CoursePackage.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageContent+CoursePackage.h"
#import "CoursePackage.h"

@implementation CoursePackageContent (CoursePackage)

/**
 *  直接加载课程包信息
 *
 *  @param package 父课程包
 */
- (void)loadDataFrom:(CoursePackage *)package {
    self.ID = package.ID;
    self.name = package.name;
    self.desc = package.desc;
    self.availableTime = package.availableTime;
}
@end
