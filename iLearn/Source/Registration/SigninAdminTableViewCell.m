//
//  SigninAdminTableViewCell.m
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "SigninAdminTableViewCell.h"

@interface SigninAdminTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation SigninAdminTableViewCell

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

- (IBAction)qrCodeTouched:(id)sender {
    [super qrCodeTouched];
}
@end
