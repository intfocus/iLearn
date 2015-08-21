//
//  SigninUserTableViewCell.h
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "ContentTableViewCell.h"

@interface SigninUserTableViewCell : ContentTableViewCell

@property (strong, nonatomic) NSString *employeeID;
@property (strong, nonatomic) NSString *employeeName;
@property (strong, nonatomic) NSString *courseID;
@property (strong, nonatomic) NSString *signinID;
//@property (strong, nonatomic) NSString *userID; // 签到创建者ID

@property (strong, nonatomic) NSString *choices;

@end
