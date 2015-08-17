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
#import "HttpUtils.h"
#import "ViewUtils.h"
#import "DataHelper.h"

static const NSInteger kMinScanInterval = 3;

@interface SigninAdminTableViewController ()
@property (strong, nonatomic) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataList;
@property (nonatomic) ContentTableViewCell *currentCell;
@property (strong, nonatomic) NSString *lastScannedResult;
@property (assign, nonatomic) long long lastScanDate;
@end

@implementation SigninAdminTableViewController

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
    SigninAdminTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SigninAdminTableViewCell"];
    cell.delegate = self;
    
    NSDictionary *dict = _dataList[indexPath.row];
    
    cell.titleLabel.text = dict[@"Name"];
    cell.statusLabel.text = [NSString stringWithFormat:@"%@ (%@)", dict[@"UserName"], dict[@"EmployeeID"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SigninCRUD"]) {
        SigninFormViewController *formVC = (SigninFormViewController*)segue.destinationViewController;
        formVC.delegate  = self;
        formVC.isCreated = [sender[@"isCreated"] boolValue];
        formVC.name = sender[@"Name"];
    }
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell {
    self.currentCell = cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *dict = self.dataList[indexPath.row];
    dict[@"isCreated"] = @NO;
    [self performSegueWithIdentifier:@"SigninCRUD" sender:dict];
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
    
    NSDictionary *content = [self.dataList objectAtIndex:indexPath.row];
    
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
    _dataList = [DataHelper signins:NO cid:@"1"];
    [self.tableView reloadData];
}

/**
 *  创建签到
 */
- (void)scanQRCode {
    [self performSegueWithIdentifier:@"SigninCRUD" sender:@{@"isCreated": @YES,@"name": @""}];
}

- (void)actionEdit {
    NSLog(@"actionEdit");
}
- (void)actionSubmit {
    NSLog(@"actionSubmit");
}
- (void)actionRemove {
    NSLog(@"actionRemove");
}

@end
