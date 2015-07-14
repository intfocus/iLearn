//
//  LectureTableViewCell.m
//  iLearn
//
//  Created by lijunjie on 15/7/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "LectureTableViewCell.h"

@interface LectureTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

@implementation LectureTableViewCell

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
