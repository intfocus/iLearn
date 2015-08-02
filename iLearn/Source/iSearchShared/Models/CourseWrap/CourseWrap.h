//
//  CourseWrap.h
//  iLearn
//
//  Created by lijunjie on 15/8/2.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "BaseModel.h"

/**
 *  课件包，课程包的一部分
 */
@interface CourseWrap : BaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSArray  *originList;
@property (nonatomic, strong) NSArray  *courseList;

- (CourseWrap *)initWithData:(NSDictionary *)data;
- (BOOL)isCourseWrap;
- (NSString *)typeName;
- (NSArray *)statusLabelText;
@end
