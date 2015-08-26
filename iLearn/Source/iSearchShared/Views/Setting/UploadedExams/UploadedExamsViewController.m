//
//  UploadedExamsViewController.m
//  iLearn
//
//  Created by lijunjie on 15/8/26.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "UploadedExamsViewController.h"
#import "SettingViewController.h"
#import "DataHelper.h"
#import "Constants.h"
#import "ConnectionManager.h"
#import "ExamUtil.h"
#import "HttpUtils.h"
#import "FileUtils.h"
#import "CacheHelper.h"
#import "User.h"
#import "ViewUtils.h"

@interface UploadedExamsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *uploadedExams;
@property (nonatomic, strong) ConnectionManager *connectionManager;
@property (nonatomic, strong) NSMutableDictionary *examsIndexPath;
@end

@implementation UploadedExamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _uploadedExams     = [NSMutableArray array];
    _examsIndexPath    = [NSMutableDictionary dictionary];
    _connectionManager = [[ConnectionManager alloc] init];
    _connectionManager.delegate = self;
    
    UIBarButtonItem *navBtnRefresh = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(actionNavRefresh:)];
    self.navigationItem.rightBarButtonItem = navBtnRefresh;
    self.title = @"考试记录";
    
    [self syncData:[HttpUtils isNetworkAvailable]];
}

- (void)syncData:(BOOL)isNetworkAvailable {
    NSMutableDictionary *dict = [DataHelper uploadedExams:isNetworkAvailable userID:[User userID]];
    if(dict && dict[@"data"] && [dict[@"data"] isKindOfClass:[NSArray class]]) {
        _uploadedExams = [NSMutableArray arrayWithArray:dict[@"data"]];
    }
    
    NSString *examFolder = [FileUtils dirPath:ExamFolder];
    for (NSInteger i=0; i<[_uploadedExams count]; i++) {
        NSDictionary *exam = _uploadedExams[i];
        NSString *examID = exam[@"ExamId"];
        
        NSString *examPath = [NSString stringWithFormat:@"%@/%@.json", examFolder, examID];
        if([FileUtils checkFileExist:examPath isDir:NO]) {
            NSMutableDictionary *content = [FileUtils readConfigFile:examPath];
            if(content[ExamTitle]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:exam];
                tempDict[@"ExamName"] = content[ExamTitle];
                _uploadedExams[i] = [NSDictionary dictionaryWithDictionary:tempDict];
            }
        }
        else if(isNetworkAvailable) {
            [_connectionManager downloadExamWithId:examID];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - controls action
- (IBAction)actionBackToMain:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)actionNavRefresh:(id)sender {
    if([HttpUtils isNetworkAvailable]) {
        [self syncData:YES];
    }
    else {
        [ViewUtils showPopupView:self.view Info:@"请联网后刷新！"];
    }
}

- (void)connectionManagerDidDownloadExam:(NSString *)examID withError:(NSError *)error {
    NSString *examFolder = [FileUtils dirPath:ExamFolder];
    NSString *examPath = [NSString stringWithFormat:@"%@/%@.json", examFolder, examID];
    if([FileUtils checkFileExist:examPath isDir:NO]) {
        NSMutableDictionary *content = [FileUtils readConfigFile:examPath];
        NSString *dbPath = [ExamUtil examDBPath:examID];
        [ExamUtil parseContentIntoDB:content Path:dbPath];
        
        NSMutableDictionary *upladedExamResult = [DataHelper uploadedExamResult:[HttpUtils isNetworkAvailable] userID:[User userID] examID:examID];
        [ExamUtil parseResultIntoDB:upladedExamResult Path:dbPath];
        
        for(NSInteger i=0; i < [_uploadedExams count]; i++) {
            NSMutableDictionary *dict = _uploadedExams[i];
            if([dict[@"ExamId"] isEqualToString:examID] && content[ExamTitle]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                tempDict[@"ExamName"] = content[ExamTitle];
                _uploadedExams[i] = [NSDictionary dictionaryWithDictionary:tempDict];
                
                NSIndexPath *indexPath = _examsIndexPath[examID];
                if(indexPath) {
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }
                
                break;
            }
        }
    }
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_uploadedExams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if(!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellID"];
    }
    
    NSDictionary *dict = _uploadedExams[indexPath.row];
    cell.textLabel.text       = dict[@"ExamName"] ?: @"loading...";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"得分: %@", dict[@"Score"]];
    
    if(dict[@"ExamId"]) {
        _examsIndexPath[dict[@"ExamId"]] = indexPath;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dict = _uploadedExams[indexPath.row];
        NSString *examID = dict[@"ExamId"];
        if(examID && [examID intValue] > 0) {
            NSString *examFolder = [FileUtils dirPath:ExamFolder];
            NSString *examPath = [NSString stringWithFormat:@"%@/%@.json", examFolder, examID];
            NSString *examDBPath = [NSString stringWithFormat:@"%@/%@.db", examFolder, examID];
            [FileUtils removeFile:examPath];
            [FileUtils removeFile:examDBPath];
            [_uploadedExams removeObjectAtIndex:indexPath.row];
            
            _examsIndexPath = [NSMutableDictionary dictionary];
            [self.tableView reloadData];
        }
        else {
            [ViewUtils showPopupView:self.view Info:@"请联系开发人员，考试ID不存在！"];
        }
    }
}
@end
