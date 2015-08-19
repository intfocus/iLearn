//
//  Url.m
//  iSearch
//
//  Created by lijunjie on 15/7/10.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "Url.h"
#import "const.h"

@implementation Url

- (Url *)init {
    if(self = [super init]) {
        _base                 = BASE_URL;
        _login                = [self concate:LOGIN_URL_PATH];
        _notifications        = [self concate:NOTIFICATION_URL_PATH];
        _actionLog            = [self concate:ACTION_LOGGER_URL_PATH];
        _coursePackages       = [self concate:COURSE_PACKAGES_URL_PATH];
        _coursePackageContent = [self concate:COURSE_PACKAGE_CONTENT_URL_PATH];
        _downloadCourse       = [self concate:COURSE_DOWNLOAD_URL_PATH];

        _trainCourses            = @"http://tsa-china.takeda.com.cn/uat/api/Trainings_Api.php";
        _courseSignup             = @"http://tsa-china.takeda.com.cn/uat/api/Trainee_Api.php";
        _courseSignins            = @"http://tsa-china.takeda.com.cn/uat/api/CheckInList_Api.php";
        _courseSignin             = @"http://tsa-china.takeda.com.cn/uat/api/CheckIn_Api.php";
        _courseSigninUsers        = @"http://tsa-china.takeda.com.cn/uat/api/RollCallUserList_Api.php";
        _courseSigninScannedUsers = @"http://tsa-china.takeda.com.cn/uat/api/RollCallOldList_Api.php";
        _courseSigninUser         = @"http://tsa-china.takeda.com.cn/uat/api/RollCall_Api.php";
    }
    return self;
}

#pragma mark - asisstant methods
- (NSString *)concate:(NSString *)path {
    NSString *splitStr  = ([path hasPrefix:@"/"] ? @"" : @"/");
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@%@", BASE_URL, BASE_PATH, splitStr, path];
    return  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
