//
//  RegistrationTableViewController.m
//  iLearn
//
//  Created by lijunjie on 15/8/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "RegistrationTableViewController.h"
#import "ExamUtil.h"
#import "FileUtils.h"
#import "HttpUtils.h"
#import "ViewUtils.h"
#import <MBProgressHUD.h>
#import "ListViewController.h"
#import "DetailViewController.h"
#import "DataHelper.h"
#import "TrainCourse.h"
#import "RegistrationTableViewCell.h"
#import "ExtendNSLogFunctionality.h"

static NSString *const kShowDetailSegue    = @"showDetailPage";

@interface RegistrationTableViewController()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataList;

@property (assign, nonatomic) BOOL hasAutoSynced;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (weak, nonatomic) UIAlertView *lastAlertView;

@property (assign, nonatomic) BOOL showBeginTestInfo;
@property (assign, nonatomic) BOOL showRemoveButton;
@property (nonatomic) ContentTableViewCell *currentCell;
@end

@implementation RegistrationTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    RegistrationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegistrationTableViewCell"];
    cell.delegate = self;

    TrainCourse *trainCourse = [self.dataList objectAtIndex:indexPath.row];
    cell.titleLabel.text        = trainCourse.name;
    cell.statusLabel.text       = trainCourse.statusName;
    [cell.actionButton setTitle:trainCourse.actionButtonLabel forState:UIControlStateNormal];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowDetailSegue]) {
        DetailViewController *detailVC = (DetailViewController*)segue.destinationViewController;
        detailVC.titleString       = [sender name];
        detailVC.descString        = [sender desc];
        detailVC.showFromBeginTest = self.showBeginTestInfo;
        detailVC.showRemoveButton  = self.showRemoveButton;
    }
}
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell {
    self.currentCell = cell;
    self.showBeginTestInfo = NO;
    self.showRemoveButton  = NO;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    id obj = [self.dataList objectAtIndex:[indexPath row]];
    [self performSegueWithIdentifier:kShowDetailSegue sender:obj];
}

- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TrainCourse *trainCourse = self.dataList[indexPath.row];
    if([trainCourse isSignin]) {
        [FileUtils shareData:trainCourse.originalDict];
        
        self.listViewController.listType = ListViewTypeSigninAdmin;
        [self.listViewController refreshContentView];
    }
    else {
        if([trainCourse.statusName isEqualToString:@"可接受报名"]) {
            [DataHelper trainSignup:trainCourse.ID];
            [self syncData];
        }
        else {
            [ViewUtils showPopupView:self.listViewController.view Info:@"报名审核中，请耐心等候."];
        }
    }
}

- (IBAction)actionBack:(id)sender {

}
- (void)didSelectQRCodeButtonOfCell:(ContentTableViewCell*)cell {}


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
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    self.progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
    
    _dataList = [DataHelper trainCourses:YES];
    [self.tableView reloadData];
    
    [self.progressHUD hide:YES];
}


@end
