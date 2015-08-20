//
//  SigninUserTableVIewController.m
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "SigninUserTableViewController.h"
#import <MBProgressHUD.h>
#import "SigninUserTableViewCell.h"
#import "ListViewController.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "DataHelper.h"
#import "FileUtils.h"
#import "const.h"
#import "CourseSignin.h"
#import "User.h"

@interface SigninUserTableViewController ()
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) NSMutableArray *stateList;
@property (strong, nonatomic) NSString *courseID;
@property (strong, nonatomic) NSString *signinID;
@property (nonatomic) ContentTableViewCell *currentCell;

@end

@implementation SigninUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataList = [NSArray array];
    _stateList = [NSMutableArray array];
    
    NSDictionary *dict = [FileUtils shareData:@"signin-users"];
    _courseID = dict[@"tid"];
    _signinID = dict[@"ciid"];
    self.listViewController.centerLabel.text = dict[@"name"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self syncData];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SigninUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SigninUserTableViewCell"];
    cell.delegate = self;
    
    NSDictionary *dict = _dataList[indexPath.row];
    cell.employeeName  = dict[@"UserName"];
    cell.employeeID    = dict[@"EmployeeId"];
    cell.courseID      = self.courseID;
    cell.signinID      = self.signinID;
    
    if(self.stateList && [self.stateList count] > 0) {
        CourseSignin *courseSignin;
        for(NSInteger i=0; i < [self.stateList count]; i++) {
            courseSignin = [[CourseSignin alloc] initLocalData:self.stateList[i]];
            if([courseSignin.employeeID isEqualToString:dict[@"EmployeeId"]]) {
                cell.choices = courseSignin.choices;

                [self.stateList removeObjectAtIndex:i];
                break;
            }
        }
    }
 
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell {
    self.currentCell = cell;
    NSLog(@"didSelectInfoButtonOfCell");
}

- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell {
    NSLog(@"didSelectActionButtonOfCell");
}

- (IBAction)actionBack:(id)sender {
    self.listViewController.listType = ListViewTypeSigninAdmin;
    [self.listViewController refreshContentView];
}

- (void)didSelectQRCodeButtonOfCell:(ContentTableViewCell*)cell {
    NSLog(@"didSelectQRCodeButtonOfCell");
}


#pragma mark - ConnectionManagerDelegate

- (void)connectionManagerDidDownloadCourse:(NSString *)courseID Ext:(NSString *)extName withError:(NSError *)error {
    [_progressHUD hide:YES];
}
- (void)connectionManagerDidDownloadExamsForUser:(NSString *)userId withError:(NSError *)error {
    [_progressHUD hide:YES];
}

- (void)connectionManagerDidDownloadExam:(NSString *)examId withError:(NSError *)error {
    [_progressHUD hide:YES];
}

- (void)connectionManagerDidUploadExamResult:(NSString *)examId withError:(NSError *)error {
    [_progressHUD hide:YES];
}

- (void)connectionManagerDidUploadExamScannedResult:(NSString *)result withError:(NSError *)error {
    [_progressHUD hide:YES];
}

- (void)syncData {
    NSDictionary *dict = [DataHelper trainSigninUsers:NO tid:self.courseID];
    _dataList = (NSArray *)psd(dict[@"traineesdata"], @[]);
    NSArray *array = [DataHelper trainSigninScannedUsers:NO courseID:self.courseID signinID:self.signinID];
    _stateList = [NSMutableArray arrayWithArray:array];
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([HttpUtils isNetworkAvailable]) {
            NSDictionary *dict = [DataHelper trainSigninUsers:YES tid:self.courseID];
            _dataList = (NSArray *)psd(dict[@"traineesdata"], @[]);
            
            [CourseSignin postToServer:self.courseID signinID:self.signinID createrID:[User userID]];
            NSArray *array = [DataHelper trainSigninScannedUsers:YES courseID:self.courseID signinID:self.signinID];
            _stateList = [NSMutableArray arrayWithArray:array];
            
            [self.tableView reloadData];
        }
        [_progressHUD hide:YES];
    });
}

@end
