//
//  SubjectViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "SubjectViewController.h"
#import "SubjectCollectionViewCell.h"
#import "QuestionOptionCell.h"
#import "Constants.h"
#import "ExamUtil.h"

static NSString *const kSubjectCollectionCellIdentifier = @"subjectCollectionViewCell";

static NSString *const kQuestionOptionCellIdentifier = @"QuestionAnswerCell";

typedef NS_ENUM(NSUInteger, CellStatus) {
    CellStatusNone,
    CellStatusAnswered,
    CellStatusCorrect,
    CellStatusWrong,
};


@interface SubjectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightStatusLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *subjectCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;


@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *questionTableView;

@property (weak, nonatomic) IBOutlet UIView *correctionView;
@property (weak, nonatomic) IBOutlet UILabel *correctionTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *correctionTableView;
@property (weak, nonatomic) IBOutlet UILabel *correctionNoteLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionToCorrectionSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *correctionTableViewHeightConstraint;

@property (strong, nonatomic) NSMutableArray *cellStatus;
@property (assign, nonatomic) NSUInteger selectedCellIndex;
@property (strong, nonatomic) NSMutableArray *selectedRowsOfSubject;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSString *titleString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"DASHBOARD_QUESTIONNAIRE", nil), NSLocalizedString(@"COMMON_CONTENT", nil)];
    self.title = titleString;

    [self.submitButton setTitle:NSLocalizedString(@"COMMON_SUBMIT", nil) forState:UIControlStateNormal];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Img_background"]]];

    // Setup CellStatus (answered, normal, correct, wrong...)
    self.cellStatus = [NSMutableArray array];
    for (NSDictionary *subject in _examContent[ExamQuestions]) {

        if ([subject[ExamQuestionAnswered] isEqualToNumber:@(1)]) {
            [_cellStatus addObject:@(CellStatusAnswered)];
        }
        else {
            [_cellStatus addObject:@(CellStatusNone)];
        }
    }
    [self updateStringLabels];
    [self updateSubmitButtonStatus];

    self.selectedCellIndex = 0;
    [self updateSelections];
    [self updateOptionContents];

    BOOL isCorrectionHidden = NO;

    if (isCorrectionHidden) {
        CGFloat correctionViewHeight = _correctionView.frame.size.height;

        _correctionView.hidden = YES;
        _questionToCorrectionSpaceConstraint.constant = -correctionViewHeight;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *subjects = _examContent[ExamQuestions];
    return [subjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SubjectCollectionViewCell *cell = (SubjectCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kSubjectCollectionCellIdentifier forIndexPath:indexPath];

    cell.numberLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
    cell.numberLabel.textColor = [UIColor blackColor];

    if ([_cellStatus[indexPath.row] isEqualToNumber:@(CellStatusAnswered)]) {
        cell.backgroundColor = RGBCOLOR(27.0, 165.0, 158.0);
        cell.numberLabel.textColor = [UIColor whiteColor];
    }
    else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != _selectedCellIndex) {
        [self changeSubjectToIndex:indexPath.row];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *selectedQuestion = _examContent[ExamQuestions][_selectedCellIndex];
    NSArray *options = selectedQuestion[ExamQuestionOptions];
    return [options count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionOptionCell *cell = (QuestionOptionCell*)[tableView dequeueReusableCellWithIdentifier:kQuestionOptionCellIdentifier];

    NSDictionary *selectedQuestion = _examContent[ExamQuestions][_selectedCellIndex];
    NSArray *options = selectedQuestion[ExamQuestionOptions];
    NSDictionary *option = options[indexPath.row];

    cell.seqLabel.text = [NSString stringWithFormat:@"%c", (indexPath.row+1)+64];
    cell.titleLabel.text = option[ExamQuestionOptionTitle];

    // Set cell background color when answering
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = RGBCOLOR(27.0, 165.0, 158.0);
    cell.selectedBackgroundView = backgroundView;

    if (tableView == _questionTableView && [_selectedRowsOfSubject containsObject:@(indexPath.row)]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

    // Set cell background color when correcting
    NSArray *answersBySeq = selectedQuestion[ExamQuestionAnswerBySeq];
    if (tableView == _questionTableView) {

    }
    else if (tableView == _correctionTableView) {
        if ([answersBySeq containsObject:@(indexPath.row)]) {
            cell.backgroundColor = RGBCOLOR(27.0, 165.0, 158.0);
        }
        else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    [_selectedRowsOfSubject addObject:@(indexPath.row)];
    [self updateSubjectsStatus];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectRowAtIndexPath");
    [_selectedRowsOfSubject removeObject:@(indexPath.row)];
    [self updateSubjectsStatus];
}

#pragma mark - UI Adjustment

- (void)updateSelections
{
    self.selectedRowsOfSubject = [NSMutableArray array];

    NSDictionary *subject = _examContent[ExamQuestions][_selectedCellIndex];

    for (int i = 0; i<[subject[ExamQuestionOptions] count]; i++) {

        NSDictionary *option = subject[ExamQuestionOptions][i];
        BOOL selected = [option[ExamQuestionOptionSelected] integerValue];

        if (selected) {
            NSNumber *optionSeq = option[ExamQuestionOptionSeq];
            [_selectedRowsOfSubject addObject:optionSeq];
        }
    }
}

- (void)updateOptionContents
{
    NSDictionary *selectedQuestion = _examContent[ExamQuestions][_selectedCellIndex];
    NSString *questionTitle = selectedQuestion[ExamQuestionTitle];
    NSString *title = [NSString stringWithFormat:@"%d.  %@", _selectedCellIndex+1, questionTitle];

    _questionTitleLabel.text = title;
    _correctionTitleLabel.text = title;

    NSArray *answersBySeq = selectedQuestion[ExamQuestionAnswerBySeq];
    NSMutableString *answerString = [NSMutableString string];
    for (NSNumber *seq in answersBySeq) {
        [answerString appendString:[NSString stringWithFormat:@"%c", ([seq integerValue] + 1) + 64]];
    }

    NSString *correctionNote = selectedQuestion[ExamQuestionNote];
    NSString *correctionString = [NSString stringWithFormat:NSLocalizedString(@"EXAM_CORRECTION_TEMPLATE", nil), answerString, correctionNote];

    _correctionNoteLabel.text = correctionString;

    [_questionTableView reloadData];
    [_correctionTableView reloadData];

    CGFloat height = _questionTableView.contentSize.height;
    _answerTableViewHeightConstraint.constant = height;
    _correctionTableViewHeightConstraint.constant = height;

    _nextButton.hidden = _selectedCellIndex == [_cellStatus count]-1? YES: NO;
}

- (void)updateSubmitButtonStatus
{
    for (NSNumber *status in _cellStatus) {
        if ([status isEqualToNumber:@(CellStatusNone)]) {
            _submitButton.hidden = YES;
            return;
        }
    }
    _submitButton.hidden = NO;
}

- (void)saveSelections
{
    NSMutableDictionary *subject = _examContent[ExamQuestions][_selectedCellIndex];
    NSString *subjectId = subject[ExamQuestionId];
    NSString *fileName = _examContent[CommonFileName];

    for (int i = 0; i<[subject[ExamQuestionOptions] count]; i++) {

        NSMutableDictionary *option = subject[ExamQuestionOptions][i];
        NSString *optionId = option[ExamQuestionOptionId];

        NSString *dbPath = [ExamUtil examDBPathOfFile:fileName];

        BOOL selected = [_selectedRowsOfSubject containsObject:@(i)];

        option[ExamQuestionOptionSelected] = @(selected);
        [ExamUtil setOptionSelected:selected withSubjectId:subjectId optionId:optionId andDBPath:dbPath];
    }
}

- (void)updateSubjectsStatus
{
    NSMutableDictionary *subject = _examContent[ExamQuestions][_selectedCellIndex];

    // Update collectionView cell status
    if ([_selectedRowsOfSubject count]) {
        _cellStatus[_selectedCellIndex] = @(CellStatusAnswered);
        subject[ExamQuestionAnswered] = @(1);
    }
    else {
        _cellStatus[_selectedCellIndex] = @(CellStatusNone);
        subject[ExamQuestionAnswered] = @(0);
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedCellIndex inSection:0];
    [_subjectCollectionView reloadItemsAtIndexPaths:@[indexPath]];

    // Update answered/unanswered status
    [self updateStringLabels];
    [self updateSubmitButtonStatus];
}

- (void)updateStringLabels
{
    NSInteger numberOfSubjects = [_cellStatus count];
    NSInteger numberOfAnsweredSubjects = [self numberOfAnsweredSubjects];

    NSString *answeredString = [NSString stringWithFormat:NSLocalizedString(@"EXAM_ANSWERED_TEMPLATE", nil), numberOfAnsweredSubjects];
    _leftStatusLabel.text = answeredString;

    NSString *unansweredString = [NSString stringWithFormat:NSLocalizedString(@"EXAM_UNANSWERED_TEMPLATE", nil), numberOfSubjects-numberOfAnsweredSubjects];
    _rightStatusLabel.text = unansweredString;
}

- (NSInteger)numberOfAnsweredSubjects
{
    NSInteger numberOfAnsweredSubjects = 0;

    for (NSNumber *status in _cellStatus) {
        if ([status isEqualToNumber:@(CellStatusAnswered)]) {
            numberOfAnsweredSubjects++;
        }
    }
    return numberOfAnsweredSubjects;
}

- (void)changeSubjectToIndex:(NSInteger)index
{
    [self saveSelections];
    self.selectedCellIndex = index;
    [self updateSelections];
    [self updateOptionContents];
}

#pragma mark - UIAction

- (IBAction)logoButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonTouched:(id)sender
{
    NSInteger nextIndex = _selectedCellIndex + 1;
    if (nextIndex < [_cellStatus count]) {
        [self changeSubjectToIndex:nextIndex];
    }
}

- (IBAction)submitButtonTouched:(id)sender {
    [self saveSelections];

    NSString *fileName = _examContent[CommonFileName];
    NSString *dbPath = [ExamUtil examDBPathOfFile:fileName];

    [ExamUtil setExamSubmittedwithDBPath:dbPath];
    NSInteger score = [ExamUtil examScoreOfDBPath:dbPath];

    NSLog(@"score: %lld", (long long)score);
}

@end
