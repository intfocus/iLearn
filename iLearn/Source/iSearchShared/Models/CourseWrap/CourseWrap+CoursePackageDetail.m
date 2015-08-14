//
//  CourseWrap+CoursePackageDetail.m
//  iLearn
//
//  Created by lijunjie on 15/8/2.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CourseWrap+CoursePackageDetail.h"
#import "CoursePackageDetail.h"

@implementation CourseWrap (CoursePackageDetail)

- (CourseWrap *)initWithDataAndCourse:(NSDictionary *)data {
    self = [self initWithData:data];
    self.courseList = [CoursePackageDetail loadCourses:self.originList];

    return self;
}

+ (NSArray *)loadCourseWraps:(NSArray *)courseWraps {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *courseWrap in courseWraps) {
        [array addObject:[[CourseWrap alloc] initWithDataAndCourse:courseWrap]];
    }
    return [NSArray arrayWithArray:array];
}
@end
