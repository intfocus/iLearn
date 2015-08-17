//
//  SigninFormViewController.m
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "SigninFormViewController.h"

@interface SigninFormViewController ()

@end

@implementation SigninFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title = self.name;
    
    self.descTextView.text = self.name;
    self.descTextView.editable = NO;
    self.removeButton.hidden = NO;
    self.actionButton.hidden = NO;
    
    if(self.isCreated) {
        self.removeButton.hidden = YES;
        [self.actionButton setTitle:@"提交" forState:UIControlStateNormal];
        self.descTextView.editable = YES;
        self.descTextView.text = @"请在此处输入签到名称";
        title = @"创建";
    }
    if(self.isEdit) {
        self.removeButton.hidden = YES;
        [self.actionButton setTitle:@"提交" forState:UIControlStateNormal];
        self.descTextView.editable = YES;
        self.descTextView.text = self.name;
        title = @"编辑";
    }
    self.titleLabel.text = title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)actionTouched:(id)sender {
    if(self.isCreated) {
        [self dismissViewControllerAnimated:NO completion:^{
                if ([self.delegate respondsToSelector:@selector(actionSubmit)]) {
                    [self.delegate actionSubmit];
                }
        }];
    }
    else if(self.isEdit) {
        NSLog(@"put record.");
    }
    else {
        self.removeButton.hidden = YES;
        [self.actionButton setTitle:@"提交" forState:UIControlStateNormal];
        self.descTextView.editable = YES;
        self.titleLabel.text = @"编辑";
        self.isEdit = YES;
    }
}
- (IBAction)removeTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(actionRemove)]) {
            [self.delegate actionRemove];
        }
    }];
}


@end
