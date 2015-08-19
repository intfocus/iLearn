//
//  CourseSignin.m
//  iLearn
//
//  Created by lijunjie on 15/8/19.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CourseSignin.h"
#import "FileUtils.h"
#import "const.h"

@implementation CourseSignin

- (CourseSignin *)initServerData:(NSDictionary *)dict {
    if(self = [super init]) {
        _courseID  = dict[@"TrainingId"];
        _signinID  = dict[@"CheckInId"];
        _userID    = dict[@"UserId"];
        _createAt  = dict[@"IssueDate"];
        _createrID = dict[@"CreatedUser"];
        _choices   = dict[@"Reason"];
        _isUpload  = ([dict[@"Status"] intValue] > 0);
    }
    
    return self;
}

- (CourseSignin *)initLocalData:(NSDictionary *)dict {
    if(self = [super init]) {
        _courseID  = dict[@"CourseID"];
        _signinID  = dict[@"CheckInId"];
        _userID    = dict[@"UserId"];
        _createAt  = dict[@"IssueDate"];
        _createrID = dict[@"CreatedUser"];
        _choices   = dict[@"Reason"];
        _isUpload  = ([dict[@"Status"] intValue] > 0);
    }
    //@{@"EmployeeId": employeeID, @"Choices": self.choices, @"IsUpload": @NO, @"CreatedAt":createdAt}
    return self;
}


- (NSString *)scannedFileName {
    return [NSString stringWithFormat:@"%@-%@.scanned", _courseID, _signinID];
}

- (NSString *)scannedFilePath {
    return [FileUtils dirPath:CACHE_DIRNAME FileName:[self scannedFileName]];
}

- (NSString *)findChoices:(NSString *)employeeID employeeID:(NSString *)employeeID{
    NSString *scannedFilePath = [self scannedFilePath];
    NSString *choices = @"";
    if([FileUtils checkFileExist:scannedFilePath isDir:NO]) {
        NSMutableDictionary *scannedList = [FileUtils readConfigFile:scannedFilePath][@"Data"];
        for(NSDictionary *dict in scannedList) {
            if([dict[@"EmployeeId"] isEqualToString:employeeID]) {
                choices = dict[@"Choices"];

                break;
            }
        }
    }
    return choices;
}
@end
