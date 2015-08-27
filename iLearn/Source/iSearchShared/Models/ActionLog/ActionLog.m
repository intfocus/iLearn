//
//  ActionLog.m
//  iSearch
//
//  Created by lijunjie on 15/7/6.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionLog.h"

#import "const.h"
#import "DataHelper.h"
#import "DatabaseUtils+ActionLog.h"
#import "ExtendNSLogFunctionality.h"

@interface ActionLog()
@property (nonatomic, strong) DatabaseUtils *databaseUtils;
@end

@implementation ActionLog
- (ActionLog *)init {
    if(self = [super init]) {
        _databaseUtils = [[DatabaseUtils alloc] init];
    }
    return self;
}

- (void)syncRecords {
    NSMutableArray *unSyncRecords = [self.databaseUtils records:YES];
    NSMutableArray *IDS = [DataHelper actionLog:unSyncRecords];
    [self.databaseUtils updateSyncedRecords:IDS];
}

+ (void)syncRecords {
    [[[ActionLog alloc] init] syncRecords];
}

- (int)trainNum {
    return [self.databaseUtils dashboardInfo:@"培训报名"];
}
- (int)examNum {
    return ([self.databaseUtils dashboardInfo:@"练习考试"] + [self.databaseUtils dashboardInfo:@"正式考试"]);
}
- (int)questionNum {
    return ([self.databaseUtils dashboardInfo:@"练习问卷"] + [self.databaseUtils dashboardInfo:@"正式问卷"]);
}
- (int)learnNum {
    return ([self.databaseUtils dashboardInfo:@"练习考试"] + [self.databaseUtils dashboardInfo:@"课件学习"] + [self.databaseUtils dashboardInfo:@"练习问卷"]);
}
@end