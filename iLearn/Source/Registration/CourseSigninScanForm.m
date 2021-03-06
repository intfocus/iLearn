//
//  TrainCourseScannForm.m
//  iLearn
//
//  Created by lijunjie on 15/8/18.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "CourseSigninScanForm.h"
#import "FileUtils.h"
#import "const.h"
#import "SigninAdminTableViewController.h"
#import "ApiHelper.h"
#import "User.h"
#import "DateUtils.h"
#import "HttpResponse.h"
#import "HttpUtils.h"
#import "CourseSignin.h"
#import "ExtendNSLogFunctionality.h"


@interface CourseSigninScanForm ()
@property (weak, nonatomic) IBOutlet UILabel *employeeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *employeeIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UISwitch *oneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *threeSwitch;

@property (strong, nonatomic) NSString *courseID;
@property (strong, nonatomic) NSString *signinID;
@property (strong, nonatomic) NSString *employeeID;

@end

@implementation CourseSigninScanForm

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _courseID   = self.courseSignin[@"TrainingId"];
    _signinID   = self.courseSignin[@"Id"];
    _employeeID = self.employee[@"EmployeeId"];
    
    UISwitch *control;
    NSArray *controls = @[_oneSwitch, _twoSwitch, _threeSwitch];
    for(NSInteger i=0; i < [controls count]; i++) {
        control = controls[i];
        control.tag = i;
        [control addTarget:self action:@selector(actionSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    self.choices = [CourseSignin findChoices:self.employeeID
                                    courseID:self.courseID
                                    signinID:self.signinID];
    // 默认[签到]
    if([self.choices length] == 0) {
        self.choices = @"0";
    }
    
    NSArray *choosed = [self.choices componentsSeparatedByString:@","];
    
    for(control in controls) {
        BOOL isChoosed = [choosed containsObject:[NSString stringWithFormat:@"%li", (long)control.tag]];
        [control setOn:isChoosed];
    }
    
    self.employeeNameLabel.text = [NSString stringWithFormat:@"%@", self.employee[@"UserName"]];// make sure display "(null)" when nil
    self.employeeIDLabel.text   = [NSString stringWithFormat:@"%@", self.employee[@"EmployeeId"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionContinue:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        [self saveToLocal];
        if([HttpUtils isNetworkAvailable]) {
            [self postToServer];
        }
        
        [self.masterViewController setupQRCodeReader];
    }];
}

- (IBAction)actionTimer:(id)sender {
}

- (IBAction)actionDismiss:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        [self saveToLocal];
        if([HttpUtils isNetworkAvailable]) {
            [self postToServer];
        }
    }];
}
/**
 *  [签到][迟到][早退]的逻辑关系；
 *  [迟到]/[早退] => [签到]
 *  取消[签到] => 取消[迟到][早退]
 *
 *  @param sender UISwitch
 */
- (IBAction)actionSwitchValueChanged:(UISwitch *)sender {
    NSMutableArray *choosed = [NSMutableArray arrayWithArray:[self.choices componentsSeparatedByString:@","]];
    if([sender isOn]) {
        [choosed addObject:[NSString stringWithFormat:@"%li", (long)sender.tag]];
        
        //  [迟到]/[早退] => [签到]
        if((sender.tag == CourseSigninTypeArriveLate || sender.tag == CourseSigninTypeLeaveEarly) &&
            ![choosed containsObject:[NSString stringWithFormat:@"%li", (long)CourseSigninTypeSignin]]) {
            
            [self.oneSwitch setOn:YES];
            [choosed addObject:[NSString stringWithFormat:@"%li", (long)CourseSigninTypeSignin]];
        }
    }
    else {
        [choosed removeObject:[NSString stringWithFormat:@"%li", (long)sender.tag]];
        
        // 取消[签到] => 取消[迟到][早退]
        if(sender.tag == CourseSigninTypeSignin) {
            [self.twoSwitch setOn:NO];
            [self.threeSwitch setOn:NO];
            [choosed removeObject:[NSString stringWithFormat:@"%li", (long)CourseSigninTypeArriveLate]];
            [choosed removeObject:[NSString stringWithFormat:@"%li", (long)CourseSigninTypeLeaveEarly]];
        }
    }
    
    for(NSInteger i= [choosed count]-1; i >= 0; i--) {
        if([choosed[i] length] == 0) {
            [choosed removeObjectAtIndex:i];
        }
    }
    self.choices = [choosed componentsJoinedByString:@","];
}

- (void)saveToLocal {
    [CourseSignin saveToLocal:self.employeeID
                      choices:self.choices
                     courseID:self.courseID
                     signinID:self.signinID];
}
/**
 *  培训班签到点名
 *
 * {
 *     TrainingId: "1",
 *     UserId: "2",
 *     IssueDate: "2015/07/18 14:33:43",
 *     Status: "1",
 *     Reason: "等快递快递收到伐",
 *     CreatedUser: "1",
 *     CheckInId: "1"
 * }
 *
 */
- (void)postToServer {
    NSString *createrID = [User userID];
    //NSString *userID = self.courseSignin[@"UserId"];
    
    [CourseSignin postToServer:self.courseID
                      signinID:self.signinID
                     createrID:createrID];
    
}
@end
