//
//  ListTableViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ListTableViewController.h"
#import "QuestionnaireCell.h"
#import "DetailViewController.h"
#import "PasswordViewController.h"
#import "QuestionnaireUtil.h"
#import "SubjectViewController.h"
#import "ScoreQRCodeViewController.h"
#import "LicenseUtil.h"
#import "ExamUtil.h"
#import "UIImage+MDQRCode.h"
#import <MBProgressHUD.h>

static NSString *const kShowSubjectSegue = @"showSubjectPage";
static NSString *const kShowDetailSegue = @"showDetailPage";
static NSString *const kShowPasswordSegue = @"showPasswordPage";
static NSString *const kShowSettingsSegue = @"showSettingsPage";
static NSString *const kShowScoreQRCode = @"showScoreQRCode";

static NSString *const kQuestionnaireCellIdentifier = @"QuestionnaireCell";

@interface ListTableViewController ()

@property (strong, nonatomic) ConnectionManager *connectionManager;

@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@property (weak, nonatomic) IBOutlet UIButton *lectureButton;
@property (weak, nonatomic) IBOutlet UIButton *questionnaireButton;
@property (weak, nonatomic) IBOutlet UIButton *examButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (weak, nonatomic) IBOutlet UIImageView *avartarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceCallLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSArray *contents;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UIView *registrationView;
@property (weak, nonatomic) IBOutlet UIView *lectureView;
@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIView *examView;

@property (assign, nonatomic) BOOL hasAutoSynced;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (strong, nonatomic) NSMutableArray *unsubmittedExamResults;
@property (strong, nonatomic) NSMutableArray *unsubmittedExamScannedResults;

@end


@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _registrationButton.enabled = NO;
    _lectureButton.enabled = NO;
    _questionnaireButton.enabled = NO;
    _settingsButton.enabled = NO;

    // Setup avatar image view
    CGFloat width = _avatarImageView.frame.size.width;
    [_avatarImageView.layer setCornerRadius:width/2.0];
    [_avatarImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_avatarImageView.layer setBorderWidth:2.0];
    _avatarImageView.clipsToBounds = YES;

    _userNameLabel.text = [LicenseUtil userAccount];

    _serviceCallLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"DASHBOARD_SERVICE_CALL", nil), [LicenseUtil serviceNumber]];

    self.connectionManager = [[ConnectionManager alloc] init];
    _connectionManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshContent];

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

        DetailViewController *detailVC = (DetailViewController*)segue.destinationViewController;

        switch (_listType) {
            case ListViewTypeExam:
                detailVC.titleString = [[ExamUtil titleFromContent:sender] stringByAppendingString:NSLocalizedString(@"LIST_DETAIL", nil)];
                detailVC.descString = [ExamUtil descFromContent:sender];
                break;
            case ListViewTypeQuestionnaire:
                detailVC.titleString = [[QuestionnaireUtil titleFromContent:sender] stringByAppendingString:NSLocalizedString(@"LIST_DETAIL", nil)];
                detailVC.descString = [QuestionnaireUtil descFromContent:sender];
                break;
            default:
                detailVC.titleString = [[QuestionnaireUtil titleFromContent:sender] stringByAppendingString:NSLocalizedString(@"LIST_DETAIL", nil)];
                detailVC.descString = [QuestionnaireUtil descFromContent:sender];
                break;
        }
    }
    if ([segue.identifier isEqualToString:kShowPasswordSegue]) {

        PasswordViewController *detailVC = (PasswordViewController*)segue.destinationViewController;

        if (_listType == ListViewTypeExam) {
                detailVC.titleString = [[ExamUtil titleFromContent:sender] stringByAppendingString:NSLocalizedString(@"LIST_DETAIL", nil)];
                detailVC.descString = [ExamUtil descFromContent:sender];
                detailVC.password = sender[ExamPassword];
                __weak id weakSelf = self;
                detailVC.callback = ^(void){
                    [weakSelf enterExamPageForContent:sender];
                };
        }
    }
    else if ([segue.identifier isEqualToString:kShowSubjectSegue]) {
        UINavigationController *navController = segue.destinationViewController;
        UIViewController *viewController = navController.topViewController;

        if ([viewController isKindOfClass:[SubjectViewController class]]) {
            SubjectViewController *subjectVC = (SubjectViewController*)viewController;

            subjectVC.examContent = sender;
        }
    }
    else if ([segue.identifier isEqualToString:kShowScoreQRCode]) {

        ScoreQRCodeViewController *scoreQRCodeVC = segue.destinationViewController;
        scoreQRCodeVC.scoreQRCodeImage = sender;
    }
}

#pragma mark - UI Adjustment

- (void)syncData
{
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);

    self.unsubmittedExamResults = [[ExamUtil resultFiles] mutableCopy];
    self.unsubmittedExamScannedResults = [[ExamUtil unsubmittedScannedResults] mutableCopy];

    [self downloadExams];
    [self syncExamResults];
    [self syncScannedExamResults];
}

- (void)syncExamResults
{
    NSString *filePath = [_unsubmittedExamResults firstObject];

    if (filePath) {
        [_unsubmittedExamResults removeObjectAtIndex:0];
        [_connectionManager uploadExamResultWithPath:filePath];
    }
}

- (void)syncScannedExamResults
{
    NSString *scannedResult = [_unsubmittedExamScannedResults firstObject];

    if (scannedResult) {
        [_unsubmittedExamScannedResults removeObjectAtIndex:0];
        [_connectionManager uploadExamScannedResult:scannedResult];
    }
}

- (void)downloadExams
{
    [_connectionManager downloadExamsForUser:[LicenseUtil userId]];
}

- (void)downloadExamId:(NSString*)examId
{
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
    [_connectionManager downloadExamWithId:examId];
}

- (void)refreshContent
{
    switch (_listType) {
        case ListViewTypeExam:
            self.contents = [ExamUtil loadExams];
            self.titleLabel.text = NSLocalizedString(@"LIST_EXAM", nil);
            break;
        case ListViewTypeQuestionnaire:
            self.contents = [QuestionnaireUtil loadQuestionaires];
            self.titleLabel.text = NSLocalizedString(@"LIST_QUESTIONNAIRE", nil);
            break;
        default:
            self.contents = [QuestionnaireUtil loadQuestionaires];
            self.titleLabel.text = NSLocalizedString(@"LIST_QUESTIONNAIRE", nil);
            break;
    }

    [self adjustSelectedItemInPanel];
    [self.tableView reloadData];
}

- (void)adjustSelectedItemInPanel
{
    _examView.backgroundColor = [UIColor clearColor];
    _questionnaireView.backgroundColor = [UIColor clearColor];
    _lectureView.backgroundColor = [UIColor clearColor];
    _registrationView.backgroundColor = [UIColor clearColor];

    switch (_listType) {
        case ListViewTypeExam:
            _examView.backgroundColor = RGBCOLOR(26.0, 78.0, 132.0);
            break;
        case ListViewTypeLecture:
            _lectureView.backgroundColor = RGBCOLOR(26.0, 78.0, 132.0);
            break;
        case ListViewTypeQuestionnaire:
            _questionnaireView.backgroundColor = RGBCOLOR(26.0, 78.0, 132.0);
            break;
        case ListViewTypeRegistration:
            _registrationView.backgroundColor = RGBCOLOR(26.0, 78.0, 132.0);
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contents count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_listType) {
        case ListViewTypeExam:
            return [self tableView:tableView cellForExamRowAtIndexPath:indexPath];
            break;
        case ListViewTypeQuestionnaire:
            return [self tableView:tableView cellForQuestionnaireRowAtIndexPath:indexPath];
            break;
        default:
            return [self tableView:tableView cellForQuestionnaireRowAtIndexPath:indexPath];
            break;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForQuestionnaireRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionnaireCell *cell = [tableView dequeueReusableCellWithIdentifier:kQuestionnaireCellIdentifier];
    cell.delegate = self;

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

    cell.titleLabel.text = [QuestionnaireUtil titleFromContent:content];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    NSInteger epochTime = [QuestionnaireUtil expirationDateFromContent:content];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:epochTime];
    NSString *expirationDateString = [formatter stringFromDate:date];

    cell.expirationDateLabel.text = [NSString stringWithFormat:@"有效日期：%@", expirationDateString];

    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForExamRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionnaireCell *cell = [tableView dequeueReusableCellWithIdentifier:kQuestionnaireCellIdentifier];
    cell.delegate = self;

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

    cell.titleLabel.text = [ExamUtil titleFromContent:content];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    long long epochTime = [ExamUtil endDateFromContent:content];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:epochTime];
    NSString *endDateString = [formatter stringFromDate:endDate];

    cell.expirationDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LIST_END_DATE_TEMPLATE", nil), endDateString];

    cell.scoreTitleLabel.hidden = YES;
    cell.scoreLabel.hidden = YES;
    cell.qrCodeButton.hidden = YES;

    if ([content[ExamCached] isEqualToNumber:@1]) {

        NSDate *now = [NSDate date];
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[ExamUtil startDateFromContent:content]];
        NSInteger scoreInt = -1;

        if ([endDate laterDate:now] == now) { // Exam is ended

            NSNumber *score = content[ExamScore];

            if (score == nil || [score isEqualToNumber:@(-1)]) { // Not calculated score yet
                NSString *fileName = content[CommonFileName];
                NSString *dbPath = [ExamUtil examDBPathOfFile:fileName];

                scoreInt = [ExamUtil examScoreOfDBPath:dbPath];
                [ExamUtil generateExamUploadJsonOfDBPath:dbPath];
//                NSLog(@"score: %lld", (long long)scoreInt);
            }
        }

        cell.actionButton.enabled = YES;

        if ([startDate laterDate:now] == startDate) { // Exam is not started yet
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_STARTED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_START_TESTING", nil) forState:UIControlStateNormal];
            cell.actionButtonType = ListTableViewCellActionView;
        }
        else {
            NSNumber *score;

            if (scoreInt == -1) {
                score = content[ExamScore];
            }
            else {
                score = @(scoreInt);
            }

            if (score != nil && [score integerValue] != -1) {
                // Score was calculated, test was submitted but may not success

                NSNumber *submitted = content[ExamSubmitted];

                if ([submitted isEqualToNumber:@1]) {
                    cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_SUBMITTED", nil);
                }
                else {
                    cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_SUBMITTED", nil);
                    cell.qrCodeButton.hidden = NO;
                }
                [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_VIEW_RESULT", nil) forState:UIControlStateNormal];
                cell.actionButtonType = ListTableViewCellActionView;

                cell.scoreTitleLabel.hidden = NO;
                cell.scoreLabel.hidden = NO;

                cell.scoreTitleLabel.text = NSLocalizedString(@"LIST_SCORE_TITLE", nil);

                NSString *strScore = [NSString stringWithFormat:@"%lld", [score longLongValue]];
                NSString *scoreString = [NSString stringWithFormat:NSLocalizedString(@"LIST_SCORE_TEMPLATE", nil), [score longLongValue]];
                NSMutableAttributedString *scoreAttrString = [[NSMutableAttributedString alloc] initWithString:scoreString];
                NSRange scoreRange = [scoreString rangeOfString:strScore];
                [scoreAttrString addAttributes:@{NSForegroundColorAttributeName: RGBCOLOR(200.0, 0.0, 10.0)} range:scoreRange];
                cell.scoreLabel.attributedText = scoreAttrString;

                cell.qrCodeButton.titleLabel.text = NSLocalizedString(@"LIST_BUTTON_QRCODE", nil);
            }
            else {
                cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_TESTING", nil);
                [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_START_TESTING", nil) forState:UIControlStateNormal];
                cell.actionButtonType = ListTableViewCellActionView;
            }

        }
    }
    else {

        NSDate *now = [NSDate date];

        if ([endDate laterDate:now] == now) { // Exam is ended
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_ENDED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_ENDED", nil) forState:UIControlStateNormal];
            cell.actionButton.enabled = NO;
        }
        else {
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_DOWNLOADED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_DOWNLOAD", nil) forState:UIControlStateNormal];
            cell.actionButtonType = ListTableViewCellActionDownload;
        }
    }

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)didSelectInfoButtonOfCell:(ListTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSLog(@"didSelectInfoButtonOfCell:");
    NSLog(@"indexPath.row: %d", indexPath.row);

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kShowDetailSegue sender:content];
}

- (void)didSelectActionButtonOfCell:(ListTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSLog(@"didSelectActionButtonOfCell:");
    NSLog(@"indexPath.row: %d", indexPath.row);

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

        if (cell.actionButtonType == ListTableViewCellActionDownload) {

            NSString *examId = [NSString stringWithFormat:@"%@", content[ExamId]];
            [self downloadExamId:examId];
        }
        else if (cell.actionButtonType == ListTableViewCellActionView) {

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
}

- (void)didSelectQRCodeButtonOfCell:(ListTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSLog(@"didSelectQRCodeButtonOfCell:");
    NSLog(@"indexPath.row: %d", indexPath.row);

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

    NSString *examId = content[ExamId];
    NSNumber *examScore = content[ExamScore];
    NSString *userId = [LicenseUtil userId];

    NSString *qrCodeString = [NSString stringWithFormat:@"iLearn+%@+%@+%@", userId, examId, examScore];
    UIImage *qrCodeImage = [UIImage mdQRCodeForString:qrCodeString size:200.0];

    [self performSegueWithIdentifier:kShowScoreQRCode sender:qrCodeImage];
}

#pragma mark - IBAction

- (IBAction)logoButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registrationButtonTouched:(id)sender {
    NSLog(@"registrationButtonTouched");
    if (_listType == ListViewTypeRegistration) {
        return;
    }
    self.listType = ListViewTypeRegistration;
    [self refreshContent];
}

- (IBAction)lectureButtonTouched:(id)sender {
    NSLog(@"lectureButtonTouched");
    if (_listType == ListViewTypeLecture) {
        return;
    }
    self.listType = ListViewTypeLecture;
    [self refreshContent];
}

- (IBAction)questionnaireButtonTouched:(id)sender {
    NSLog(@"questionnaireButtonTouched");
    if (_listType == ListViewTypeQuestionnaire) {
        return;
    }
    self.listType = ListViewTypeQuestionnaire;
    [self refreshContent];
}

- (IBAction)examButtonTouched:(id)sender {
    NSLog(@"examButtonTouched");
    if (_listType == ListViewTypeExam) {
        return;
    }
    self.listType = ListViewTypeExam;
    [self refreshContent];
}

- (IBAction)settingsButtonTouched:(id)sender {
    NSLog(@"settingsButtonTouched");
    [self performSegueWithIdentifier:kShowSettingsSegue sender:nil];
}

- (IBAction)syncButtonTouched:(id)sender {
    NSLog(@"syncButtonTouched");
    [self syncData];
}

- (IBAction)scanButtonTouched:(id)sender {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *reader = nil;
        static dispatch_once_t onceToken;

        dispatch_once(&onceToken, ^{
            reader                        = [QRCodeReaderViewController new];
            reader.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        reader.delegate = self;

        [reader setCompletionWithBlock:^(NSString *resultAsString) {
            NSLog(@"Completion with result: %@", resultAsString);
        }];

        [self presentViewController:reader animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)enterExamPageForContent:(NSDictionary*)content
{
    [ExamUtil parseContentIntoDB:content];

    NSString *dbPath = [ExamUtil examDBPathOfFile:content[CommonFileName]];

    NSDictionary *dbContent = [ExamUtil examContentFromDBFile:dbPath];
    NSLog(@"dbContent: %@", [ExamUtil jsonStringOfContent:dbContent]);

    [self performSegueWithIdentifier:kShowSubjectSegue sender:dbContent];
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    NSArray *components = [result componentsSeparatedByString:@"+"];

    if ([components count] != 4 || ![components[0] isEqualToString:@"iLearn"]) {
        return;
    }

    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"LIST_SCORE_SCAN_RESULT_TEMPLATE", nil), components[1], components[2], components[3]];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LIST_SCORE_SCAN_RESULT", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"COMMON_CLOSE", nil) otherButtonTitles:nil];
    [alert show];

    NSString *savedResult = [@[components[1], components[2], components[3]] componentsJoinedByString:@"+"];

    [ExamUtil saveScannedResultIntoDB:savedResult];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - ConnectionManagerDelegate

- (void)connectionManagerDidDownloadExamsForUser:(NSString *)userId withError:(NSError *)error
{
    [_progressHUD hide:YES];

    if (!error) {
        [self refreshContent];
    }
}

- (void)connectionManagerDidDownloadExam:(NSString *)examId withError:(NSError *)error
{
    [_progressHUD hide:YES];

    if (!error) {
        [self refreshContent];
    }
}

- (void)connectionManagerDidUploadExamResult:(NSString *)examId withError:(NSError *)error
{
    if (!error) {
        NSString *dbPath = [ExamUtil examDBPathOfFile:examId];
        [ExamUtil setExamSubmittedwithDBPath:dbPath];

        [self refreshContent];
    }
    [self syncExamResults];
}

- (void)connectionManagerDidUploadExamScannedResult:(NSString *)result withError:(NSError *)error
{
    if (!error) {
        [ExamUtil setScannedResultSubmitted:result];
    }
    [self syncScannedExamResults];
}

@end
