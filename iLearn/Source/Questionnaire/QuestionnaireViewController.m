//
//  QuestionnaireViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "QuestionnaireViewController.h"
#import "QuestionCollectionViewCell.h"
#import "QuestionOptionCell.h"
#import "Constants.h"
#import "LicenseUtil.h"
#import "QuestionnaireUtil.h"
#import "User.h"
#import "GroupSelectionView.h"
#import <MBProgressHUD.h>

static NSString *const kSubjectCollectionCellIdentifier = @"subjectCollectionViewCell";
static NSString *const kQuestionOptionCellIdentifier = @"QuestionAnswerCell";

typedef NS_ENUM(NSUInteger, CellStatus) {
    CellStatusNone,
    CellStatusAnswered,
    CellStatusCorrect,
    CellStatusWrong,
};

@interface QuestionnaireViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAccountTitle;
@property (weak, nonatomic) IBOutlet UILabel *userAccountLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightStatusLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *subjectCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *questionTableView;
@property (weak, nonatomic) IBOutlet UIView *questionTypeView;
@property (weak, nonatomic) IBOutlet UILabel *questionTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerTableViewHeightConstraint;

@property (strong, nonatomic) NSMutableArray *cellStatus;
@property (assign, nonatomic) NSUInteger selectedCellIndex;
@property (strong, nonatomic) NSMutableArray *selectedRowsOfSubject;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSDate *examEndDate;

@property (weak, nonatomic) IBOutlet UIView *fakeNavBarView;
@property (weak, nonatomic) IBOutlet UIView *squareView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerVIewHeightConstraint;
@property (nonatomic, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UITextView *fillTextView;
@property (weak, nonatomic) IBOutlet UILabel *textViewPlaceholderLabel;
@property (weak, nonatomic) GroupSelectionView *gridView;

@end

@implementation QuestionnaireViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.user = [[User alloc] init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Img_background"]]];

    _titleLabel.text = _questionnaireContent[QuestionnaireTitle];
    _typeLabel.text = NSLocalizedString(@"LIST_QUESTIONNAIRE", nil);
    _userAccountTitle.text = NSLocalizedString(@"COMMON_ACCOUNT", nil);
    _userAccountLabel.text = [LicenseUtil userAccount];
    _userNameTitle.text = NSLocalizedString(@"COMMON_NAME", nil);
    _userNameLabel.text = [LicenseUtil userName];

    [_questionTypeView.layer setCornerRadius:5.0];

    [self.submitButton setTitle:NSLocalizedString(@"COMMON_SUBMIT", nil) forState:UIControlStateNormal];

    // Setup CellStatus (answered, normal, correct, wrong...)
    self.cellStatus = [NSMutableArray array];
    for (NSDictionary *subject in _questionnaireContent[QuestionnaireQuestions]) {

        if ([subject[QuestionnaireQuestionAnswered] isEqualToNumber:@(1)]) {
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

    self.answerVIewHeightConstraint.constant = 704;

    _submitButton.layer.cornerRadius = 4;

    _fillTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _fillTextView.layer.borderWidth = 1.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *subjects = _questionnaireContent[QuestionnaireQuestions];
    return [subjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionCollectionViewCell *cell = (QuestionCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kSubjectCollectionCellIdentifier forIndexPath:indexPath];

    cell.numberLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];

    if (indexPath.row == _selectedCellIndex) {
        cell.backgroundColor = ILLightGreen;
        cell.numberLabel.textColor = [UIColor whiteColor];
    }
    else {
        cell.backgroundColor = [UIColor clearColor];

        if ([_cellStatus[indexPath.row] isEqualToNumber:@(CellStatusAnswered)]) {
            cell.numberLabel.textColor = ILLightGreen;
        }
        else {
            cell.numberLabel.textColor = ILLightGray;
        }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedQuestion = _questionnaireContent[QuestionnaireQuestions][_selectedCellIndex];
    NSArray *options = selectedQuestion[QuestionnaireQuestionOptions];
    NSDictionary *option = options[indexPath.row];
    NSString *title = option[QuestionnaireQuestionOptionTitle];

    return [self calculateOptionLabelHeightForText:title] + 10.0;
}

- (CGFloat)calculateOptionLabelHeightForText:(NSString*)text
{
    CGRect labelRect = [text boundingRectWithSize:CGSizeMake(570.0, CGFLOAT_MAX)
                                          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0]}
                                          context:nil];
    return labelRect.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *selectedQuestion = _questionnaireContent[QuestionnaireQuestions][_selectedCellIndex];
    NSArray *options = selectedQuestion[QuestionnaireQuestionOptions];
    return [options count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionOptionCell *cell = (QuestionOptionCell*)[tableView dequeueReusableCellWithIdentifier:kQuestionOptionCellIdentifier];

    NSDictionary *selectedQuestion = _questionnaireContent[QuestionnaireQuestions][_selectedCellIndex];
    NSArray *options = selectedQuestion[QuestionnaireQuestionOptions];
    NSDictionary *option = options[indexPath.row];

    cell.seqLabel.text = [NSString stringWithFormat:@"%c", (indexPath.row+1)+64];
    cell.titleLabel.text = option[QuestionnaireQuestionOptionTitle];

    if (tableView == _questionTableView) {
        // Set cell background color when answering
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = ILLightGreen;
        cell.selectedBackgroundView = backgroundView;

        if ([_selectedRowsOfSubject containsObject:@(indexPath.row)]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedRowsOfSubject addObject:@(indexPath.row)];
    [self updateSubjectsStatus];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedRowsOfSubject removeObject:@(indexPath.row)];
    [self updateSubjectsStatus];
}

#pragma mark - UI Adjustment

- (void)updateSelections
{
    self.selectedRowsOfSubject = [NSMutableArray array];

    NSArray *questions = _questionnaireContent[QuestionnaireQuestions];
    if (questions.count > 0) {
        NSDictionary *subject = questions[_selectedCellIndex];
        for (int i = 0; i<[subject[QuestionnaireQuestionOptions] count]; i++) {
            
            NSDictionary *option = subject[QuestionnaireQuestionOptions][i];
            BOOL selected = [option[QuestionnaireQuestionOptionSelected] integerValue];
            
            if (selected) {
                NSNumber *optionSeq = option[QuestionnaireQuestionOptionSeq];
                [_selectedRowsOfSubject addObject:optionSeq];
            }
        }
    }
}

- (void)showGridViewOfContent:(NSDictionary*)content
{
    GroupSelectionView *groupView = [[GroupSelectionView alloc] initWithFrame:CGRectMake(20, 100, 656, 600)];
    [self.questionView addSubview:groupView];
    [groupView setQuestionnaireData:content[QuestionnaireQuestions]];
    [groupView drawGrid];
    self.gridView = groupView;

    self.answerVIewHeightConstraint.constant = 1200;
    self.scrollView.scrollEnabled = YES;
}

- (void)updateOptionContents
{
    NSDictionary *selectedQuestion = _questionnaireContent[QuestionnaireQuestions][_selectedCellIndex];
    QuestionnaireQuestionTypes questionType = [selectedQuestion[QuestionnaireQuestionType] integerValue];

    [_gridView removeFromSuperview];
    [_scrollView setContentOffset:CGPointZero];

    if (questionType <= QuestionnaireQuestionsTypeEssay) {

        NSString *typeString;

        switch (questionType) {
            case QuestionnaireQuestionsTypeTrueFalse:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_TRUE_FALSE", Nil);
                _questionTableView.allowsMultipleSelection = NO;
                break;
            case QuestionnaireQuestionsTypeSingle:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_SINGLE", Nil);
                _questionTableView.allowsMultipleSelection = NO;
                break;
            case QuestionnaireQuestionsTypeMultiple:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_MULTIPLE", Nil);
                _questionTableView.allowsMultipleSelection = YES;
                break;
            case QuestionnaireQuestionsTypeFill:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_FILL", Nil);
                break;
            case QuestionnaireQuestionsTypeEssay:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_ESSAY", Nil);
                break;
            default:
                break;
        }
        
        _questionTypeLabel.text = typeString;

        NSString *questionTitle = selectedQuestion[QuestionnaireQuestionTitle];
        NSString *title = [NSString stringWithFormat:@"%d. %@", _selectedCellIndex+1, questionTitle];
        _questionTitleLabel.text = title;

        if (questionType <= QuestionnaireQuestionsTypeMultiple) {

            _questionTableView.hidden = NO;
            _fillTextView.hidden = YES;
            _textViewPlaceholderLabel.hidden = YES;

            [_questionTableView reloadData];

            CGFloat height = _questionTableView.contentSize.height;
            _answerTableViewHeightConstraint.constant = height;
        }
        else {
            _questionTableView.hidden = YES;
            _fillTextView.hidden = NO;

            NSString *filledAnswer = selectedQuestion[QuestionnaireQuestionFilledAnswer];

            if ([filledAnswer length] == 0) {
                _textViewPlaceholderLabel.hidden = NO;
                _fillTextView.text = @"";
            }
            else {
                _textViewPlaceholderLabel.hidden = YES;
                _fillTextView.text = filledAnswer;
            }

        }

        _answerVIewHeightConstraint.constant = 704.0;
        self.scrollView.scrollEnabled = NO;
    }
    else {

        NSDictionary *firstSubQuestion = [selectedQuestion[QuestionnaireQuestions] firstObject];
        QuestionnaireQuestionTypes firstSubQuestionType = [firstSubQuestion[QuestionnaireQuestionType] integerValue];

        NSString *typeString;

        switch (firstSubQuestionType) {
            case QuestionnaireQuestionsTypeTrueFalse:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_TRUE_FALSE", Nil);
                break;
            case QuestionnaireQuestionsTypeSingle:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_SINGLE", Nil);
                break;
            case QuestionnaireQuestionsTypeMultiple:
                typeString = NSLocalizedString(@"QUETIONNAIRE_TYPE_MULTIPLE", Nil);
                break;
            default:
                break;
        }

        _questionTypeLabel.text = typeString;

        NSString *questionTitle = selectedQuestion[QuestionnaireQuestionGroup];
        NSString *title = [NSString stringWithFormat:@"%d. %@", _selectedCellIndex+1, questionTitle];
        _questionTitleLabel.text = title;

        [self showGridViewOfContent:selectedQuestion];

        _questionTableView.hidden = YES;
        _fillTextView.hidden = YES;
        _textViewPlaceholderLabel.hidden = YES;
    }

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
    NSMutableDictionary *subject = _questionnaireContent[QuestionnaireQuestions][_selectedCellIndex];
    NSString *subjectId = subject[QuestionnaireQuestionId];
    NSString *fileName = _questionnaireContent[CommonFileName];
    QuestionnaireQuestionTypes questionType = [subject[QuestionnaireQuestionType] integerValue];
    NSString *dbPath = [QuestionnaireUtil questionnaireDBPathOfFile:fileName];

    if (questionType <= QuestionnaireQuestionsTypeMultiple) {
        for (int i = 0; i < [subject[QuestionnaireQuestionOptions] count]; i++) {

            NSMutableDictionary *option = subject[QuestionnaireQuestionOptions][i];
            NSString *optionId = option[QuestionnaireQuestionOptionId];

            BOOL selected = [_selectedRowsOfSubject containsObject:@(i)];

            option[QuestionnaireQuestionOptionSelected] = @(selected);
            [QuestionnaireUtil setOptionSelected:selected withQuestionId:subjectId optionId:optionId andDBPath:dbPath];
        }
    }
    else if (questionType <= QuestionnaireQuestionsTypeEssay) {

        NSString *textContent = _fillTextView.text;
        subject[QuestionnaireQuestionFilledAnswer] = textContent;
        [QuestionnaireUtil saveFilledAnswer:textContent withQuestionId:subjectId andDBPath:dbPath];
    }
    else {
        
    }

}

- (void)updateSubjectsStatus
{
    NSMutableDictionary *subject = _questionnaireContent[QuestionnaireQuestions][_selectedCellIndex];

    // Update collectionView cell status
    if ([_selectedRowsOfSubject count]) {
        _cellStatus[_selectedCellIndex] = @(CellStatusAnswered);
        subject[QuestionnaireQuestionAnswered] = @(1);
    }
    else {
        _cellStatus[_selectedCellIndex] = @(CellStatusNone);
        subject[QuestionnaireQuestionAnswered] = @(0);
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
    NSString *answeredNumberString = [NSString stringWithFormat:@"%lld", (long long)numberOfAnsweredSubjects];
    NSRange answeredNumberRange = [answeredString rangeOfString:answeredNumberString];
    NSRange answeredTextRange = NSMakeRange(0, answeredNumberRange.location);

    NSMutableAttributedString *answeredAttrString = [[NSMutableAttributedString alloc] initWithString:answeredString];
    [answeredAttrString setAttributes:@{NSForegroundColorAttributeName:ILDarkGray, NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} range:answeredTextRange];
    [answeredAttrString setAttributes:@{NSForegroundColorAttributeName:ILGreen, NSFontAttributeName:[UIFont boldSystemFontOfSize:20]} range:answeredNumberRange];

    _leftStatusLabel.attributedText = answeredAttrString;

    NSString *unansweredString = [NSString stringWithFormat:NSLocalizedString(@"EXAM_UNANSWERED_TEMPLATE", nil), numberOfSubjects-numberOfAnsweredSubjects];
    NSString *unansweredNumberString = [NSString stringWithFormat:@"%lld", (long long)(numberOfSubjects-numberOfAnsweredSubjects)];
    NSRange unansweredNumberRange = [unansweredString rangeOfString:unansweredNumberString];
    NSRange unansweredTextRange = NSMakeRange(0, unansweredNumberRange.location);

    NSMutableAttributedString *unansweredAttrString = [[NSMutableAttributedString alloc] initWithString:unansweredString];
    [unansweredAttrString setAttributes:@{NSForegroundColorAttributeName:ILDarkGray, NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} range:unansweredTextRange];
    [unansweredAttrString setAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:20]} range:unansweredNumberRange];

    _rightStatusLabel.attributedText = unansweredAttrString;
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
    NSIndexPath *originalIndex = [NSIndexPath indexPathForRow:_selectedCellIndex inSection:0];
    NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:index inSection:0];

    NSArray *reloadCollectionCells = @[originalIndex, nextIndex];

    [self saveSelections];
    self.selectedCellIndex = index;
    [self updateSelections];
    [self updateOptionContents];
    [_subjectCollectionView reloadItemsAtIndexPaths:reloadCollectionCells];
}

- (void)submit
{
    __weak QuestionnaireViewController *weakSelf = self;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"LIST_LOADING", nil);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [self saveSelections];

        NSString *fileName = _questionnaireContent[CommonFileName];
        NSString *dbPath = [QuestionnaireUtil questionnaireDBPathOfFile:fileName];

        [QuestionnaireUtil generateUploadJsonFromDBPath:dbPath];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EXAM_SCORE_TITLE", nil) message:@"SUCCESS" delegate:weakSelf cancelButtonTitle:NSLocalizedString(@"COMMON_OK", nil) otherButtonTitles:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [alert show];
        });
    });
}

#pragma mark - UIAction

- (IBAction)back:(id)sender {
    [self saveSelections];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backButtonTouched:(id)sender
{
    [self saveSelections];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nextButtonTouched:(id)sender
{
    NSInteger nextIndex = _selectedCellIndex + 1;
    if (nextIndex < [_cellStatus count]) {
        [self changeSubjectToIndex:nextIndex];
    }
}

- (IBAction)submitButtonTouched:(id)sender
{
    [self submit];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submit:(UIButton *)sender {
    [self submit];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        _textViewPlaceholderLabel.hidden = NO;
    }
    else {
        _textViewPlaceholderLabel.hidden = YES;
    }
}

@end
