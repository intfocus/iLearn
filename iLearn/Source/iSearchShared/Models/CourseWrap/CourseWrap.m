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
- (BOOL)canRemove {
    return NO;
}

- (NSString *)desc {
    return [NSString stringWithFormat:@"描述:\n%@", _desc];
}
- (NSString *)typeName {
    return @"课件包";
}

- (NSArray *)statusLabelText {
    return @[@"TODO", @"进入"];
}

- (NSString *)infoButtonImage {
    return @"course_course";
}
@end
