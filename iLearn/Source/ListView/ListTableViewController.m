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
#import "QuestionnaireUtil.h"
#import "SubjectViewController.h"
#import "LicenseUtil.h"
#import "ExamUtil.h"

static NSString *const kShowSubjectSegue = @"showSubjectPage";
static NSString *const kShowDetailSegue = @"showDetailPage";
static NSString *const kShowSettingsSegue = @"showSettingsPage";

static NSString *const kQuestionnaireCellIdentifier = @"QuestionnaireCell";

@interface ListTableViewController ()

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

@end


@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // Setup avatar image view
    CGFloat width = _avatarImageView.frame.size.width;
    [_avatarImageView.layer setCornerRadius:width/2.0];
    [_avatarImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_avatarImageView.layer setBorderWidth:2.0];
    _avatarImageView.clipsToBounds = YES;

    _userNameLabel.text = [LicenseUtil userAccount];

    _serviceCallLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"DASHBOARD_SERVICE_CALL", nil), [LicenseUtil serviceNumber]];

    [self refreshContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshContent];
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
    else if ([segue.identifier isEqualToString:kShowSubjectSegue]) {
        UINavigationController *navController = segue.destinationViewController;
        UIViewController *viewController = navController.topViewController;

        if ([viewController isKindOfClass:[SubjectViewController class]]) {
            SubjectViewController *subjectVC = (SubjectViewController*)viewController;

            subjectVC.examContent = sender;
        }

    }

}

#pragma mark - UI Adjustment

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
    NSInteger epochTime = [ExamUtil expirationDateFromContent:content];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:epochTime];
    NSString *expirationDateString = [formatter stringFromDate:date];

    cell.expirationDateLabel.text = [NSString stringWithFormat:@"有效日期：%@", expirationDateString];

    if ([content[ExamCached] isEqualToNumber:@1]) {

        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[ExamUtil startDateFromContent:content]];
        NSDate *now = [NSDate date];

        if ([startDate laterDate:now] == startDate) { // Exam is not start yet
            cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_STARTED", nil);
            [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_NOT_STARTDED", nil) forState:UIControlStateNormal];
            cell.actionButton.enabled = NO;
        }
        else {
            NSNumber *score = content[ExamScore];

            if (score != nil && [score integerValue] != -1) {
                // Score was calculated, test was submitted but may not success

                NSNumber *submitted = content[ExamSubmitted];

                if ([submitted isEqualToNumber:@1]) {
                    cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_SUBMITTED", nil);
                    [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_VIEW_RESULT", nil) forState:UIControlStateNormal];
                }
                else {
                    cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_SUBMITTED", nil);
                    [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_SUBMIT", nil) forState:UIControlStateNormal];
                }

            }
            else {
                cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_TESTING", nil);
                [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_START_TESTING", nil) forState:UIControlStateNormal];
            }

        }
    }
    else {
        cell.statusLabel.text = NSLocalizedString(@"LIST_STATUS_NOT_DOWNLOADED", nil);
        [cell.actionButton setTitle:NSLocalizedString(@"LIST_BUTTON_DOWNLOAD", nil) forState:UIControlStateNormal];
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
    [self enterExamPageForContent:content];
}

#pragma mark - IBAction

- (IBAction)logoButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registrationButtonTouched:(id)sender {
    NSLog(@"registrationButtonTouched");
    self.listType = ListViewTypeRegistration;
    [self refreshContent];
}

- (IBAction)lectureButtonTouched:(id)sender {
    NSLog(@"lectureButtonTouched");
    self.listType = ListViewTypeLecture;
    [self refreshContent];
}

- (IBAction)questionnaireButtonTouched:(id)sender {
    NSLog(@"questionnaireButtonTouched");
    self.listType = ListViewTypeQuestionnaire;
    [self refreshContent];
}

- (IBAction)examButtonTouched:(id)sender {
    NSLog(@"examButtonTouched");
    self.listType = ListViewTypeExam;
    [self refreshContent];
}

- (IBAction)settingsButtonTouched:(id)sender {
    NSLog(@"settingsButtonTouched");
    [self performSegueWithIdentifier:kShowSettingsSegue sender:nil];
}

- (IBAction)syncButtonTouched:(id)sender {
    NSLog(@"syncButtonTouched");
}

- (void)enterExamPageForContent:(NSDictionary*)content
{
    [ExamUtil parseContentIntoDB:content];

    NSString *dbPath = [ExamUtil examDBPathOfFile:content[CommonFileName]];

    NSDictionary *dbContent = [ExamUtil examContentFromDBFile:dbPath];
    NSLog(@"dbContent: %@", [ExamUtil jsonStringOfContent:dbContent]);

    [self performSegueWithIdentifier:kShowSubjectSegue sender:dbContent];
}

@end
