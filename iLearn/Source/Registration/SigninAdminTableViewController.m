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
#import "UIImage+MDQRCode.h"
#import "TrainCourse.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "DataHelper.h"
#import "FileUtils.h"

static const NSInteger kMinScanInterval = 3;
static NSString *const kTrainSigninFormIdentifier = @"SigninCRUD";

@interface SigninAdminTableViewController ()
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataList;
@property (nonatomic) ContentTableViewCell *currentCell;
@property (strong, nonatomic) NSString *lastScannedResult;
@property (assign, nonatomic) long long lastScanDate;
@property (strong, nonatomic) TrainCourse *trainCourse;
@property (strong, nonatomic) NSDictionary *currentTrainSingin;
@end

@implementation SigninAdminTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataList = [NSArray array];
    _currentTrainSingin = [NSDictionary dictionary];
    
    _trainCourse = [[TrainCourse alloc] initCourseData:[FileUtils shareData]];
    self.listViewController.courseNameLabel.text = self.trainCourse.name;
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
    SigninAdminTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SigninAdminTableViewCell"];
    cell.delegate = self;
    
    NSDictionary *dict = _dataList[indexPath.row];
    
    cell.titleLabel.text = dict[@"Name"];
    cell.statusLabel.text = [NSString stringWithFormat:@"%@ (%@)", dict[@"UserName"], dict[@"EmployeeId"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kTrainSigninFormIdentifier]) {
        SigninFormViewController *formVC = (SigninFormViewController*)segue.destinationViewController;
        formVC.delegate    = self;
        formVC.isCreated   = [sender boolValue];
        formVC.trainCourse = self.trainCourse;
        formVC.trainSignin = self.currentTrainSingin;
        //formVC.listViewController = self.listViewController;
    }
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.currentTrainSingin = [self.dataList objectAtIndex:[indexPath row]];
    
    if(self.currentTrainSingin[@"Id"]) {
        [self performSegueWithIdentifier:kTrainSigninFormIdentifier sender:@NO];
    }
    else {
        [ViewUtils showPopupView:self.listViewController.view Info:@"缺少签到ID，请联系管理员"];
    }
}

- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell {
    self.listViewController.listType = ListViewTypeSigninUser;
    [self.listViewController refreshContentView];
}

- (void)didSelectQRCodeButtonOfCell:(ContentTableViewCell*)cell {
    NSLog(@"didSelectQRCodeButtonOfCell");
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"didSelectQRCodeButtonOfCell:");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    // NSDictionary *content = [self.dataList objectAtIndex:indexPath.row];
    
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

- (IBAction)actionBack:(id)sender {
    self.listViewController.listType = ListViewTypeRegistration;
    [self.listViewController refreshContentView];
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    NSDate *now = [NSDate date];
    NSTimeInterval nowInterval = [now timeIntervalSince1970];
    
    if (nowInterval - _lastScanDate < kMinScanInterval) {
        return;
    }
    _lastScanDate = nowInterval;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"result" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    _dataList = [DataHelper trainSingins:[HttpUtils isNetworkAvailable] tid:self.trainCourse.ID];
    [self.tableView reloadData];
}

/**
 *  创建签到
 */
- (void)scanQRCode {
    self.currentTrainSingin = [NSDictionary dictionary];
    [self performSegueWithIdentifier:kTrainSigninFormIdentifier sender:@YES];
}

- (void)actionEdit {
    [self syncData];
}
- (void)actionSubmit {
    [self syncData];
}
- (void)actionRemove {
    [self syncData];
}

@end
