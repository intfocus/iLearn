//
//  CoursePackageContent.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageContent.h"
#import "ExtendNSLogFunctionality.h"

@implementation CoursePackageContent

- (CoursePackageContent *)initWithData:(NSDictionary *)data {
    if(self = [super init]) {
        _packagesList = [self makeNotNil:data[COURSE_PACKAGES_FIELD_PACKAGES]];
        _courseList   = [self makeNotNil:data[COURSE_PACKAGES_FIELD_COURSES]];
        _questionList = [self makeNotNil:data[COURSE_PACKAGES_FIELD_QUESTIONS]];
        _examList     = [self makeNotNil:data[COURSE_PACKAGES_FIELD_EXAMS]];
    }
    return self;
}

#pragma mark - asisstant methods
- (NSArray *)makeNotNil:(id)array {
    return (NSArray *)psd(array, @[]);
}
@end
