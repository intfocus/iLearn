//
//  DashboardViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/13.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "DashboardViewController.h"
#import "ListTableViewController.h"
#import "QRCodeViewController.h"
#import "LicenseUtil.h"
#import "NotificationViewController.h"
#import "const.h"
#import "FileUtils.h"

static NSString *const kShowQuestionnaireSegue = @"showQuestionnairePage";
static NSString *const kShowExamSegue = @"showExamPage";
static NSString *const kShowRegistrationSegue = @"showRegistrationPage";
static NSString *const kShowLectureSegue = @"showLecturePage";
static NSString *const kShowSettingsSegue = @"showSettingsPage";
static NSString *const kShowQRCodeSegue = @"showQRCodePage";

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

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _registrationButton.enabled = NO;
    _lectureButton.enabled = NO;
    _questionnaireButton.enabled = NO;
    _settingsButton.enabled = NO;

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

    [self setupAvatarImageView];
    [self reloadNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowQuestionnaireSegue]) {
        ListTableViewController* listVC = (ListTableViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeQuestionnaire;
    }
    else if ([segue.identifier isEqualToString:kShowExamSegue]) {
        ListTableViewController* listVC = (ListTableViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeExam;
    }
    else if ([segue.identifier isEqualToString:kShowRegistrationSegue]) {
        ListTableViewController* listVC = (ListTableViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeRegistration;
    }
    else if ([segue.identifier isEqualToString:kShowLectureSegue]) {
        ListTableViewController* listVC = (ListTableViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeLecture;
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
    NSString *cachePath = [FileUtils getPathName:NOTIFICATION_DIRNAME FileName:NOTIFICATION_CACHE];
    NSError *error;
    NSMutableDictionary *notificationDatas = [NSMutableDictionary dictionary];

    // 读取本地cache
    NSString *cacheContent = [NSString stringWithContentsOfFile:cachePath usedEncoding:NULL error:&error];
    NSLog(@"notifications cache read");
    if(!error) {
        // 解析为json数组
        notificationDatas = [NSJSONSerialization JSONObjectWithData:[cacheContent dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
        NSLog(@"notifications cache parse into json");
    }

    self.notificationList = notificationDatas[NOTIFICATION_FIELD_GGDATA]; // 公告数据

    // 公告通知按created_date升序
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NOTIFICATION_FIELD_CREATEDATE ascending:YES];
    [self.notificationList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

    [_notificationTableView reloadData];
}

#pragma mark - IBActions

- (IBAction)settingsTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowSettingsSegue sender:nil];
}

- (IBAction)registrationTouced:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowRegistrationSegue sender:nil];
}

- (IBAction)lectureTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowLectureSegue sender:nil];
}

- (IBAction)reminderTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
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
    NotificationViewController *notificationVC = [[NotificationViewController alloc] init];
    [self presentViewController:notificationVC animated:YES completion:nil];
}

@end
