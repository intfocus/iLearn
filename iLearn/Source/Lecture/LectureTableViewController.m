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
#import "FileUtils.h"
#import "HttpUtils.h"
#import <MBProgressHUD.h>
#import <SSZipArchive.h>
#import "ListViewController.h"
#import "DataHelper.h"
#import "CoursePackage.h"
#import "CoursePackageContent.h"
#import "CoursePackageDetail.h"
#import "CourseWrap.h"
#import "DisplayViewController.h"
#import "LectureTableViewCell.h"
#import "ExtendNSLogFunctionality.h"

static NSString *const kExamVCStoryBoardID = @"ExamViewController";
static NSString *const kShowDetailSegue    = @"showDetailPage";
static NSString *const kShowSettingsSegue  = @"showSettingsPage";

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
    _dataList = [NSArray array];
    
    self.connectionManager = [[ConnectionManager alloc] init];
    _connectionManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    _depth = @1; // 一级: 课程包列表， 二级: 课件包、课件、考试、问卷, 三级: 二级内容的重组
    [self syncData];
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
        }
        detailVC.shownFromBeginTest = self.showBeginTestInfo;
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
    LectureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    cell.delegate = self;
    
    switch ([self.depth intValue]) {
        case 1: {
            CoursePackage *coursePackage = [self.dataList objectAtIndex:indexPath.row];
            cell.titleLabel.text        = coursePackage.name;
            cell.statusTitleLabel.text  = @"类型:";
            cell.statusLabel.text       = @"课程包";
            cell.scoreTitleLabel.text   = @"状态:";
            cell.scoreLabel.text        = @"TODO";
            cell.scoreTitleLabel.hidden = YES;
            cell.scoreLabel.hidden      = YES;
            [cell.actionButton setTitle:@"进入" forState:UIControlStateNormal];
            [cell.infoButton setImage:[UIImage imageNamed:@"course_package"] forState:UIControlStateNormal];
            break;
        }
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
            [cell.infoButton setImage:[UIImage imageNamed:[obj infoButtonImage]] forState:UIControlStateNormal];
            
            break;
        }
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
    
    NSInteger depth = [self.depth intValue];
    id obj = [self.dataList objectAtIndex:indexPath.row];
    switch (depth) {
        case 1: {
            self.depth = @2;
            CoursePackage *coursePackage = (CoursePackage *)obj;
            _dataList = [DataHelper coursePackageContent:NO pid:coursePackage.ID];
            self.listViewController.titleLabel.hidden = YES;
            self.listViewController.backButton.hidden = NO;
            self.listViewController.courseNameLabel.hidden = NO;
            self.listViewController.courseNameLabel.text = coursePackage.name;
            self.lastCoursePackage = coursePackage;
            [self.tableView reloadData];
            break;
        }
        case 2:
        case 3: {
            self.depth = @3;
            if([obj isCourseWrap]) {
                CourseWrap *courseWrap = (CourseWrap *)obj;
                _dataList = courseWrap.courseList;
                [self.tableView reloadData];
                self.listViewController.courseNameLabel.text = courseWrap.name;
            }
            break;
        }
        default:
            break;
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL removeHUD = YES;
        if([HttpUtils isNetworkAvailable]) {
            switch (depth) {
                case 1: {
                    CoursePackage *coursePackage = (CoursePackage *)obj;
                    NSArray *array = [NSArray array];
                    array = [DataHelper coursePackageContent:YES pid:coursePackage.ID];
                    self.listViewController.courseNameLabel.text = coursePackage.name;
                    self.lastCoursePackage = coursePackage;
                    if([array count]) {
                        _dataList = array;
                        [self.tableView reloadData];
                    }
                    break;
                }
                case 2:
                case 3: {
                    if(![obj isCourseWrap]) {
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
                    break;
                }
                default:
                    break;
            }
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
    
    NSInteger depth = [self.depth intValue];
    switch (depth) {
        case 2: {
            _dataList = [DataHelper coursePackages:NO];
            self.listViewController.backButton.hidden = YES;
            self.listViewController.titleLabel.hidden = NO;
            self.listViewController.courseNameLabel.hidden = YES;
        }
            break;
        case 3: {
            _dataList = [DataHelper coursePackageContent:NO pid:self.lastCoursePackage.ID];
            self.listViewController.courseNameLabel.hidden = NO;
            self.listViewController.courseNameLabel.text = self.lastCoursePackage.name;
        }
            break;
        default:
            break;
    }
    [self.tableView reloadData];
    // 易混淆点: dispatch_after,tableView#cellForRowAtIndexPath 都需要使用self.depth
    self.depth = [NSNumber numberWithInteger:([self.depth intValue] -1)];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([HttpUtils isNetworkAvailable]) {
            NSArray *array = [NSArray array];
            switch (depth) {
                case 2: {
                    array = [DataHelper coursePackages:YES];
                    break;
                }
                case 3: {
                    array = [DataHelper coursePackageContent:YES pid:self.lastCoursePackage.ID];
                    break;
                }
                default:
                    break;
            }
            
            if([array count] > 0) {
                _dataList = array;
                [self.tableView reloadData];
            }
        }
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
        NSString *examDBPath = [FileUtils coursePath:content[CommonFileName] Ext:@"db"];
        [ExamUtil parseContentIntoDB:content Path:examDBPath];
        
        
        NSDictionary *dbContent = [ExamUtil examContentFromDBFile:examDBPath];
        [dbContent setValue:examDBPath forKey:CommonDBPath];
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
        if([extName isEqualToString:@"zip"]) {
            NSString *zipPath    = [FileUtils coursePath:courseID Ext:extName UseExt:YES];
            NSString *coursePath = [FileUtils coursePath:courseID Ext:extName UseExt:NO];
            if([SSZipArchive unzipFileAtPath:zipPath toDestination:coursePath]) {
                NSFileManager *fileManage = [NSFileManager defaultManager];
                NSArray *files = [fileManage subpathsAtPath: coursePath];
                
                NSString *subDirPath = [coursePath stringByAppendingPathComponent:files[0]];
                NSString *tmpPath = [NSString stringWithFormat:@"%@-tmp", coursePath];
                [fileManage moveItemAtPath:subDirPath toPath:tmpPath error:&error];
                NSErrorPrint(error, @"move %@ => %@", subDirPath, tmpPath);
                [FileUtils removeFile:coursePath];
                [fileManage moveItemAtPath:tmpPath toPath:coursePath error:&error];
                NSErrorPrint(error, @"move %@ => %@", tmpPath, coursePath);
                
                [FileUtils removeFile:zipPath];
            }
        }
        
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
        NSString *examPath = [ExamUtil examPath:examId];
        NSString *coursePath = [FileUtils coursePath:examId Ext:[examPath pathExtension]];
        [FileUtils move:examPath to:coursePath];
        
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
    
    switch ([self.depth intValue]) {
        case 1: {
            _dataList = [DataHelper coursePackages:NO];
            self.listViewController.backButton.hidden = YES;
            self.listViewController.titleLabel.hidden = NO;
            self.listViewController.courseNameLabel.hidden = YES;
            break;
        }
        case 2: {
            _dataList = [DataHelper coursePackageContent:NO pid:self.lastCoursePackage.ID];
            self.listViewController.courseNameLabel.hidden = NO;
            self.listViewController.courseNameLabel.text = self.lastCoursePackage.name;
            break;
        }
        default:
            break;
    }
    [self.tableView reloadData];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([HttpUtils isNetworkAvailable]) {
            NSArray *array = [NSArray array];
            switch ([self.depth intValue]) {
                case 1: {
                    array = [DataHelper coursePackages:YES];
                    break;
                }
                case 2: {
                    array = [DataHelper coursePackageContent:YES pid:self.lastCoursePackage.ID];
                    break;
                }
                default:
                    break;
            }
            if([array count] > 0) {
                _dataList = array;
                [self.tableView reloadData];
            }
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
