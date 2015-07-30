//
//  CoursePackage.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CoursePackage.h"

@implementation CoursePackage

- (CoursePackage *)initWithData:(NSDictionary *)data {
    if(self = [super init]) {
        _ID            = data[COURSE_PACKAGES_FIELD_ID];
        _name          = data[COURSE_PACKAGES_FIELD_NAME];
        _desc          = data[COURSE_PACKAGES_FIELD_DESC];
        _availableTime = data[COURSE_PACKAGES_FIELD_AVTIME];
    }
    
    return self;
}
@end
