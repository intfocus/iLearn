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

@interface SigninUserTableViewController ()
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataList;
@property (nonatomic) ContentTableViewCell *currentCell;

@end

@implementation SigninUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataList = [NSArray array];
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
    cell.labelUserName.text   = dict[@"UserName"];
    cell.labelEmployeeID.text = dict[@"EmployeeID"];

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
    _dataList = [DataHelper signinUsers:NO cid:@"1"];
    [self.tableView reloadData];
}

/**
 *  创建签到
 */
- (void)scanQRCode {
    NSLog(@"Hello create signin");
}
@end
