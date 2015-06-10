//
//  PasswordViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/6/11.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "PasswordViewController.h"
#import "Constants.h"

@interface PasswordViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *textFieldLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewCenterYConstraint;

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.actionButton.layer setCornerRadius:10.0];

    [self.contentView.layer setBorderWidth:1.0];

    UIColor *borderColor = RGBCOLOR(190.0, 190.0, 190.0);
    [self.contentView.layer setBorderColor:borderColor.CGColor];

    self.titleLabel.text = _titleString;
    self.descLabel.text = _descString;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)actionTouched:(id)sender {

    NSString *inputPassword = _passwordTextField.text;
    if ([inputPassword isEqualToString:_password]) {
        [self dismissViewControllerAnimated:NO completion:^{
            self.callback();
        }];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    _contentViewCenterYConstraint.constant = 100;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _contentViewCenterYConstraint.constant = 0;
    [_passwordTextField resignFirstResponder];
}

@end
