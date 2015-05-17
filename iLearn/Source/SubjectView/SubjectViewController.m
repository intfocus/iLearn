//
//  SubjectViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "SubjectViewController.h"

static NSString *const kSubjectCollectionCellIdentifier = @"subjectCollectionViewCell";

@interface SubjectViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *answeredTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *unansweredTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *answeredLabel;
@property (weak, nonatomic) IBOutlet UILabel *unansweredLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *subjectCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;

@end

@implementation SubjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSString *titleString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"DASHBOARD_QUESTIONNAIRE", nil), NSLocalizedString(@"COMMON_CONTENT", nil)];
    self.title = titleString;

    self.submitButton.title = NSLocalizedString(@"COMMON_SUBMIT", nil);

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Img_background"]]];
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
    return 15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSubjectCollectionCellIdentifier forIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionViewDelegate

@end
