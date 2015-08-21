//
//  TrainCourseScannForm.h
//  iLearn
//
//  Created by lijunjie on 15/8/18.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SigninAdminTableViewController;

@interface CourseSigninScanForm : UIViewController

@property (strong, nonatomic) NSDictionary *courseSignin;
@property (strong, nonatomic) NSDictionary *employee;
@property (strong, nonatomic) NSString *choices;
@property (strong, nonatomic) SigninAdminTableViewController *masterViewController;

@end
