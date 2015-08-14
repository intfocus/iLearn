//
//  CourseWrap+CoursePackageDetail.h
//  iLearn
//
//  Created by lijunjie on 15/8/2.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CourseWrap.h"

@interface CourseWrap (CoursePackageDetail)
- (CourseWrap *)initWithDataAndCourse:(NSDictionary *)data;
+ (NSArray *)loadCourseWraps:(NSArray *)courseWraps;
@end
