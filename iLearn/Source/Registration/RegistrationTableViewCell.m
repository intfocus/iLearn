//
//  RegistrationTableViewCell.m
//  iLearn
//
//  Created by lijunjie on 15/8/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "RegistrationTableViewCell.h"

@interface RegistrationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation RegistrationTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_actionButton.layer setCornerRadius:10.0];
}

- (IBAction)actionTouched:(id)sender {
    [super actionTouched];
}

- (IBAction)infoTouched:(id)sender {
    [super infoTouched];
}

@end
