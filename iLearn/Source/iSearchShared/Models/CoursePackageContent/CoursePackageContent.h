//
//  CoursePackageContent.h
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "BaseModel.h"

/**
 *  课程包材料: 课件包、课件列表、考试列表
 */
@interface CoursePackageContent : BaseModel

// 课程包信息
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *availableTime;

// 课件包
@property (nonatomic, strong) NSArray *courseWrapList;
// 课件列表
@property (nonatomic, strong) NSArray *courseList;
// 问卷列表
@property (nonatomic, strong) NSArray *questionList;
// 考试列表
@property (nonatomic, strong) NSArray *examList;

- (CoursePackageContent *)initWithData:(NSDictionary *)data;
@end
