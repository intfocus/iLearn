//
//  ContentTableViewCell.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ContentTableViewCell.h"

@implementation ContentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)actionTouched
{
    if ([self.delegate respondsToSelector:@selector(didSelectActionButtonOfCell:)]) {

        [self.delegate didSelectActionButtonOfCell:self];
    }
}

- (void)infoTouched
{
    if ([self.delegate respondsToSelector:@selector(didSelectInfoButtonOfCell:)]) {

        [self.delegate didSelectInfoButtonOfCell:self];
    }
}

- (void)qrCodeTouched
{
    if ([self.delegate respondsToSelector:@selector(didSelectQRCodeButtonOfCell:)]) {

        [self.delegate didSelectQRCodeButtonOfCell:self];
    }
}

@end
