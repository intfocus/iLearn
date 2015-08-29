//
//  SigninFormViewController.m
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "SigninFormViewController.h"
#import "ApiHelper.h"
#import "HttpResponse.h"
#import "User.h"
#import <MBProgressHUD.h>
#import <SCLAlertView.h>
#import "ViewUtils.h"

typedef NS_ENUM(NSInteger, TrainSigninFormState) {
    TrainSigninFormCreate = 0,
    TrainSigninFormEdit   = 1,
    TrainSigninFormDelete = -1
};
@interface SigninFormViewController ()
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation SigninFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *title = @"签到明细";
    
    if(self.trainSignin[@"Name"]) {
        self.nameTextField.text = self.trainSignin[@"Name"];
    }
    self.nameTextField.enabled = NO;
    self.removeButton.hidden = NO;
    self.actionButton.hidden = NO;
    
    if(self.isCreated) {
        self.removeButton.hidden = YES;
        [self.actionButton setTitle:@"提交" forState:UIControlStateNormal];
        self.nameTextField.enabled = YES;
        self.nameTextField.placeholder = @"请输入签到名称";
        title = @"创建签到";
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

/**
 *{
 *    UserId: "8",//创建用户
 *    CheckInName: "ccssdd",//签到名称
 *    CheckInId: "5",//签到ID，修改和删除时生效
 *    Status: "-1"，//状态（0：新增，1：修改，-1：删除）
 *    TrainingId: "1"//课程编号g
 *}
 *
 */
- (IBAction)actionTouched:(id)sender {
    if(self.isEdit || self.isCreated) {
        NSString *input = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([input length] > 0) {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.progressHUD.labelText = @"提交中...";
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        }
        else {
            [ViewUtils showPopupView:self.view Info:@"请输入签到名称！"];
            return;
        }
    }
    
    if(self.isCreated) {
        [self postForm:TrainSigninFormCreate id:@""];
        [self.progressHUD hide:YES];
        
        if ([self.delegate respondsToSelector:@selector(actionSubmit)]) {
            [self.delegate actionSubmit];
        }
        [self dismissViewControllerAnimated:NO completion:^{}];
    }
    else if(self.isEdit) {
        [self postForm:TrainSigninFormEdit id:self.trainSignin[@"Id"]];
        [self.progressHUD hide:YES];
        
        if ([self.delegate respondsToSelector:@selector(actionEdit)]) {
            [self.delegate actionEdit];
        }
        [self dismissViewControllerAnimated:NO completion:^{}];
    }
    else {
        [self.actionButton setTitle:@"提交" forState:UIControlStateNormal];
        [self.removeButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.removeButton setBackgroundColor:[UIColor lightGrayColor]];
        self.nameTextField.enabled = YES;
        self.titleLabel.text       = @"编辑签到";
        self.isEdit                = YES;
    }
}
- (IBAction)removeTouched:(id)sender {
    if(self.isEdit) {
        self.isEdit    = NO;
        self.isCreated = NO;
        [self.removeButton setTitle:@"删除" forState:UIControlStateNormal];
        [self.removeButton setBackgroundColor:[UIColor redColor]];
        [self.actionButton setTitle:@"编辑" forState:UIControlStateNormal];
        self.titleLabel.text       = @"签到明细";
    }
    else {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        [alert addButton:@"确认" actionBlock:^(void) {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.progressHUD.labelText = @"删除中...";
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
            
            [self postForm:TrainSigninFormDelete id:self.trainSignin[@"Id"]];
            
            [self.progressHUD hide:YES];
            if ([self.delegate respondsToSelector:@selector(actionRemove)]) {
                [self.delegate actionRemove];
            }
            [self dismissViewControllerAnimated:NO completion:^{}];
        }];
        
        [alert showError:self title:@"确认删除" subTitle:self.trainSignin[@"Name"] closeButtonTitle:@"取消" duration:0.0f];
    }
}

- (void)postForm:(NSInteger)postType id:(NSString *)ID {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"UserId"]      = [User userID];
    params[@"CheckInName"] = self.nameTextField.text;
    params[@"CheckInId"]   = ID;
    params[@"Status"]      = [NSNumber numberWithInteger:postType];
    params[@"TrainingId"]  = self.trainCourse.ID;
    HttpResponse *response = [ApiHelper courseSignin:params];
    
    if([response.errors count]) {
        self.progressHUD.labelText = [response.errors componentsJoinedByString:@"\n"];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        [NSThread sleepForTimeInterval:3.0];
    }
    else {
        self.progressHUD.labelText = @"提交成功";
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        [NSThread sleepForTimeInterval:1.0];
    }
}


@end
