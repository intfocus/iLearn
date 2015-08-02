//
//  CourseWrap.m
//  iLearn
//
//  Created by lijunjie on 15/8/2.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CourseWrap.h"

@implementation CourseWrap

- (CourseWrap *)initWithData:(NSDictionary *)data {
    if(self = [super init]) {
        _name = [self defaultStringWhenNil:data[COURSE_WRAP_FIELD_NAME]];
        _desc = [self defaultStringWhenNil:data[COURSE_WRAP_FIELD_DESC]];
        _originList = [self defaultArrayWhenNil:data[COURSE_WRAP_FIELD_LIST]];
        _courseList = @[];
    }
    return self;
}

- (BOOL)isCourseWrap {
    return YES;
}

- (NSString *)typeName {
    return @"课件包";
}

- (NSString *)statusLabelText {
    return @"todo";
}

- (NSString *)actionButtonState {
    return @"进入";
}
@end
