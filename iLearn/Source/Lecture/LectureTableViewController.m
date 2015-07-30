//
//  LectureTableViewController.m
//  iLearn
//
//  Created by lijunjie on 15/7/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//
#import "LectureTableViewController.h"
#import "DetailViewController.h"
#import "PasswordViewController.h"
#import "QuestionnaireUtil.h"
#import "ExamViewController.h"
#import "ScoreQRCodeViewController.h"
#import "LicenseUtil.h"
#import "ExamUtil.h"
#import "UIImage+MDQRCode.h"
#import <MBProgressHUD.h>
#import "ListViewController.h"
#import "DataHelper.h"
#import "CoursePackage.h"
#import "CoursePackageContent.h"
#import "CoursePackageDetail.h"

static NSString *const kShowSubjectSegue = @"showSubjectPage";
static NSString *const kShowDetailSegue = @"showDetailPage";
static NSString *const kShowPasswordSegue = @"showPasswordPage";
static NSString *const kShowSettingsSegue = @"showSettingsPage";
static NSString *const kShowScoreQRCode = @"showScoreQRCode";

static NSString *const kTableViewCellIdentifier = @"LectureTableViewCell";

@interface LectureTableViewController () <DetailViewControllerProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ConnectionManager *connectionManager;

@property (strong, nonatomic) NSArray *dataList;

@property (assign, nonatomic) BOOL hasAutoSynced;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (weak, nonatomic) UIAlertView *lastAlertView;

@property (assign, nonatomic) BOOL showBeginTestInfo;
@property (nonatomic) ContentTableViewCell *currentCell;

@property (strong, nonatomic) NSNumber *depth;
@end


@implementation LectureTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataList = [[NSArray alloc] init];
    
    self.connectionManager = [[ConnectionManager alloc] init];
    _connectionManager.delegate = self;
    
    _depth = @1; // 一级: 课程包列表， 二级: 课件包、课件、考试、问卷, 三级: 二级内容的重组
    _dataList = [DataHelper coursePackages];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    if (!_hasAutoSynced) {
        _hasAutoSynced = YES;
        [self syncData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowDetailSegue]) {
        CoursePackage *coursePackage = (CoursePackage *)sender;
        
        DetailViewController *detailVC = (DetailViewController*)segue.destinationViewController;
        detailVC.titleString = coursePackage.name;
        detailVC.descString  = coursePackage.desc;
        if (self.showBeginTestInfo) {
            detailVC.delegate = self;
            detailVC.shownFromBeginTest = self.showBeginTestInfo;
        }
        else {
            detailVC.shownFromBeginTest = self.showBeginTestInfo;
        }
    }
    if ([segue.identifier isEqualToString:kShowPasswordSegue]) {
        PasswordViewController *detailVC = (PasswordViewController*)segue.destinationViewController;
        
        detailVC.titleString = [[ExamUtil titleFromContent:sender] stringByAppendingString:NSLocalizedString(@"LIST_DETAIL", nil)];
        detailVC.descString = [ExamUtil descFromContent:sender];
        detailVC.password = sender[ExamPassword];
        __weak id weakSelf = self;
        detailVC.callback = ^(void){
            [weakSelf enterExamPageForContent:sender];
        };
    }
    else if ([segue.identifier isEqualToString:kShowSubjectSegue]) {
        //UINavigationController *navController = segue.destinationViewController;
        UIViewController *viewController = segue.destinationViewController;
        
        if ([viewController isKindOfClass:[ExamViewController class]]) {
            ExamViewController *examVC = (ExamViewController*)viewController;
            examVC.examContent = sender;
        }
    }
    else if ([segue.identifier isEqualToString:kShowScoreQRCode]) {
        
        ScoreQRCodeViewController *scoreQRCodeVC = segue.destinationViewController;
        scoreQRCodeVC.scoreQRCodeImage = sender;
    }
}

#pragma mark - UI Adjustment


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView cellForExamRowAtIndexPath:indexPath];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForExamRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExamTabelViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    cell.delegate = self;
    
    switch ([self.depth intValue]) {
        case 1: {
            CoursePackage *coursePackage = [self.dataList objectAtIndex:indexPath.row];
            cell.titleLabel.text       = coursePackage.name;
            cell.statusTitleLabel.text = @"TODO1";
            cell.statusLabel.text      = @"TODO1";
            cell.scoreTitleLabel.text  = @"TODO1";
            cell.scoreLabel.text       = @"TODO1";
            [cell.actionButton setTitle:@"进入" forState:UIControlStateNormal];
        }
            break;
            
        case 2: {
            CoursePackageDetail *packageDetail = [self.dataList objectAtIndex:indexPath.row];
            cell.titleLabel.text       = packageDetail.courseName;
            cell.statusTitleLabel.text = @"TODO2";
            cell.statusLabel.text      = @"TODO2";
            cell.scoreTitleLabel.text  = @"TODO2";
            cell.scoreLabel.text       = @"TODO2";
            [cell.actionButton setTitle:@"TODO" forState:UIControlStateNormal];
        }
            break;
        case 3:
            break;
            
        default:
            break;
    }
    

    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell
{
    self.showBeginTestInfo = NO;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    CoursePackage *coursePackage = [self.dataList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kShowDetailSegue sender:coursePackage];
}

- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell
{
    self.showBeginTestInfo = YES;
    self.currentCell = cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"didSelectActionButtonOfCell:");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    //NSDictionary *content = [self.dataList objectAtIndex:indexPath.row];
    
    switch ([self.depth intValue]) {
        case 1: {
            CoursePackage *coursePackage = [self.dataList objectAtIndex:indexPath.row];
            _dataList = [DataHelper coursePackageContent:coursePackage.ID];
            self.depth = @2;
            [self.tableView reloadData];
        }
            break;
            
        case 2:
            break;
            
        case 3:
            break;
            
        default:
            break;
    }
    if (cell.actionButtonType == ContentTableViewCellActionDownload) {
        
//        NSString *examId = [NSString stringWithFormat:@"%@", content[ExamId]];
//        [self downloadExamId:examId];
    }
    else if (cell.actionButtonType == ContentTableViewCellActionView) {
        
//        ExamTabelViewCell *examTVC = (ExamTabelViewCell *)cell;
//        if ([examTVC.actionButton.titleLabel.text isEqual:NSLocalizedString(@"LIST_BUTTON_VIEW_RESULT", nil)]) {
//            [self beginTest: content];
//        }
//        else {
//            [self performSegueWithIdentifier:kShowDetailSegue sender:content];
//        }
    }
}

- (void)didSelectQRCodeButtonOfCell:(ContentTableViewCell*)cell {}

#pragma mark - IBAction

- (void)enterExamPageForContent:(NSDictionary*)content
{
    __weak LectureTableViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    hud.labelText = NSLocalizedString(@"LIST_LOADING", nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ExamUtil parseContentIntoDB:content];
        
        NSString *dbPath = [ExamUtil examDBPathOfFile:content[CommonFileName]];
        
        NSDictionary *dbContent = [ExamUtil examContentFromDBFile:dbPath];
        //NSLog(@"dbContent: %@", [ExamUtil jsonStringOfContent:dbContent]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [weakSelf performSegueWithIdentifier:kShowSubjectSegue sender:dbContent];
        });
    });
}

#pragma mark - ConnectionManagerDelegate

- (void)connectionManagerDidDownloadExamsForUser:(NSString *)userId withError:(NSError *)error
{
    [_progressHUD hide:YES];
    
    if (!error) {
        //[self refreshContent];
    }
}

- (void)connectionManagerDidDownloadExam:(NSString *)examId withError:(NSError *)error
{
    [_progressHUD hide:YES];
    
    if (!error) {
        //[self refreshContent];
    }
}

- (void)connectionManagerDidUploadExamResult:(NSString *)examId withError:(NSError *)error
{
    if (!error) {
        NSString *dbPath = [ExamUtil examDBPathOfFile:examId];
        [ExamUtil setExamSubmittedwithDBPath:dbPath];
        
        //[self refreshContent];
    }
}

- (void)connectionManagerDidUploadExamScannedResult:(NSString *)result withError:(NSError *)error
{
}



- (void)syncData {}

- (void)beginTest:(NSDictionary *)content {
    NSNumber *examType = content[ExamType];
    NSNumber *examLocation = content[ExamLocation];
    NSNumber *examOpened = content[ExamOpened];
    
    if ([examType isEqualToNumber:@(ExamTypesFormal)] &&
        [examLocation isEqualToNumber:@(ExamLocationsOnsite)] &&
        ![examOpened isEqualToNumber:@1]) {
        
        [self performSegueWithIdentifier:kShowPasswordSegue sender:content];
    }
    else {
        [self enterExamPageForContent:content];
    }
}

#pragma mark - DetailViewControllerProtocol
- (void)begin{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.currentCell];
    NSDictionary *content = [self.dataList objectAtIndex:indexPath.row];
    [self beginTest:content];
}

@end
