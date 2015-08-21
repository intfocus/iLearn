//
//  UploadQuestionnaireViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/8/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "UploadQuestionnaireViewController.h"
#import "Constants.h"
#import "QuestionnaireUtil.h"
#import "LicenseUtil.h"

static NSString *const statusUploading  = @"问卷上传服务器中...";
static NSString *const resultUploading  = @"请等待";
static NSString *const statusUploaded   = @"问卷上传服务器成功";
static NSString *const resultUploaded   = @"感谢您的反馈\n您的建议是我们前行的动力！";
static NSString *const statusUploadFail = @"问卷上传服务器失败";
static NSString *const resultUploadFail = @"请返回后刷新重试";

@interface UploadQuestionnaireViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) ConnectionManager *connectionManager;

@end

@implementation UploadQuestionnaireViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.actionButton.layer setCornerRadius:15.0];
    [self.contentView.layer setBorderWidth:1.0];
    UIColor *borderColor = RGBCOLOR(190.0, 190.0, 190.0);
    [self.contentView.layer setBorderColor:borderColor.CGColor];
    
    self.connectionManager = [[ConnectionManager alloc] init];
    _connectionManager.delegate = self;

    self.statusLabel.text    = statusUploading;
    self.resultLabel.text    = resultUploading;
    self.actionButton.hidden = YES; // show after uploading questionnaire result
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *questionnairePath = [QuestionnaireUtil questionnaireFolderPathInDocument];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.result", questionnairePath, self.questionnaireID];
    [_connectionManager uploadQuestionnaireResultWithPath:filePath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ConnectionManagerDelegate

- (void)connectionManagerDidUploadQuestionnaireResult:(NSString*)questionnaireId withError:(NSError *)error
{
    if (!error) {
        NSString *dbPath = [QuestionnaireUtil questionnaireDBPathOfFile:questionnaireId];
        [QuestionnaireUtil setQuestionnaireSubmittedwithDBPath:dbPath];
        
        self.statusLabel.text = statusUploaded;
        self.resultLabel.text = resultUploaded;
    }
    else {
        self.statusLabel.text = statusUploadFail;
        self.resultLabel.text = resultUploadFail;
    }
    self.actionButton.hidden = NO;
}

#pragma mark - IBAction

- (IBAction)closeTouched:(id)sender {

    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(backToListView)]) {
            [self.delegate backToListView];
        }
    }];
}

- (IBAction)actionTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(backToListView)]) {
            [self.delegate backToListView];
        }
    }];
}

@end
