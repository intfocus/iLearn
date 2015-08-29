//
//  TrainCourse.m
//  iLearn
//
//  Created by lijunjie on 15/8/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "TrainCourse.h"

@implementation TrainCourse

- (TrainCourse *)initData:(NSDictionary *)dict type:(NSString *)typeName {
    if(self = [super init]) {
        _type           = typeName;
        _ID             = dict[@"Id"];
        _name           = dict[@"Name"];
        _lecturer       = dict[@"SpeakerName"];
        _begin          = dict[@"Begin"];
        _end            = dict[@"End"];
        _startDate      = dict[@"StartDate"];
        _endDate        = dict[@"EndDate"];
        _location       = dict[@"Location"];
        _memo           = dict[@"Memo"];
        _manager        = dict[@"Manager"];
        _status         = dict[@"Status"];
        _approreLevel   = dict[@"ApproreLevel"];
        _traineesStatus = dict[@"TraineesStatus"];
    }
    _originalDict = dict;
    
    return self;
}

- (TrainCourse *)initCourseData:(NSDictionary *)dict {
    return [self initData:dict type:@"course"];
}

- (TrainCourse *)initSigninData:(NSDictionary *)dict {
    return [self initData:dict type:@"signin"];
}

- (BOOL)isCourse {
    return [self.type isEqualToString:@"course"];
}
- (BOOL)isSignin {
    return [self.type isEqualToString:@"signin"];
}

- (NSString *)actionButtonLabel {
    NSString *label = @"TODO";
    
    if([self isCourse]) {
        label = @"我要报名";
    }
    else {
        label = @"签到管理";
    }
    
    return label;
}
- (NSString *)statusName {
    NSString *status = @"TODO";
    
    if([self isCourse]) {
        if(!self.traineesStatus || [self.traineesStatus isEqual:[NSNull null]]) {
            status = @"可接受报名";
        }
        else if([self.traineesStatus intValue] < [self.approreLevel intValue]) {
            status = [NSString stringWithFormat:@"审核至%i层(共%i层)", [self.traineesStatus intValue], [self.approreLevel intValue]];
        }
        else if([self.traineesStatus intValue] == [self.approreLevel intValue]) {
            status = @"报名成功";
        }
        // 如果审核级数为0,则提交即报名成功
        else if([self.traineesStatus intValue] == 0) {
            status = @"等待审核";
        }
        else {
            status =  @"unkown error";
        }
    }
    else {
        status = @"未开始";
    }
    
    return status;
}

/**
 *  报名状态不同，显示截止日期不同
 *
 *  @return 截止日期
 */
- (NSString *)availabelTime {
    NSString *label = @"TODO";
    
    if([self isCourse]) {
        if(self.traineesStatus && ![self.traineesStatus isEqual:[NSNull null]] &&
           [self.traineesStatus intValue] == [self.approreLevel intValue]) {
            
            label = [NSString stringWithFormat:@"%@: %@", @"课程开始日期", self.begin];
        }
        else {
            label = [NSString stringWithFormat:@"%@: %@", @"报名截止日期", self.endDate];
        }
    }
    else {
        label = [NSString stringWithFormat:@"%@: %@", @"课程开始日期", self.begin];
    }
    
    return label;
}

+ (NSArray *)loadCourseData:(NSArray *)dataList {
    return [self loadData:dataList type:@"course"];
}
+ (NSArray *)loadSigninData:(NSArray *)dataList {
    return [self loadData:dataList type:@"signin"];
}

+ (NSArray *)loadData:(NSArray *)dataList type:(NSString *)typeName {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for(NSDictionary *dict in dataList) {
        [mutableArray addObject:[[TrainCourse alloc] initData:dict type:typeName]];
    }
    
    return [NSArray arrayWithArray:mutableArray];
}

- (NSString *)desc {
    return [NSString stringWithFormat:@"讲师: %@\n地址: %@\n报名时间:%@ - %@\n培训时间:%@ - %@\n说明:\n%@\n", _lecturer, _location, _startDate, _endDate, _begin, _end, _memo];
}

@end
