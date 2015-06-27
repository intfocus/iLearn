//
//  ListViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ListViewController.h"
#import "LicenseUtil.h"
#import "ExamTableViewController.h"
#import "NotificationViewController.h"

static NSString *const kShowSettingsSegue = @"showSettingsPage";

@interface ListViewController ()

@property (weak, nonatomic) IBOutlet UIView *registrationView;
@property (weak, nonatomic) IBOutlet UIView *lectureView;
@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIView *examView;

@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@property (weak, nonatomic) IBOutlet UIButton *lectureButton;
@property (weak, nonatomic) IBOutlet UIButton *questionnaireButton;
@property (weak, nonatomic) IBOutlet UIButton *examButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) ContentViewController<ContentViewProtocal> *contentViewController;
@property (strong, nonatomic) ExamTableViewController *examTableViewController;
@property (strong, nonatomic) NotificationViewController *notificationViewController;

@property (weak, nonatomic) IBOutlet UIImageView *avartarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceCallLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;

@end


@implementation ListViewController

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

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];

    self.examTableViewController = [storyboard instantiateViewControllerWithIdentifier:@"ExamTableViewController"];
    _examTableViewController.listViewController = self;

    self.notificationViewController = [[NotificationViewController alloc] init];

    [self refreshContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//}

- (void)switchContentViewToViewController
{
    ContentViewController<ContentViewProtocal> *newContentViewController;

    switch (_listType) {
        case ListViewTypeExam:
            newContentViewController = _examTableViewController;
            break;
        case ListViewTypeNotification:
            newContentViewController = _notificationViewController;
            break;
        default:
            break;
    }

    CGRect containViewFrame = self.contentView.bounds;

    [_contentViewController removeFromParentViewController];
    [_contentViewController.view removeFromSuperview];

    self.contentViewController = newContentViewController;

    [self addChildViewController:_contentViewController];
    [self.contentView addSubview:_contentViewController.view];
    [_contentViewController.view setFrame:containViewFrame];

    [_contentViewController didMoveToParentViewController:self];
}

#pragma mark - UI Adjustment

- (void)refreshContentView
{
    [self switchContentViewToViewController];
    [self adjustToolbarItems];
    [self adjustSelectedItemInPanel];
}

- (void)adjustToolbarItems
{
    switch (_listType) {
        case ListViewTypeExam:
            self.titleLabel.text = NSLocalizedString(@"LIST_EXAM", nil);
            _syncButton.hidden = NO;
            _scanButton.hidden = NO;
            break;
        case ListViewTypeQuestionnaire:
            self.titleLabel.text = NSLocalizedString(@"LIST_QUESTIONNAIRE", nil);
            _syncButton.hidden = NO;
            _scanButton.hidden = YES;
            break;
        case ListViewTypeNotification:
            self.titleLabel.text = NSLocalizedString(@"LIST_NOTIFICATION", nil);
            _syncButton.hidden = NO;
            _scanButton.hidden = YES;
            break;
        default:
            self.titleLabel.text = NSLocalizedString(@"LIST_QUESTIONNAIRE", nil);
            _syncButton.hidden = NO;
            _scanButton.hidden = YES;
            break;
    }
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
    [self refreshContentView];
}

- (IBAction)lectureButtonTouched:(id)sender {
    NSLog(@"lectureButtonTouched");
    if (_listType == ListViewTypeLecture) {
        return;
    }
    self.listType = ListViewTypeLecture;
    [self refreshContentView];
}

- (IBAction)questionnaireButtonTouched:(id)sender {
    NSLog(@"questionnaireButtonTouched");
    if (_listType == ListViewTypeQuestionnaire) {
        return;
    }
    self.listType = ListViewTypeQuestionnaire;
    [self refreshContentView];
}

- (IBAction)examButtonTouched:(id)sender {
    NSLog(@"examButtonTouched");
    if (_listType == ListViewTypeExam) {
        return;
    }
    self.listType = ListViewTypeExam;
    [self refreshContentView];
}

- (IBAction)settingsButtonTouched:(id)sender {
    NSLog(@"settingsButtonTouched");
    [self performSegueWithIdentifier:kShowSettingsSegue sender:nil];
}

- (IBAction)syncButtonTouched:(id)sender {
    NSLog(@"syncButtonTouched");

    if ([_contentViewController respondsToSelector:@selector(syncData)]) {
        [_contentViewController syncData];
    }
}

- (IBAction)scanButtonTouched:(id)sender {

    if ([_contentViewController respondsToSelector:@selector(scanQRCode)]) {
        [_contentViewController scanQRCode];
    }
}

@end
