//
//  QuestionnaireCell.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "QuestionnaireCell.h"

@interface QuestionnaireCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation QuestionnaireCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_actionButton.layer setCornerRadius:10.0];
    [_qrCodeButton.layer setCornerRadius:10.0];
}

- (IBAction)actionTouched:(id)sender {
    [super actionTouched];
}

- (IBAction)infoTouched:(id)sender {
    [super infoTouched];
}

- (IBAction)qrCodeTouched:(id)sender {
    [super qrCodeTouched];
}

@end
