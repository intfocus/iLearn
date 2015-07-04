//
//  QuestionnaireTableViewCell.h
//  iLearn
//
//  Created by Charlie Hung on 2015/7/4.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentTableViewCell.h"

@interface QuestionnaireTableViewCell : ContentTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *expirationDateLabel;

@end
