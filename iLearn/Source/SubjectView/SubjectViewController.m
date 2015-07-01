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
#import "LicenseUtil.h"
#import "ExamUtil.h"
#import "User.h"
#import <MBProgressHUD.h>

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
@property (weak, nonatomic) IBOutlet UIView *correctionView;
@property (weak, nonatomic) IBOutlet UILabel *correctionTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *correctionTableView;
@property (weak, nonatomic) IBOutlet UILabel *correctionNoteLabel;
@property (weak, nonatomic) IBOutlet UIView *correctionTypeView;
@property (weak, nonatomic) IBOutlet UILabel *correctionTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionToCorrectionSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *correctionTableViewHeightConstraint;

@property (strong, nonatomic) NSMutableArray *cellStatus;
@property (assign, nonatomic) NSUInteger selectedCellIndex;
@property (strong, nonatomic) NSMutableArray *selectedRowsOfSubject;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSDate *examEndDate;
@property (strong, nonatomic) NSTimer *timeLeftTimer;
@property (strong, nonatomic) NSTimer *timeOutTimer;

@property (assign, nonatomic) BOOL isAnswerMode; //答案模式

@property (weak, nonatomic) IBOutlet UIView *fakeNavBarView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton2;
@property (weak, nonatomic) IBOutlet UIView *squareView;

@property (weak, nonatomic) IBOutlet UIView *countDownView;
@property (weak, nonatomic) IBOutlet UILabel *countDownHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *countDownMinuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *countDownSecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *examQuestionCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *examQuestionScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *examQuestionTitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countDownViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *correctionVIewButtonContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *correctionViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *answerVIewHeightConstraint;
@property (nonatomic, nonatomic) User *user;

@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.user = [[User alloc] init];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Img_background"]]];

    _titleLabel.text = _examContent[ExamTitle];
    _typeLabel.text = NSLocalizedString(@"LIST_EXAM", nil);
    _userAccountTitle.text = NSLocalizedString(@"COMMON_ACCOUNT", nil);
    _userAccountLabel.text = [LicenseUtil userAccount];
    _userNameTitle.text = NSLocalizedString(@"COMMON_NAME", nil);
    _userNameLabel.text = [LicenseUtil userName];

    [_questionTypeView.layer setCornerRadius:5.0];
    [_correctionTypeView.layer setCornerRadius:5.0];

    NSNumber *score = _examContent[ExamScore];

    ExamTypes examType = [_examContent[ExamType] integerValue];

    if (score != nil && [score integerValue] != -1) {
        self.isAnswerMode = YES;
        _questionTableView.userInteractionEnabled = NO;
    }
    else if (examType == ExamTypesPractice) {
        self.isAnswerMode = NO;
    }
    else {
        self.isAnswerMode = NO;

        NSNumber *endTime = _examContent[ExamExamEnd];

        if (endTime) {

            self.examEndDate = [NSDate dateWithTimeIntervalSince1970:[endTime longLongValue]];

            [self updateTimeLeft];

            self.timeLeftTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLeft) userInfo:nil repeats:YES];

            NSTimeInterval timeLeft = [_examEndDate timeIntervalSinceNow];

            self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:timeLeft target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
        }
    }

    [self.submitButton setTitle:NSLocalizedString(@"COMMON_SUBMIT", nil) forState:UIControlStateNormal];

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

    if (!_isAnswerMode) { // Hide the answer view
        _correctionView.hidden = YES;
        self.scrollView.scrollEnabled = NO;
        self.answerVIewHeightConstraint.constant = 704;
    }
    else {
        self.countDownViewHeightConstraint.constant = 0;
        self.squareView.backgroundColor = ILDarkRed;
    }
    
    self.submitButton2.layer.cornerRadius = 4;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.examQuestionCountLabel.text = [NSString stringWithFormat:@"%ld", (long)[_examContent[ExamQuestions] count]];
    NSString *examQuestionScore, *examQuestionTitle;
    if([_examContent[ExamScore] intValue] < 0) {
        examQuestionScore = @"100";
        examQuestionTitle = @"试题总分";
    } else {
        examQuestionScore = [NSString stringWithFormat:@"%@", _examContent[ExamScore]];
        examQuestionTitle = @"考试得分";
    }
    self.examQuestionScoreLabel.text = examQuestionScore;
    self.examQuestionTitleLabel.text = examQuestionTitle;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

    if (_isAnswerMode) {

        NSDictionary *subjectContent = _examContent[ExamQuestions][indexPath.row];
        
        if (indexPath.row == _selectedCellIndex) {

            cell.backgroundColor = ILDarkRed;
            cell.numberLabel.textColor = [UIColor whiteColor];
            if ([subjectContent[ExamQuestionCorrect] isEqualToNumber:@1]) {
                cell.backgroundColor = ILLightGreen;
            }
            else {
                cell.backgroundColor = ILDarkRed;
            }
        }
        else {
            cell.backgroundColor = [UIColor clearColor];
            if ([subjectContent[ExamQuestionCorrect] isEqualToNumber:@1]) {
                cell.numberLabel.textColor = ILLightGreen;
            }
            else {
                cell.numberLabel.textColor = ILDarkRed;
            }
        }
    }
    else {
        
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
    NSDictionary *selectedQuestion = _examContent[ExamQuestions][_selectedCellIndex];
    NSArray *options = selectedQuestion[ExamQuestionOptions];
    NSDictionary *option = options[indexPath.row];
    NSString *title = option[ExamQuestionOptionTitle];

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

    if (tableView == _questionTableView) {
        // Set cell background color when answering
        UIView *backgroundView = [UIView new];

        BOOL correct = [selectedQuestion[ExamQuestionCorrect] boolValue];

        if (_isAnswerMode && !correct) {
            backgroundView.backgroundColor = ILDarkRed;
        }
        else {
            backgroundView.backgroundColor = ILLightGreen;
        }
        cell.selectedBackgroundView = backgroundView;

        if ([_selectedRowsOfSubject containsObject:@(indexPath.row)]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else if (tableView == _correctionTableView) {
        // Set cell background color of correction
        NSArray *answersBySeq = selectedQuestion[ExamQuestionAnswerBySeq];

        if ([answersBySeq containsObject:@(indexPath.row)]) {
            cell.backgroundColor = ILLightGreen;
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

    NSArray *questions = _examContent[ExamQuestions];
    if (questions.count > 0) {
        NSDictionary *subject = questions[_selectedCellIndex];
        for (int i = 0; i<[subject[ExamQuestionOptions] count]; i++) {
            
            NSDictionary *option = subject[ExamQuestionOptions][i];
            BOOL selected = [option[ExamQuestionOptionSelected] integerValue];
            
            if (selected) {
                NSNumber *optionSeq = option[ExamQuestionOptionSeq];
                [_selectedRowsOfSubject addObject:optionSeq];
            }
        }
    }
}

- (void)updateOptionContents
{
    NSDictionary *selectedQuestion = _examContent[ExamQuestions][_selectedCellIndex];
    NSString *questionTitle = selectedQuestion[ExamQuestionTitle];
    NSNumber *questionType = selectedQuestion[ExamQuestionType];
    NSString *typeString;

    switch ([questionType integerValue]) {
        case ExamSubjectTypeTrueFalse:
            typeString = NSLocalizedString(@"EXAM_TYPE_TRUE_FALSE", Nil);
            _questionTableView.allowsMultipleSelection = NO;
            break;
        case ExamSubjectTypeSingle:
            typeString = NSLocalizedString(@"EXAM_TYPE_SINGLE", Nil);
            _questionTableView.allowsMultipleSelection = NO;
            break;
        case ExamSubjectTypeMultiple:
            typeString = NSLocalizedString(@"EXAM_TYPE_MULTIPLE", Nil);
            _questionTableView.allowsMultipleSelection = YES;
            break;
        default:
            break;
    }

    _questionTypeLabel.text = typeString;
    _correctionTypeLabel.text = typeString;

    NSString *title = [NSString stringWithFormat:@"%d. %@", _selectedCellIndex+1, questionTitle];

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
    if (_isAnswerMode) {
        _submitButton.hidden = YES;
        self.submitButton2.hidden = YES;
    }
    else {
        for (NSNumber *status in _cellStatus) {
            if ([status isEqualToNumber:@(CellStatusNone)]) {
                _submitButton.hidden = YES;
                self.submitButton2.hidden = YES;
                return;
            }
        }
        _submitButton.hidden = NO;
        self.submitButton2.hidden = NO;
    }
}

- (void)saveSelections
{
    if (_isAnswerMode) {
        return;
    }

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
    if (_isAnswerMode) {
        NSInteger numberOfSubjects = [_examContent[ExamQuestions] count];
        NSInteger numberOfCorrectSubjects = [self numberOfCorrectSubjects];

        NSString *correctString = [NSString stringWithFormat:NSLocalizedString(@"EXAM_CORRECT_TEMPLATE", nil), numberOfCorrectSubjects];
        NSString *correctNumberString = [NSString stringWithFormat:@"%lld", (long long)numberOfCorrectSubjects];
        NSRange correctNumberRange = [correctString rangeOfString:correctNumberString];
        NSRange correctTextRange = NSMakeRange(0, correctNumberRange.location);

        NSMutableAttributedString *correctAttrString = [[NSMutableAttributedString alloc] initWithString:correctString];
        [correctAttrString setAttributes:@{NSForegroundColorAttributeName:ILDarkGray, NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} range:correctTextRange];
        [correctAttrString setAttributes:@{NSForegroundColorAttributeName:ILLightGreen, NSFontAttributeName:[UIFont boldSystemFontOfSize:20]} range:correctNumberRange];

        _leftStatusLabel.attributedText = correctAttrString;

        NSString *wrongString = [NSString stringWithFormat:NSLocalizedString(@"EXAM_WRONG_TEMPLATE", nil), numberOfSubjects-numberOfCorrectSubjects];
        NSString *wrongNumberString = [NSString stringWithFormat:@"%lld", (long long)(numberOfSubjects-numberOfCorrectSubjects)];
        NSRange wrongNumberRange = [wrongString rangeOfString:wrongNumberString];
        NSRange wrongTextRange = NSMakeRange(0, wrongNumberRange.location);

        NSMutableAttributedString *wrongAttrString = [[NSMutableAttributedString alloc] initWithString:wrongString];
        [wrongAttrString setAttributes:@{NSForegroundColorAttributeName:ILDarkGray, NSFontAttributeName:[UIFont boldSystemFontOfSize:14]} range:wrongTextRange];
        [wrongAttrString setAttributes:@{NSForegroundColorAttributeName:ILRed, NSFontAttributeName:[UIFont boldSystemFontOfSize:20]} range:wrongNumberRange];

        _rightStatusLabel.attributedText = wrongAttrString;
    }
    else {
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

- (NSInteger)numberOfCorrectSubjects
{
    NSInteger numberOfCorrectSubjects = 0;

    for (NSDictionary *subject in _examContent[ExamQuestions]) {
        if ([subject[ExamQuestionCorrect] isEqualToNumber:@(1)]) {
            numberOfCorrectSubjects++;
        }
    }
    return numberOfCorrectSubjects;
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

- (void)updateTimeLeft
{
    NSInteger timeLeft = [_examEndDate timeIntervalSinceNow];

    if (timeLeft < 0) {
        timeLeft = 0;
    }

    NSInteger minute = timeLeft / 60;
    NSInteger hour;
    if (minute > 60) {
        hour = minute / 60;
    }
    else {
        hour = 0;
    }
    NSInteger second = timeLeft % 60;
    minute = minute % 60;

    self.countDownHourLabel.text = [NSString stringWithFormat:@"%02ld", (long)hour];
    self.countDownMinuteLabel.text = [NSString stringWithFormat:@"%02ld", (long)minute];
    self.countDownSecondLabel.text = [NSString stringWithFormat:@"%02ld", (long)second];
}

- (void)timeOut
{
    [self submit];
}

- (void)submit
{
    [_timeLeftTimer invalidate];
    [_timeOutTimer invalidate];

    __weak SubjectViewController *weakSelf = self;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"LIST_LOADING", nil);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [self saveSelections];

        NSString *fileName = _examContent[CommonFileName];
        NSString *dbPath = [ExamUtil examDBPathOfFile:fileName];

        NSInteger score = [ExamUtil examScoreOfDBPath:dbPath];

        [ExamUtil generateExamUploadJsonOfDBPath:dbPath];

        NSString *scoreString = [NSString stringWithFormat:NSLocalizedString(@"EXAM_SCORE_TEMPLATE", nil), score];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EXAM_SCORE_TITLE", nil) message:scoreString delegate:weakSelf cancelButtonTitle:NSLocalizedString(@"COMMON_OK", nil) otherButtonTitles:nil];

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

@end
