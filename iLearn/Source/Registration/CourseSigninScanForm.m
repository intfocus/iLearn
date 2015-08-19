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

typedef NS_ENUM(NSInteger, CourseSigninType) {
    CourseSigninTypeSignin = 0,
    CourseSigninTypeArriveLate = 1,
    CourseSigninTypeLeaveEarly = 2
};
@interface CourseSigninScanForm ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *employeeLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UISwitch *oneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twoSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *threeSwitch;

@property (strong, nonatomic) NSString *scannedFilePath;

@end

@implementation CourseSigninScanForm

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwitch *control;
    NSArray *controls = @[_oneSwitch, _twoSwitch, _threeSwitch];
    for(NSInteger i=0; i < [controls count]; i++) {
        control = controls[i];
        control.tag = i;
    }
    NSString *scannedFileName = [NSString stringWithFormat:@"%@-%@.scanned", self.courseSignin[@"TrainingId"], self.courseSignin[@"Id"]];
    _scannedFilePath = [FileUtils dirPath:CACHE_DIRNAME FileName:scannedFileName];
    if([FileUtils checkFileExist:self.scannedFilePath isDir:NO]) {
        NSMutableDictionary *scannedList = [FileUtils readConfigFile:self.scannedFilePath][@"Data"];
        for(NSDictionary *dict in scannedList) {
            if([dict[@"EmployeeId"] isEqualToString:self.employee[@"EmployeeId"]]) {
                _choices = dict[@"Choices"];
                
                if(self.choices && [self.choices length] > 0) {
                    NSArray *choosed = [self.choices componentsSeparatedByString:@","];
                    for(control in controls) {
                        BOOL isChoosed = [choosed containsObject:[NSString stringWithFormat:@"%li", (long)control.tag]];
                        [control setOn:isChoosed];
                    }
                }
                break;
            }
        }
    }
    [self.oneSwitch addTarget:self action:@selector(actionSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.twoSwitch addTarget:self action:@selector(actionSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.threeSwitch addTarget:self action:@selector(actionSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
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

- (void)actionSwitchValueChanged:(UISwitch *)sender {
    NSMutableArray *choosed = [NSMutableArray arrayWithArray:[self.choices componentsSeparatedByString:@","]];
    if([sender isOn]) {
        [choosed addObject:[NSString stringWithFormat:@"%li", (long)sender.tag]];
    }
    else {
        [choosed removeObject:[NSString stringWithFormat:@"%li", (long)sender.tag]];
    }
    self.choices = [choosed componentsJoinedByString:@","];
}

- (void)saveToLocal {
    NSMutableDictionary *scannedList = [NSMutableDictionary dictionary];
    NSString *employeeID = self.employee[@"EmployeeId"];
    NSString *createdAt = [DateUtils dateToStr:[NSDate date] Format:DATE_FORMAT];
    
    if([FileUtils checkFileExist:self.scannedFilePath isDir:NO]) {
        scannedList = [FileUtils readConfigFile:self.scannedFilePath];
        
        BOOL isExist = NO;
        NSMutableDictionary *temp = [NSMutableDictionary dictionary];
        for(NSInteger i=0; i < [scannedList[@"Data"] count]; i++) {
            temp = scannedList[@"Data"][i];
            if([temp[@"EmployeeId"] isEqualToString:employeeID]) {
                isExist            = YES;
                temp[@"Choices"]   = self.choices;
                temp[@"IsUpload"]  = @NO;
                temp[@"CreatedAt"] = createdAt;
                scannedList[@"Data"][i] = temp;
                break;
            }
        }
        if(!isExist) {
            [scannedList[@"Data"] addObject:@{@"EmployeeId": employeeID, @"Choices": self.choices, @"IsUpload": @NO, @"CreatedAt":createdAt}];
        }
        
    }
    else {
        scannedList[@"CourseId"] = self.courseSignin[@"TrainingId"];
        scannedList[@"SigninId"] = self.courseSignin[@"Id"];
        scannedList[@"Data"] = @[@{@"EmployeeId": employeeID, @"Choices": self.choices, @"IsUpload": @NO, @"CreatedAt":createdAt}];
    }
    [FileUtils writeJSON:scannedList Into:self.scannedFilePath];
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
    if(![FileUtils checkFileExist:self.scannedFilePath isDir:NO]) {
        return;
    }
    
    NSString *employeeID = self.employee[@"EmployeeId"];
    NSMutableDictionary *scannedList = [FileUtils readConfigFile:self.scannedFilePath];
    
    BOOL isChanged = NO;
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    for(NSInteger i=0; i < [scannedList[@"Data"] count]; i++) {
        temp = scannedList[@"Data"][i];
        if([temp[@"EmployeeId"] isEqualToString:employeeID]) {
            if(![temp[@"IsUpload"] boolValue]) {
                temp[@"IsUpload"]       = @YES;
                scannedList[@"Data"][i] = temp;
                
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                params[@"TrainingId"]  = scannedList[@"CourseId"];
                params[@"CheckInId"]   = scannedList[@"SigninId"];
                params[@"CreatedUser"] = [User userID];
                params[@"Status"]      = @"1";
                params[@"Reason"]      = temp[@"Choices"];
                params[@"IssueDate"]   = temp[@"CreatedAt"];
                params[@"UserId"]      = self.courseSignin[@"UserId"];
                
                HttpResponse *response = [ApiHelper courseSigninUser:params];
                isChanged = ([response.statusCode intValue] == 200);
            }
            break;
        }
    }
    if(isChanged) {
        [FileUtils writeJSON:scannedList Into:self.scannedFilePath];
    }

}
#pragma mark - rewrite setter

- (void)setEmployee:(NSDictionary *)employee {
    self.nameLabel.text     = [NSString stringWithFormat:@"%@", employee[@"UserName"]];// make sure display "(null)" when nil
    self.employeeLabel.text = [NSString stringWithFormat:@"%@", employee[@"EmployeeId"]];
    
    _employee = employee;
}

@end
