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
    
    return self;
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
            status = @"审核中...";
        }
        else if([self.traineesStatus intValue] == [self.approreLevel intValue]) {
            status = @"报名成功";
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
    return [NSString stringWithFormat:@"讲师: %@\n地址: %@\n开始时间:%@\n截止时间:%@\n说明:%@\n", _lecturer, _location, _begin, _end, _memo];
}

@end
