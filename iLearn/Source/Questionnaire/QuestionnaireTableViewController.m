//
//  QuestionnaireTableViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/7/4.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "QuestionnaireTableViewController.h"
#import "QuestionnaireViewController.h"
#import "DetailViewController.h"
#import "ListViewController.h"
#import "LicenseUtil.h"
#import "QuestionnaireUtil.h"
#import <MBProgressHUD.h>

static NSString *const kShowSubjectSegue = @"showSubjectPage";
static NSString *const kShowDetailSegue = @"showDetailPage";

static NSString *const kQuestionnaireCellIdentifier = @"QuestionnaireCell";

@interface QuestionnaireTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ConnectionManager *connectionManager;

@property (strong, nonatomic) NSArray *contents;

@property (assign, nonatomic) BOOL hasAutoSynced;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (strong, nonatomic) NSMutableArray *unsubmittedQuestionnaireResults;

@end


@implementation QuestionnaireTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

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
        detailVC.titleString = [[QuestionnaireUtil titleFromContent:sender] stringByAppendingString:NSLocalizedString(@"LIST_DETAIL", nil)];
        detailVC.descString = [QuestionnaireUtil descFromContent:sender];
    }
    else if ([segue.identifier isEqualToString:kShowSubjectSegue]) {

        UIViewController *viewController = segue.destinationViewController;

        if ([viewController isKindOfClass:[QuestionnaireViewController class]]) {
            QuestionnaireViewController *subjectVC = (QuestionnaireViewController*)viewController;
            subjectVC.questionnaireContent = sender;
        }
    }
}

#pragma mark - UI Adjustment

- (void)syncData
{
//    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
//    _progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
//
//    self.unsubmittedQuestionnaireResults = [[QuestionnaireUtil resultFiles] mutableCopy];
//
//    [self downloadQuestionnaires];
//    [self syncQuestionnaireResults];
}

- (void)syncQuestionnaireResults
{
//    NSString *filePath = [_unsubmittedQuestionnaireResults firstObject];
//
//    if (filePath) {
//        [_unsubmittedQuestionnaireResults removeObjectAtIndex:0];
//        [_connectionManager uploadQuestionnaireResultWithPath:filePath];
//    }
}

- (void)downloadQuestionnaires
{
//    [_connectionManager downloadQuestionnairesForUser:[LicenseUtil userId]];
}

- (void)downloadQuestionnaireId:(NSString*)examId
{
//    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
//    _progressHUD.labelText = NSLocalizedString(@"LIST_SYNCING", nil);
//    [_connectionManager downloadQuestionnaireWithId:examId];
}

- (void)refreshContent
{
    self.contents = [QuestionnaireUtil loadQuestionaires];
    [self.tableView reloadData];
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
    return [self tableView:tableView cellForQuestionnaireRowAtIndexPath:indexPath];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForQuestionnaireRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionnaireTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQuestionnaireCellIdentifier];
    cell.delegate = self;

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

    cell.titleLabel.text = [QuestionnaireUtil titleFromContent:content];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    long long epochTime = [QuestionnaireUtil endDateFromContent:content];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:epochTime];
    NSString *endDateString = [formatter stringFromDate:endDate];

    cell.expirationDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LIST_END_DATE_TEMPLATE", nil), endDateString];

    if ([content[QuestionnaireCached] isEqualToNumber:@1]) {

        NSDate *now = [NSDate date];
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[QuestionnaireUtil startDateFromContent:content]];

        NSDate *questionnaireStartDate = nil;
        NSDate *questionnaireEndDate = nil;

        if (content[QuestionnaireQuestionnaireStart]) {
            questionnaireStartDate = [NSDate dateWithTimeIntervalSince1970:[content[QuestionnaireQuestionnaireStart] longLongValue]];
        }

        if (content[QuestionnaireQuestionnaireEnd]) {
            questionnaireEndDate = [NSDate dateWithTimeIntervalSince1970:[content[QuestionnaireQuestionnaireEnd] longLongValue]];
        }

        cell.actionButton.enabled = YES;

        if ([startDate laterDate:now] == startDate) { // Questinnare is not started yet
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_STARTED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_START_ANSWER", nil) forState:UIControlStateNormal];
            cell.actionButtonType = ContentTableViewCellActionView;
        }
        else if ([endDate laterDate:now] == now && questionnaireEndDate == nil) { // Questinnare is ended and not start answering
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_ENDED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_ENDED", nil) forState:UIControlStateNormal];
            cell.actionButton.enabled = NO;
        }
        else { // Questinnare is started

            BOOL finished = [content[QuestionnaireFinished] boolValue];

            if (finished) {
                // Questinnare is completed

                NSNumber *submitted = content[ExamSubmitted];

                if ([submitted isEqualToNumber:@1]) {
                    cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_SUBMITTED", nil);
                }
                else {
                    cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_SUBMITTED", nil);
                }
                [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_VIEW_RESULT", nil) forState:UIControlStateNormal];
                cell.actionButtonType = ContentTableViewCellActionView;
            }
            else {
                // Not start testing or testing
                cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_ON_GOING", nil);
                [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_START_ANSWER", nil) forState:UIControlStateNormal];
                cell.actionButtonType = ContentTableViewCellActionView;
            }
        }
    }
    else {

        NSDate *now = [NSDate date];

        if ([endDate laterDate:now] == now) { // Questinnare is ended
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_ENDED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_ENDED", nil) forState:UIControlStateNormal];
            cell.actionButton.enabled = NO;
        }
        else {
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_DOWNLOADED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_DOWNLOAD", nil) forState:UIControlStateNormal];
            cell.actionButtonType = ContentTableViewCellActionDownload;
        }
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
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSLog(@"didSelectInfoButtonOfCell:");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:kShowDetailSegue sender:content];
}

- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSLog(@"didSelectActionButtonOfCell:");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

    if (cell.actionButtonType == ContentTableViewCellActionDownload) {

        NSString *questionnaireId = [NSString stringWithFormat:@"%@", content[QuestionnaireId]];
        [self downloadQuestionnaireId:questionnaireId];
    }
    else if (cell.actionButtonType == ContentTableViewCellActionView) {
        [self enterQuestoinnairePageForContent:content];
    }
}

#pragma mark - IBAction

- (void)enterQuestoinnairePageForContent:(NSDictionary*)content
{
    __weak QuestionnaireTableViewController *weakSelf = self;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.listViewController.view animated:YES];
    hud.labelText = NSLocalizedString(@"LIST_LOADING", nil);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [QuestionnaireUtil parseContentIntoDB:content];

        NSString *dbPath = [QuestionnaireUtil questionnaireDBPathOfFile:content[CommonFileName]];

        NSDictionary *dbContent = [QuestionnaireUtil contentFromDBFile:dbPath];
        NSLog(@"dbContent: %@", [QuestionnaireUtil jsonStringOfContent:dbContent]);

        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
//            [weakSelf performSegueWithIdentifier:kShowSubjectSegue sender:dbContent];
        });
    });
}

#pragma mark - ConnectionManagerDelegate

- (void)connectionManagerDidDownloadQuestionnairesForUser:(NSString *)userId withError:(NSError *)error
{
    [_progressHUD hide:YES];

    if (!error) {
        [self refreshContent];
    }
}

- (void)connectionManagerDidDownloadQuestionnaire:(NSString *)questionnaireId withError:(NSError *)error
{
    [_progressHUD hide:YES];

    if (!error) {
        [self refreshContent];
    }
}

- (void)connectionManagerDidUploadQuestionnaireResult:(NSString *)questionnaireId withError:(NSError *)error
{
    if (!error) {
        NSString *dbPath = [QuestionnaireUtil questionnaireDBPathOfFile:questionnaireId];
        [QuestionnaireUtil setQuestionnaireSubmittedwithDBPath:dbPath];

        [self refreshContent];
    }
    [self syncQuestionnaireResults];
}

@end
