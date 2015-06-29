//
//  PasswordViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/6/11.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *descString;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) void (^callback)(void);

@end
