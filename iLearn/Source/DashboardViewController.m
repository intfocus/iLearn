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
#import "DataHelper.h"
#import "ExtendNSLogFunctionality.h"
#import "SettingViewController.h"
#import "UIViewController+CWPopup.h"
#import "ActionLog.h"
#import <AVFoundation/AVFoundation.h>

static NSString *const kShowQuestionnaireSegue = @"showQuestionnairePage";
static NSString *const kShowExamSegue = @"showExamPage";
static NSString *const kShowRegistrationSegue = @"showRegistrationPage";
static NSString *const kShowLectureSegue = @"showLecturePage";
static NSString *const kShowSettingsSegue = @"SettingViewController";//@"showSettingsPage";
static NSString *const kShowQRCodeSegue = @"showQRCodePage";
static NSString *const kShowNotificationSegue = @"showNotificationPage";

static NSString *const kNotificationCellIdentifier = @"notificationCellIdentifier";

@interface DashboardViewController ()<SettingViewProtocol>

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
@property (strong, nonatomic) NSArray *notificationList;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;


@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *weekdayFormatter;

// 头像设置
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (nonatomic) UIActionSheet *imagePickerActionSheet;
@property (nonatomic) UIImagePickerController *imagePicker;
@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _registrationButton.enabled  = NO;
    _lectureButton.enabled       = YES;
    _questionnaireButton.enabled = NO;
    _settingsButton.enabled      = YES;
    

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
    
    // hidden navigation
    self.navigationController.navigationBarHidden = YES;
    // load avatar image
    UIButton *avatar = self.avatarBtn;
    avatar.layer.cornerRadius=CGRectGetHeight(avatar.frame)/2;
    avatar.layer.borderColor=[UIColor whiteColor].CGColor;
    avatar.layer.borderWidth=2;
    NSData *imagedata = [[NSUserDefaults standardUserDefaults] objectForKey:@"avatarSmall"];
    if (imagedata){
        UIImage *avatarImage = [UIImage imageWithData:imagedata];
        [self.avatarBtn setImage:avatarImage forState:UIControlStateNormal];
    }
    avatar.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *humanName = @"unkown";
    if ([segue.identifier isEqualToString:kShowQuestionnaireSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeQuestionnaire;
        humanName = @"问卷";
    }
    else if ([segue.identifier isEqualToString:kShowExamSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeExam;
        humanName = @"考试";
    }
    else if ([segue.identifier isEqualToString:kShowRegistrationSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeRegistration;
        humanName = @"注册";
    }
    else if ([segue.identifier isEqualToString:kShowLectureSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeLecture;
        humanName = @"武田学院";
    }
    else if ([segue.identifier isEqualToString:kShowNotificationSegue]) {
        ListViewController* listVC = (ListViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeNotification;
        humanName = @"通知公告";
    }
    else if ([segue.identifier isEqualToString:kShowQRCodeSegue]) {
        QRCodeViewController* qrCodeVC = (QRCodeViewController*)segue.destinationViewController;
        qrCodeVC.showCloseButton = YES;
        humanName = @"二维码扫描";
    }
    
    ActionLogRecordDashboard(humanName);
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
    NSMutableDictionary *notificationDatas = [DataHelper notifications];
    NSArray *dataListOne = notificationDatas[NOTIFICATION_FIELD_GGDATA]; // 公告数据
    NSArray *dataListTwo = notificationDatas[NOTIFICATION_FIELD_HDDATA]; // 预告数据
    
    NSSortDescriptor *descriptor;
    // 公告通知按created_date降序
    descriptor = [[NSSortDescriptor alloc] initWithKey:NOTIFICATION_FIELD_CREATEDATE ascending:NO];
    dataListOne = [dataListOne sortedArrayUsingDescriptors:@[descriptor]];
    // 预告通知按occur_date升序
    descriptor = [[NSSortDescriptor alloc] initWithKey:NOTIFICATION_FIELD_OCCURDATE ascending:YES];
    dataListTwo = [dataListTwo sortedArrayUsingDescriptors:@[descriptor]];
    
    // todo tab switch with data one/two
    self.notificationList = dataListOne;
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
    settingVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    nav.view.frame = CGRectMake(0, 0, 400, 500);

    [self presentPopupViewController:nav animated:YES completion:^(void) {
        NSLog(@"popup view settingViewController");
        ActionLogRecordDashboard(@"设置");
    }];
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

/**
 *  点击头像事件
 *
 *  @param sender <#sender description#>
 */
- (IBAction)headClick:(id)sender {
    self.imagePickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选择" otherButtonTitles:@"现在拍照", nil];
    self.imagePickerActionSheet.delegate = self;
    [self.imagePickerActionSheet showInView:self.view];
    
    ActionLogRecordDashboard(@"点击头像");
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

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
- (void)dismissSettingView {
    [self dismissPopup];
}


#pragma mark - gesture recognizer delegate functions

// so that tapping popup view doesnt dismiss it
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self.view;
}

#pragma mark - 头像上传功能函数

#pragma mark - actionSheet let user choose
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self showImagePicker:buttonIndex];
}

#pragma mark - imagePicker
- (void)showImagePicker: (NSInteger)index {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        if (!self.imagePicker) {
            self.imagePicker = [[UIImagePickerController alloc] init];
        }
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = YES;
        self.imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
        if (index == 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
        else if (index == 1 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }
    else {
        //authorization failed, show the alert
        [self alertAuthorization];
    }
}

- (void)alertAuthorization{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        NSString *message = @"授权访问相机~";
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action){
            if (&UIApplicationOpenSettingsURLString != NULL) {
                NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:appSettings];
            }
        }];
        [alertVC addAction:okAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    else{
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"授权访问相机~" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - imagePicker delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editImamge = info[UIImagePickerControllerEditedImage];
    NSData *imagedata = UIImageJPEGRepresentation(editImamge, 0.6);
    //save the photo for next launch
    [[NSUserDefaults standardUserDefaults] setObject:imagedata forKey:@"avatarSmall"];
    [picker dismissViewControllerAnimated:YES completion:^{
        if (imagedata){
            UIImage *avatarImage = [UIImage imageWithData:imagedata];
            [self.avatarBtn setImage:avatarImage forState:UIControlStateNormal];
            
            ActionLogRecordDashboard(@"头像设置成功");
        }
    }];
}

#pragma mark - status bar settings
-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - supportedInterfaceOrientationsForWindow
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end
