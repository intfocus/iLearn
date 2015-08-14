//
//  TrainCourse.m
//  iLearn
//
//  Created by lijunjie on 15/8/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "TrainCourse.h"

@implementation TrainCourse

- (TrainCourse *)initData:(NSDictionary *)dict {
    if(self = [super init]) {
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

+ (NSArray *)loadData:(NSArray *)dataList {
    NSMutableArray *mutableArray = [NSMutableArray array];
    for(NSDictionary *dict in dataList) {
        [mutableArray addObject:[[TrainCourse alloc] initData:dict]];
    }
    
    return [NSArray arrayWithArray:mutableArray];
}

- (NSString *)desc {
    return [NSString stringWithFormat:@"讲师: %@\n地址: %@\n开始时间:%@\n截止时间:%@\n说明:%@\n", _lecturer, _location, _begin, _end, _memo];
}

@end
