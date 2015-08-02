//
//  CoursePackageContent.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageContent.h"

@implementation CoursePackageContent

- (CoursePackageContent *)initWithData:(NSDictionary *)data {
    if(self = [super init]) {
        _courseWrapList = [self defaultArrayWhenNil:data[COURSE_PACKAGES_FIELD_PACKAGES]];
        _courseList   = [self defaultArrayWhenNil:data[COURSE_PACKAGES_FIELD_COURSES]];
        _questionList = [self defaultArrayWhenNil:data[COURSE_PACKAGES_FIELD_QUESTIONS]];
        _examList     = [self defaultArrayWhenNil:data[COURSE_PACKAGES_FIELD_EXAMS]];
    }
    return self;
}
@end
