//
//  CoursePackage.h
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "BaseModel.h"

/**
 *  课程包
 */
@interface CoursePackage : BaseModel

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *availableTime;

// instance methods
- (CoursePackage *)initWithData:(NSDictionary *)data;
- (BOOL)canRemove;
@end
