//
//  DetailViewController.m
//  iLearn
//
//  Created by lijunjie on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "UploadExamViewController.h"
#import <AFNetworking.h>
#import "Constants.h"
#import "ExamUtil.h"
#import "LicenseUtil.h"


static NSString *const statusUploading  = @"成绩上传服务器中...";
static NSString *const resultUploading  = @"请等待";
static NSString *const statusUploaded   = @"成绩上传服务器成功";
static NSString *const resultUploaded   = @"请返回";
static NSString *const statusUploadFail = @"成绩上传服务器失败";
static NSString *const resultUploadFail = @"请返回后刷新重试或扫描二维码上传";
@interface UploadExamViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) ConnectionManager *connectionManager;

@end

@implementation UploadExamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.actionButton.layer setCornerRadius:15.0];
    [self.contentView.layer setBorderWidth:1.0];
    UIColor *borderColor = RGBCOLOR(190.0, 190.0, 190.0);
    [self.contentView.layer setBorderColor:borderColor.CGColor];
    
    self.connectionManager = [[ConnectionManager alloc] init];
    _connectionManager.delegate = self;
    
    self.scoreLabel.text     = self.examScoreString;
    self.statusLabel.text    = statusUploading;
    self.resultLabel.text    = resultUploading;
    self.statusLabel.hidden  = !self.isUploadExamResult;
    self.resultLabel.hidden  = !self.isUploadExamResult;
    self.actionButton.hidden = self.isUploadExamResult; // shown when upload exam result
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(self.isUploadExamResult) {
        NSString *docPath  = [self applicationDocumentsDirectory];
        NSString *examPath = [NSString stringWithFormat:@"%@/%@", docPath, ExamFolder];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.result", examPath, self.examID];
        [_connectionManager uploadExamResultWithPath:filePath];
    }
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark - ConnectionManagerDelegate

- (void)connectionManagerDidDownloadExamsForUser:(NSString *)userId withError:(NSError *)error {}

- (void)connectionManagerDidDownloadExam:(NSString *)examId withError:(NSError *)error {}

- (void)connectionManagerDidUploadExamResult:(NSString *)examId withError:(NSError *)error
{
    if (!error) {
        NSString *dbPath = [ExamUtil examDBPathOfFile:examId];
        [ExamUtil setExamSubmittedwithDBPath:dbPath];
        
        self.statusLabel.text = statusUploaded;
        self.resultLabel.text = resultUploaded;
    }
    else {
        self.statusLabel.text = statusUploadFail;
        self.resultLabel.text = resultUploadFail;
    }
    self.actionButton.hidden = NO;
}

- (void)connectionManagerDidUploadExamScannedResult:(NSString *)result withError:(NSError *)error {}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)actionTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(backToListView)]) {
            [self.delegate backToListView];
        }
    }];
}

@end
