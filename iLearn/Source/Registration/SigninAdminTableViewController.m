//
//  SigninAdminTableViewController.m
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "SigninAdminTableViewController.h"
#import "ListViewController.h"
#import <MBProgressHUD.h>
#import "SigninAdminTableViewCell.h"
#import "DetailViewController.h"
#import "SigninFormViewController.h"
#import "CourseSigninScanForm.h"
#import "UIImage+MDQRCode.h"
#import "TrainCourse.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "DataHelper.h"
#import "FileUtils.h"

static const NSInteger kMinScanInterval = 3;
static NSString *const kCourseSigninCRUDFormIdentifier = @"CourseSigninCRUDForm";
static NSString *const kCourseSigninScanFormIdentifier = @"CourseSigninScanForm";


@interface SigninAdminTableViewController ()
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataList;
@property (nonatomic) ContentTableViewCell *currentCell;
@property (strong, nonatomic) NSString *lastScannedResult;
@property (assign, nonatomic) long long lastScanDate;
@property (strong, nonatomic) TrainCourse *trainCourse;
@property (strong, nonatomic) NSDictionary *currentCourseSignin;
@property (strong, nonatomic) NSArray *CourseSigninEmployees;
@end

@implementation SigninAdminTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataList = [NSArray array];
    _currentCourseSignin = [NSDictionary dictionary];
    _CourseSigninEmployees = [NSArray array];
    
    _trainCourse = [[TrainCourse alloc] initCourseData:[FileUtils shareData:@"train"]];
    self.listViewController.centerLabel.text = self.trainCourse.name;
    
    [self syncData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    SigninAdminTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SigninAdminTableViewCell"];
    cell.delegate = self;
    
    NSDictionary *dict = _dataList[indexPath.row];
    cell.titleLabel.text = dict[@"Name"];
    cell.statusLabel.text = [NSString stringWithFormat:@"%@ (%@)", dict[@"UserName"], dict[@"EmployeeId"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kCourseSigninCRUDFormIdentifier]) {
        SigninFormViewController *formVC = (SigninFormViewController*)segue.destinationViewController;
        formVC.delegate    = self;
        formVC.isCreated   = [sender boolValue];
        formVC.trainCourse = self.trainCourse;
        formVC.trainSignin = self.currentCourseSignin;
    }
    else if([segue.identifier isEqualToString:kCourseSigninScanFormIdentifier]) {
        CourseSigninScanForm *formVC = (CourseSigninScanForm*)segue.destinationViewController;
        formVC.employee = sender;
        formVC.courseSignin = self.currentCourseSignin;
        formVC.masterViewController = self;
    }
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.currentCourseSignin = [self.dataList objectAtIndex:[indexPath row]];
    
    if(self.currentCourseSignin[@"Id"]) {
        [self performSegueWithIdentifier:kCourseSigninCRUDFormIdentifier sender:@NO];
    }
    else {
        [ViewUtils showPopupView:self.listViewController.view Info:@"缺少签到ID，请联系管理员"];
    }
}

- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *content  = [self.dataList objectAtIndex:[indexPath row]];
    
    NSDictionary *dict = @{@"tid": self.trainCourse.ID, @"ciid": content[@"Id"], @"name": content[@"Name"]};
    [FileUtils shareData:dict fileName:@"signin-users"];
    
    self.listViewController.listType = ListViewTypeSigninUser;
    [self.listViewController refreshContentView];
}

- (void)didSelectQRCodeButtonOfCell:(ContentTableViewCell*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.currentCourseSignin = [self.dataList objectAtIndex:[indexPath row]];
    
    [self setupQRCodeReader];
}

- (IBAction)actionBack:(id)sender {
    self.listViewController.listType = ListViewTypeRegistration;
    [self.listViewController refreshContentView];
}

- (void)setupQRCodeReader {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *reader = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            reader = [[QRCodeReaderViewController alloc] initWithCancelButtonTitle:NSLocalizedString(@"COMMON_CLOSE", nil)];
            reader.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        reader.delegate = self;
        
        [self presentViewController:reader animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}
#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    NSDate *now = [NSDate date];
    NSTimeInterval nowInterval = [now timeIntervalSince1970];
    
    if (nowInterval - _lastScanDate < kMinScanInterval) {
        return;
    }
    _lastScanDate = nowInterval;
    

    if(result) {
        NSDictionary *scannedEmployee = nil;
        for(NSDictionary *dict in self.CourseSigninEmployees) {
            if([dict[@"EmployeeId"] isEqualToString:result]) {
                scannedEmployee = dict;
                break;
            }
        }
        
        if(scannedEmployee) {
            [self dismissViewControllerAnimated:YES completion:^{
                [self performSegueWithIdentifier:kCourseSigninScanFormIdentifier sender:scannedEmployee];
            }];
        }
        else {
            NSString *message = [NSString stringWithFormat:@"员工(%@)不在报名列表中！", result];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        [ViewUtils showPopupView:self.listViewController.view Info:@"nothing"];
    }
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ConnectionManagerDelegate

- (void)connectionManagerDidDownloadCourse:(NSString *)courseID Ext:(NSString *)extName withError:(NSError *)error {}
- (void)connectionManagerDidDownloadExamsForUser:(NSString *)userId withError:(NSError *)error {}
- (void)connectionManagerDidDownloadExam:(NSString *)examId withError:(NSError *)error {}
- (void)connectionManagerDidUploadExamResult:(NSString *)examId withError:(NSError *)error {}
- (void)connectionManagerDidUploadExamScannedResult:(NSString *)result withError:(NSError *)error {}

- (void)syncData {
    [self syncDataWithDownloadEmployeeList:YES];
}

- (void)syncDataWithDownloadEmployeeList:(BOOL)yeath {
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    
    if(yeath) {
        self.progressHUD.labelText = @"下载报名员工列表";
        NSDictionary *dict = [DataHelper trainSigninUsers:YES tid:self.trainCourse.ID];
        _CourseSigninEmployees = dict[@"traineesdata"];
    }
    
    self.progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
    _dataList = [DataHelper trainSingins:[HttpUtils isNetworkAvailable] tid:self.trainCourse.ID];
    [self.tableView reloadData];
    [self.progressHUD hide:YES];
    

    if(yeath && (!self.CourseSigninEmployees || [self.CourseSigninEmployees count] == 0)) {
        [ViewUtils showPopupView:self.listViewController.view Info:@"温馨提示: 培训班员工列表为空！"];
    }
}

/**
 *  创建签到
 */
- (void)scanQRCode {
    self.currentCourseSignin = [NSDictionary dictionary];
    [self performSegueWithIdentifier:kCourseSigninCRUDFormIdentifier sender:@YES];
}

- (void)actionEdit {
    [self syncDataWithDownloadEmployeeList:NO];

}
- (void)actionSubmit {
    [self syncDataWithDownloadEmployeeList:NO];

}
- (void)actionRemove {
    [self syncDataWithDownloadEmployeeList:NO];

}

@end
