//
//  SigninUserTableViewCell.h
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "ContentTableViewCell.h"

@interface SigninUserTableViewCell : ContentTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *labelUserName;
@property (nonatomic, weak) IBOutlet UILabel *labelEmployeeID;
@property (nonatomic, weak) IBOutlet UISwitch *switchOne;
@property (nonatomic, weak) IBOutlet UISwitch *switchTwo;
@property (nonatomic, weak) IBOutlet UISwitch *switchThree;

@end
