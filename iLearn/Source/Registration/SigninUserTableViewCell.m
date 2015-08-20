//
//  SigninUserTableViewCell.m
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "SigninUserTableViewCell.h"
#import "CourseSignin.h"

@interface SigninUserTableViewCell()
@property (nonatomic, weak) IBOutlet UILabel *labelEmployeeName;
@property (nonatomic, weak) IBOutlet UILabel *labelEmployeeID;
@property (nonatomic, weak) IBOutlet UISwitch *oneSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *twoSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *threeSwitch;
@end

@implementation SigninUserTableViewCell

- (void)awakeFromNib {
    UISwitch *control;
    NSArray *controls = @[_oneSwitch, _twoSwitch, _threeSwitch];
    for(NSInteger i=0; i < [controls count]; i++) {
        control = controls[i];
        control.tag = i;
        [control addTarget:self action:@selector(actionSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark - rewrite setter
- (void)setChoices:(NSString *)choices {
    NSArray *choosed = [choices componentsSeparatedByString:@","];
    for(UISwitch *control in @[_oneSwitch, _twoSwitch, _threeSwitch]) {
        BOOL isChoosed = [choosed containsObject:[NSString stringWithFormat:@"%li", (long)control.tag]];
        [control setOn:isChoosed];
    }
    _choices = choices;
}

- (void)setEmployeeID:(NSString *)employeeID {
    self.labelEmployeeID.text = employeeID;
    
    _employeeID = employeeID;
}

- (void)setEmployeeName:(NSString *)employeeName {
    self.labelEmployeeName.text = employeeName;
    
    _employeeName = employeeName;
}

#pragma mark - control methods

- (IBAction)actionSwitchValueChanged:(UISwitch *)sender {
    NSMutableArray *choosed = [NSMutableArray arrayWithArray:[self.choices componentsSeparatedByString:@","]];
    if([sender isOn]) {
        [choosed addObject:[NSString stringWithFormat:@"%li", (long)sender.tag]];
    }
    else {
        [choosed removeObject:[NSString stringWithFormat:@"%li", (long)sender.tag]];
    }
    self.choices = [choosed componentsJoinedByString:@","];
    
    [CourseSignin saveToLocal:self.employeeID choices:self.choices courseID:self.courseID signinID:self.signinID];
}
@end
