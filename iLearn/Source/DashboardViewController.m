//
//  DashboardViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/13.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "DashboardViewController.h"
#import "ListViewController.h"
#import "QRCodeViewController.h"
#import "LicenseUtil.h"
#import "NotificationViewController.h"
#import "const.h"
#import "FileUtils.h"
#import "ApiUtils.h"
#import "ExtendNSLogFunctionality.h"
#import "SettingViewController.h"
#import "UIViewController+CWPopup.h"

static NSString *const kShowQuestionnaireSegue = @"showQuestionnairePage";
static NSString *const kShowExamSegue = @"showExamPage";
static NSString *const kShowRegistrationSegue = @"showRegistrationPage";
static NSString *const kShowLectureSegue = @"showLecturePage";
static NSString *const kShowSettingsSegue = @"SettingViewController";//@"showSettingsPage";
static NSString *const kShowQRCodeSegue = @"showQRCodePage";
static NSString *const kShowNotificationSegue = @"showNotificationPage";

static NSString *const kNotificationCellIdentifier = @"notificationCellIdentifier";

@interface DashboardViewController ()

// Button Area Views
@property (weak, nonatomic) IBOutlet UIView *coursePackView;
@property (weak, nonatomic) IBOutlet UIView *lectureView;
@property (weak, nonatomic) IBOutlet UIView *reminderView;
@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIView *examView;

@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@property (weak, nonatomic) IBOutlet UIButton *lectureButton;
@property (weak, nonatomic) IBOutlet UIButton *questionnaireButton;
@property (weak, nonatomic) IBOutlet UIButton *examButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *notificationButton;

// Button Labels
@property (weak, nonatomic) IBOutlet UILabel *coursePackLabel;
@property (weak, nonatomic) IBOutlet UILabel *lectureLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionnaireLabel;
@property (weak, nonatomic) IBOutlet UILabel *examLabel;

@property (weak, nonatomic) IBOutlet UILabel *serviceCallLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *qrCodeButton;

@property (weak, nonatomic) IBOutlet UITableView *notificationTableView;
@property (strong, nonatomic) NSMutableArray *notificationList;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;


@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *weekdayFormatter;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _registrationButton.enabled = NO;
    _lectureButton.enabled = NO;
    _questionnaireButton.enabled = NO;
    _settingsButton.enabled = YES;
    

    // Setup label contents
    self.title = NSLocalizedString(@"DASHBOARD_TITLE", nil);
    self.coursePackLabel.text = NSLocalizedString(@"DASHBOARD_COURSE_PACK", nil);
    self.lectureLabel.text = NSLocalizedString(@"DASHBOARD_LECTURE", nil);
    self.reminderLabel.text = NSLocalizedString(@"DASHBOARD_REMINDER", nil);
    self.questionnaireLabel.text = NSLocalizedString(@"DASHBOARD_QUESTIONNAIRE", nil);
    self.examLabel.text = NSLocalizedString(@"DASHBOARD_EXAM", nil);
    self.serviceCallLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"DASHBOARD_SERVICE_CALL", nil), [LicenseUtil serviceNumber]];
    self.qrCodeButton.titleLabel.text = NSLocalizedString(@"SETTINGS_PERSONAL_QRCODE", nil);

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Img_background"]]];

    [self setupClockTimer];
    [self updateClock];

    [self setupAvatarImageView];
    [self reloadNotifications];

    // CWPoup setting
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    self.useBlurForPopup = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowQuestionnaireSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeQuestionnaire;
    }
    else if ([segue.identifier isEqualToString:kShowExamSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeExam;
    }
    else if ([segue.identifier isEqualToString:kShowRegistrationSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeRegistration;
    }
    else if ([segue.identifier isEqualToString:kShowLectureSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeLecture;
    }
    else if ([segue.identifier isEqualToString:kShowNotificationSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeNotification;
    }
    else if ([segue.identifier isEqualToString:kShowQRCodeSegue]) {
        QRCodeViewController* qrCodeVC = (QRCodeViewController*)segue.destinationViewController;
        qrCodeVC.showCloseButton = YES;
    }

}

#pragma mark - Helper Functions

- (void)setupAvatarImageView
{
    CGFloat width = self.avatarImageView.frame.size.width;
    [self.avatarImageView.layer setCornerRadius:width/2.0];
    [self.avatarImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.avatarImageView.layer setBorderWidth:2.0];
    [self.avatarImageView setClipsToBounds:YES];
}

// Charlie 2015/06/20
// TODO: Notification data loading (from server or cached data)

- (void)reloadNotifications
{
    NSMutableDictionary *notificationDatas = [ApiUtils notifications];
    self.notificationList = notificationDatas[NOTIFICATION_FIELD_GGDATA]; // 公告数据

    // 公告通知按created_date升序
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTIFICATION_FIELD_CREATEDATE ascending:YES];
    [self.notificationList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

    [_notificationTableView reloadData];
}

- (void)setupClockTimer
{
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [_timeFormatter setDateFormat:@"HH:mm"];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy/MM/dd"];

    self.weekdayFormatter = [[NSDateFormatter alloc] init];
    [_weekdayFormatter setDateFormat:@"EEEE"];

    NSDate *now = [NSDate date];
    NSInteger timeInterval = [now timeIntervalSince1970];
    NSInteger nextMinuteInterval = ((timeInterval / 60) + 1) * 60;
    NSDate *fireDate = [NSDate dateWithTimeIntervalSince1970:nextMinuteInterval];

    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:60
                                                target:self
                                              selector:@selector(updateClock)
                                              userInfo:nil
                                               repeats:YES];

    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    [currentRunLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)updateClock
{
    NSDate *now = [NSDate date];

    NSString *timeString = [_timeFormatter stringFromDate:now];
    NSString *dateString = [_dateFormatter stringFromDate:now];
    NSString *weekdayString = [_weekdayFormatter stringFromDate:now];

    _timeLabel.text = timeString;
    _dateLabel.text = dateString;
    _weekdayLabel.text = weekdayString;
}

#pragma mark - IBActions

- (IBAction)settingsTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // [self performSegueWithIdentifier:kShowSettingsSegue sender:nil];

    SettingViewController *settingVC = [[SettingViewController alloc] init];
    settingVC.masterViewController = self;
    [self presentPopupViewController:settingVC animated:YES completion:nil];
}

- (IBAction)registrationTouced:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowRegistrationSegue sender:nil];
}

- (IBAction)lectureTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowLectureSegue sender:nil];
}

- (IBAction)notificationTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowNotificationSegue sender:nil];
}

- (IBAction)questionnaireTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowQuestionnaireSegue sender:nil];
}

- (IBAction)examTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowExamSegue sender:nil];
}

- (IBAction)qrCodeTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowQRCodeSegue sender:nil];
}

#pragma mark - UITableViewDataSource

// Charlie 2015/06/20
// TODO: Adjust notificationi list content

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_notificationList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNotificationCellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNotificationCellIdentifier];
    }

    NSInteger cellIndex = indexPath.row;

    if (cellIndex < [self.notificationList count]) {
        NSMutableDictionary *currentDict = [self.notificationList objectAtIndex:cellIndex];
        cell.textLabel.text = currentDict[NOTIFICATION_FIELD_TITLE];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kShowNotificationSegue sender:nil];
}

#pragma mark - CWPoup

- (void)dismissPopup {
    if (self.popupViewController) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
}


#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}
@end
