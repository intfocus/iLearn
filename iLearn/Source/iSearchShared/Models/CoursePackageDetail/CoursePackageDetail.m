//
//  CoursePackageDetail.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackageDetail.h"
/**
 *  课程包内容明细
 */
@implementation CoursePackageDetail

- (CoursePackageDetail *)initWithCourse:(NSDictionary *)data {
    if(self = [super init]) {
        _type       = @"Course";
        _courseId   = data[@"CoursewareId"];
        _courseName = data[@"CoursewareName"];
        _courseDesc = data[@"CoursewareDesc"];
        _courseFile = data[@"CoursewareFile"];
        _courseExt  = data[@"Extension"];
    }
    return self;
}

+ (NSArray *)loadDataFromCourse:(NSArray *)courses {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in courses) {
        [array addObject:[[CoursePackageDetail alloc] initWithCourse:dict]];
    }
    return [NSArray arrayWithArray:array];
}

@end
