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

static NSString *const kSubjectCollectionCellIdentifier = @"subjectCollectionViewCell";

static NSString *const kQuestionOptionCellIdentifier = @"QuestionAnswerCell";

typedef NS_ENUM(NSUInteger, CellStatus) {
    CellStatusNone,
    CellStatusAnswered,
    CellStatusWrong,
};


@interface SubjectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightStatusLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *subjectCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;


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

@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSString *titleString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"DASHBOARD_QUESTIONNAIRE", nil), NSLocalizedString(@"COMMON_CONTENT", nil)];
    self.title = titleString;

    self.submitButton.title = NSLocalizedString(@"COMMON_SUBMIT", nil);

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Img_background"]]];

    self.cellStatus = [NSMutableArray array];
    for (int i = 0; i < [_examContent[ExamQuestions] count]; i++) {
        [_cellStatus addObject:@(CellStatusNone)];
    }

    self.selectedCellIndex = 0;
    [self updateOptionContents];

    BOOL isCorrectionHidden = YES;

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

- (void)updateOptionContents
{
    NSDictionary *selectedQuestion = _examContent[ExamQuestions][_selectedCellIndex];
    NSString *questionTitle = selectedQuestion[ExamQuestionTitle];
    NSString *title = [NSString stringWithFormat:@"%d.  %@", _selectedCellIndex+1, questionTitle];

    _questionTitleLabel.text = title;
    _correctionTitleLabel.text = title;

    NSString *correctionNote = selectedQuestion[ExamQuestionNote];
    _correctionNoteLabel.text = correctionNote;

    [_questionTableView reloadData];
    [_correctionTableView reloadData];

    CGFloat height = _questionTableView.contentSize.height;
    _answerTableViewHeightConstraint.constant = height;
    _correctionTableViewHeightConstraint.constant = height;
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

    if ([_cellStatus[indexPath.row] isEqualToNumber:@(CellStatusAnswered)]) {
        cell.backgroundColor = [UIColor greenColor];
    }
    else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _cellStatus[indexPath.row] = @(CellStatusAnswered);
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];

    self.selectedCellIndex = indexPath.row;
    [self updateOptionContents];
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

    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - UIAction

- (IBAction)logoButtonTouched:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
