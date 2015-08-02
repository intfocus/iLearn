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
#import "LicenseUtil.h"
#import "ExamUtil.h"
#import <MBProgressHUD.h>
#import "ListViewController.h"
#import "DataHelper.h"
#import "CoursePackage.h"
#import "CoursePackageContent.h"
#import "CoursePackageDetail.h"
#import "CourseWrap.h"
#import "DisplayViewController.h"

static NSString *const kShowSubjectSegue = @"showSubjectPage";
static NSString *const kShowDetailSegue = @"showDetailPage";
static NSString *const kShowPasswordSegue = @"showPasswordPage";
static NSString *const kShowSettingsSegue = @"showSettingsPage";

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
@property (strong, nonatomic) CoursePackage *lastCoursePackage;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowDetailSegue]) {

        DetailViewController *detailVC = (DetailViewController*)segue.destinationViewController;
        detailVC.titleString = [sender name];
        detailVC.descString  = [sender desc];
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
            cell.statusTitleLabel.text = @"类型:";
            cell.statusLabel.text      = @"课程包";
            cell.scoreTitleLabel.text  = @"状态:";
            cell.scoreLabel.text       = @"未学习";
            [cell.actionButton setTitle:@"进入" forState:UIControlStateNormal];
        }
            break;
            
        case 2:
        case 3: {
            id obj =  [self.dataList objectAtIndex:indexPath.row];
            if([obj isCourseWrap]) {
                CourseWrap *courseWrap = (CourseWrap *)obj;
                cell.titleLabel.text       = [courseWrap name];
                cell.statusTitleLabel.text = @"类型:";
                cell.statusLabel.text      = [courseWrap typeName];
                cell.scoreTitleLabel.text  = @"状态:";
                cell.scoreLabel.text       = [courseWrap statusLabelText];
                [cell.actionButton setTitle:[courseWrap actionButtonState] forState:UIControlStateNormal];
            }
            else {
                CoursePackageDetail *packageDetail = (CoursePackageDetail *)obj;
                cell.titleLabel.text       = [packageDetail name];
                cell.statusTitleLabel.text = @"类型:";
                cell.statusLabel.text      = [packageDetail typeName];
                cell.scoreTitleLabel.text  = @"状态:";
                cell.scoreLabel.text       = [packageDetail statusLabelText];
                [cell.actionButton setTitle:[packageDetail actionButtonState] forState:UIControlStateNormal];
            }
        }
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
    
    [self performSegueWithIdentifier:kShowDetailSegue sender:[self.dataList objectAtIndex:indexPath.row]];
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
            self.listViewController.titleLabel.hidden = YES;
            self.listViewController.backButton.hidden = NO;
            self.listViewController.courseNameLabel.hidden = NO;
            self.listViewController.courseNameLabel.text = coursePackage.name;
            self.depth = @2;
            self.lastCoursePackage = coursePackage;
            [self.tableView reloadData];
        }
            break;
            
        case 2:
        case 3: {
            id obj = [self.dataList objectAtIndex:indexPath.row];
            if([obj isCourseWrap]) {
                CourseWrap *courseWrap = (CourseWrap *)obj;
                _dataList = courseWrap.courseList;
                self.depth = @3;
                [self.tableView reloadData];
                self.listViewController.courseNameLabel.text = courseWrap.name;
            }
            else {
                CoursePackageDetail *packageDetail = (CoursePackageDetail *)obj;
                NSString *state = [packageDetail actionButtonState];
                if([packageDetail isCourse]) {
                    if([state isEqualToString:@"下载"]) {
                        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
                        _progressHUD.labelText = @"下载中...";
                        [self.connectionManager downloadCourse:packageDetail.courseId Ext:packageDetail.courseExt];
                    }
                    else {
                        DisplayViewController *displayViewController = [[DisplayViewController alloc] init];
                        displayViewController.packageDetail = packageDetail;
                        [self presentViewController:displayViewController animated:YES completion:nil];
                    }
                }
            }
        }
            break;
            
        default:
            break;
    }
    [self.listViewController.backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)actionBack:(id)sender {
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
    
    
    switch ([self.depth intValue]) {
        case 2: {
            _dataList = [DataHelper coursePackages];
            [self.tableView reloadData];
            self.listViewController.backButton.hidden = YES;
            self.listViewController.titleLabel.hidden = NO;
            self.listViewController.courseNameLabel.hidden = YES;
        }
            break;
        case 3: {
            _dataList = [DataHelper coursePackageContent:self.lastCoursePackage.ID];
            self.listViewController.courseNameLabel.hidden = NO;
            self.listViewController.courseNameLabel.text = self.lastCoursePackage.name;
            [self.tableView reloadData];
        }
            break;
        default:
            break;
    }
    self.depth = [NSNumber numberWithInteger:([self.depth intValue] -1)];
    [progressHUD removeFromSuperview];
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

- (void)connectionManagerDidDownloadCourse:(NSString *)courseID Ext:(NSString *)extName withError:(NSError *)error {
    [_progressHUD hide:YES];
    
    if(!error) {
        [self.tableView reloadData];
    }
}
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

- (void)connectionManagerDidUploadExamScannedResult:(NSString *)result withError:(NSError *)error {}

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
