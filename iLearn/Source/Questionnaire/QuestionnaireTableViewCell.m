//
//  QuestionnaireTableViewCell.m
//  iLearn
//
//  Created by Charlie Hung on 2015/7/4.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "QuestionnaireTableViewCell.h"

@interface QuestionnaireTableViewCell ()

@end

@implementation QuestionnaireTableViewCell

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
