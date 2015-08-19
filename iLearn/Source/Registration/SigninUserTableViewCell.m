//
//  SigninUserTableViewCell.m
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "SigninUserTableViewCell.h"

@interface SigninUserTableViewCell()
@end

@implementation SigninUserTableViewCell

- (void)awakeFromNib {
    UISwitch *control;
    NSArray *controls = @[_oneSwitch, _twoSwitch, _threeSwitch];
    for(NSInteger i=0; i < [controls count]; i++) {
        control = controls[i];
        control.tag = i;
    }
}

- (void)setChoices:(NSString *)choices {
    NSArray *choosed = [choices componentsSeparatedByString:@","];
    for(UISwitch *control in @[_oneSwitch, _twoSwitch, _threeSwitch]) {
        BOOL isChoosed = [choosed containsObject:[NSString stringWithFormat:@"%li", (long)control.tag]];
        [control setOn:isChoosed];
    }
    _choices = choices;
}
@end
