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
#import "LectureTableViewCell.h"

static NSString *const kExamVCStoryBoardID = @"ExamViewController";
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

- (void)viewWillAppear:(BOOL)animated {
    
    //if (!_hasAutoSynced) {
    //    _hasAutoSynced = YES;
        [self syncData];
    //}
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
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView cellForExamRowAtIndexPath:indexPath];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForExamRowAtIndexPath:(NSIndexPath *)indexPath {
    LectureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    cell.delegate = self;
    
    switch ([self.depth intValue]) {
        case 1: {
            CoursePackage *coursePackage = [self.dataList objectAtIndex:indexPath.row];
            cell.titleLabel.text       = coursePackage.name;
            cell.statusTitleLabel.text = @"类型:";
            cell.statusLabel.text      = @"课程包";
            cell.scoreTitleLabel.text  = @"状态:";
            cell.scoreLabel.text       = @"TODO";
            [cell.actionButton setTitle:@"进入" forState:UIControlStateNormal];
        }
            break;
        case 2:
        case 3: {
            id obj =  [self.dataList objectAtIndex:indexPath.row];
            NSArray *statusLabelText = [obj statusLabelText];
            
            cell.titleLabel.text       = [obj name];
            cell.statusLabel.text      = [obj typeName];
            cell.statusTitleLabel.text = @"类型:";
            cell.scoreTitleLabel.text  = @"状态:";
            cell.scoreLabel.text       = statusLabelText[0];
            [cell.actionButton setTitle:statusLabelText[1] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0;
}

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell {
    self.showBeginTestInfo = NO;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [self performSegueWithIdentifier:kShowDetailSegue sender:[self.dataList objectAtIndex:indexPath.row]];
}

- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell {
    self.showBeginTestInfo = YES;
    self.currentCell = cell;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSLog(@"didSelectActionButtonOfCell:");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    self.progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL removeHUD = YES;
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
                    if([packageDetail isCourse]) {
                        LectureTableViewCell *lectureTableViewCell = (LectureTableViewCell *)cell;
                        NSString *state = lectureTableViewCell.actionButton.titleLabel.text;
                        if([state isEqualToString:@"下载"]) {
                            self.progressHUD.labelText = @"下载中...";
                            removeHUD = NO;
                            [self.connectionManager downloadCourse:packageDetail.courseId Ext:packageDetail.courseExt];
                        }
                        else {
                            DisplayViewController *displayViewController = [[DisplayViewController alloc] init];
                            displayViewController.packageDetail = packageDetail;
                            [self presentViewController:displayViewController animated:YES completion:nil];
                        }
                    }
                    else if([packageDetail isExam]) {
                        if([packageDetail isExamDownload]) {
                            self.showBeginTestInfo = YES;
                            [self performSegueWithIdentifier:kShowDetailSegue sender:packageDetail];
                        }
                        else {
                            self.progressHUD.labelText = @"下载中...";
                            removeHUD = NO;
                             [_connectionManager downloadExamWithId:packageDetail.examId];
                        }
                    }
                }
            }
                break;
                
            default:
                break;
        }
        [self.listViewController.backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        if(removeHUD) {
            [self.progressHUD removeFromSuperview];
        }
    });
}

- (IBAction)actionBack:(id)sender {
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    self.progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
        [self.progressHUD removeFromSuperview];
    });
}
- (void)didSelectQRCodeButtonOfCell:(ContentTableViewCell*)cell {}

#pragma mark - IBAction

- (void)enterExamPageForContent:(NSDictionary*)content {
    __weak LectureTableViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    hud.labelText = NSLocalizedString(@"LIST_LOADING", nil);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ExamUtil parseContentIntoDB:content];
        
        NSString *dbPath = [ExamUtil examDBPath:content[CommonFileName]];
        
        NSDictionary *dbContent = [ExamUtil examContentFromDBFile:dbPath];
        [dbContent setValue:[NSNumber numberWithInt:ExamTypesPractice] forKey:ExamType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            
            UIStoryboard *storyboard   = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ExamViewController *examVC = (ExamViewController *)[storyboard instantiateViewControllerWithIdentifier:kExamVCStoryBoardID];
            examVC.examContent         = dbContent;
            [weakSelf presentViewController:examVC animated:YES completion:^{
                NSLog(@"popup view.");
            }];
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
- (void)connectionManagerDidDownloadExamsForUser:(NSString *)userId withError:(NSError *)error {
    [_progressHUD hide:YES];
    
    if (!error) {
        //[self refreshContent];
    }
}

- (void)connectionManagerDidDownloadExam:(NSString *)examId withError:(NSError *)error {
    [_progressHUD hide:YES];
    
    if(!error) {
        [self.tableView reloadData];
    }
}

- (void)connectionManagerDidUploadExamResult:(NSString *)examId withError:(NSError *)error {
    
    [_progressHUD hide:YES];
    if (!error) {
        NSString *dbPath = [ExamUtil examDBPath:examId];
        [ExamUtil setExamSubmittedwithDBPath:dbPath];
        
        //[self refreshContent];
    }
}

- (void)connectionManagerDidUploadExamScannedResult:(NSString *)result withError:(NSError *)error {
    [_progressHUD hide:YES];
}

- (void)syncData {
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    self.progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        switch ([self.depth intValue]) {
            case 1: {
                _dataList = [DataHelper coursePackages];
                [self.tableView reloadData];
                self.listViewController.backButton.hidden = YES;
                self.listViewController.titleLabel.hidden = NO;
                self.listViewController.courseNameLabel.hidden = YES;
            }
                break;
            case 2: {
                _dataList = [DataHelper coursePackageContent:self.lastCoursePackage.ID];
                self.listViewController.courseNameLabel.hidden = NO;
                self.listViewController.courseNameLabel.text = self.lastCoursePackage.name;
                [self.tableView reloadData];
            }
                break;
            case 3: {
                [self.tableView reloadData];
            }
                break;
            default:
                break;
        }
        [self.progressHUD removeFromSuperview];
    });
}


#pragma mark - DetailViewControllerProtocol
- (void)begin{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.currentCell];
    CoursePackageDetail *packageDetail = [self.dataList objectAtIndex:indexPath.row];
    NSMutableDictionary *content = [NSMutableDictionary dictionaryWithDictionary:packageDetail.examDictContent];
    content[CommonFileName] = packageDetail.examId;
    
    [self enterExamPageForContent:[NSDictionary dictionaryWithDictionary:content]];
}

@end
