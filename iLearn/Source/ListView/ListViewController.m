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
#import "QuestionnaireTableViewController.h"
#import "NotificationViewController.h"

#import "ExamTableViewController.h"
#import "LectureTableViewController.h"
#import "SettingViewController.h"
#import "UIViewController+CWPopup.h"
#import "NotificationDetailView.h"
#import "RegistrationTableViewController.h"

static NSString *const kShowSettingsSegue = @"showSettingsPage";

@interface ListViewController ()<SettingViewProtocol>

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
@property (weak, nonatomic) IBOutlet UIImageView *avartarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceCallLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;

// 头像设置
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (nonatomic) UIActionSheet *imagePickerActionSheet;
@property (nonatomic) UIImagePickerController *imagePicker;
@end


@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup avatar image view
    CGFloat width = _avatarImageView.frame.size.width;
    [_avatarImageView.layer setCornerRadius:width/2.0];
    [_avatarImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_avatarImageView.layer setBorderWidth:2.0];
    _avatarImageView.clipsToBounds = YES;
    
    _userNameLabel.text = [LicenseUtil userName];
    _serviceCallLabel.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"DASHBOARD_SERVICE_CALL", nil), [LicenseUtil serviceNumber]];
    
    [self refreshContentView];
    
    // CWpopup
    self.useBlurForPopup = YES;
    
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//}

- (void)switchContentViewToViewController
{
    ContentViewController<ContentViewProtocal> *newContentViewController;
    UIStoryboard *storyboard;
    switch (_listType) {
        case ListViewTypeExam: {
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            newContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"ExamTableViewController"];
            newContentViewController.listViewController = self;
            
            break;
        }
        case ListViewTypeLecture: {
            storyboard = [UIStoryboard storyboardWithName:@"Lecture" bundle:nil];
            newContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"LectureTableViewController"];
            newContentViewController.listViewController = self;
            
            break;
        }
        case ListViewTypeNotification: {
            NotificationViewController *notificationViewController = [[NotificationViewController alloc] init];
            notificationViewController.masterViewController = self;
            notificationViewController.listViewController = self;
            newContentViewController = notificationViewController;
            
            break;
        }
        case ListViewTypeRegistration: {
            storyboard = [UIStoryboard storyboardWithName:@"Registration" bundle:nil];
            newContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegistrationTableViewController"];
            newContentViewController.listViewController = self;
            
            break;
        }
        case ListViewTypeQuestionnaire: {
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            newContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"QuestionnaireTableViewController"];
            newContentViewController.listViewController = self;
            
            break;
        }
        case ListViewTypeSigninAdmin: {
            storyboard = [UIStoryboard storyboardWithName:@"Registration" bundle:nil];
            newContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"SigninAdminTableViewController"];
            newContentViewController.listViewController = self;
            
            break;
        }
        case ListViewTypeSigninUser: {
            storyboard = [UIStoryboard storyboardWithName:@"Registration" bundle:nil];
            newContentViewController = [storyboard instantiateViewControllerWithIdentifier:@"SigninUserTableViewController"];
            newContentViewController.listViewController = self;
            
            break;
        }
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
    
    _syncButton.hidden      = YES;
    _scanButton.hidden      = YES;
    _backButton.hidden      = YES;
    _centerLabel.hidden = YES;
    
    switch (_listType) {
        case ListViewTypeExam: {
            self.titleLabel.text = NSLocalizedString(@"LIST_EXAM", nil);
            _syncButton.hidden = NO;
            _scanButton.hidden = NO;
            
            break;
        }
        case ListViewTypeLecture: {
            self.titleLabel.text = NSLocalizedString(@"LIST_LECTURE", nil);
            _syncButton.hidden = NO;
            
            break;
        }
        case ListViewTypeQuestionnaire: {
            self.titleLabel.text = NSLocalizedString(@"LIST_QUESTIONNAIRE", nil);
            _syncButton.hidden = NO;
            
            break;
        }
        case ListViewTypeNotification: {
            self.titleLabel.text = NSLocalizedString(@"LIST_NOTIFICATION", nil);
            _syncButton.hidden = NO;
            
            break;
        }
        case ListViewTypeRegistration: {
            self.syncButton.hidden = NO;
            self.titleLabel.hidden = NO;
            self.titleLabel.text   = @"培训报名";
            break;
        }
        case ListViewTypeSigninAdmin: {
            self.syncButton.hidden      = NO;
            self.backButton.hidden      = NO;
            self.titleLabel.hidden      = YES;
            self.centerLabel.hidden = NO;
            self.scanButton.hidden      = NO;
            [self.scanButton setTitle:@"创建签到" forState:UIControlStateNormal];
            
            break;
        }
        case ListViewTypeSigninUser: {
            self.syncButton.hidden      = NO;
            self.backButton.hidden      = NO;
            self.titleLabel.hidden      = YES;
            self.centerLabel.hidden = NO;
            self.scanButton.hidden      = YES;
            [self.scanButton setTitle:@"过滤" forState:UIControlStateNormal];
            
            break;
        }
        default: {
            self.titleLabel.text = NSLocalizedString(@"LIST_QUESTIONNAIRE", nil);
            _syncButton.hidden = NO;
            break;
        }
    }
}

- (void)adjustSelectedItemInPanel
{
    _examView.backgroundColor          = [UIColor clearColor];
    _questionnaireView.backgroundColor = [UIColor clearColor];
    _lectureView.backgroundColor       = [UIColor clearColor];
    _registrationView.backgroundColor  = [UIColor clearColor];
    
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
    self.listType = ListViewTypeRegistration;
    [self refreshContentView];
}

- (IBAction)lectureButtonTouched:(id)sender {
    NSLog(@"lectureButtonTouched");
    self.listType = ListViewTypeLecture;
    [self refreshContentView];
}

- (IBAction)questionnaireButtonTouched:(id)sender {
    NSLog(@"questionnaireButtonTouched");
    self.listType = ListViewTypeQuestionnaire;
    [self refreshContentView];
}

- (IBAction)examButtonTouched:(id)sender {
    NSLog(@"examButtonTouched");
    self.listType = ListViewTypeExam;
    [self refreshContentView];
}

- (IBAction)settingsButtonTouched:(id)sender {
    //NSLog(@"settingsButtonTouched");
    //[self performSegueWithIdentifier:kShowSettingsSegue sender:nil];
    
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    settingVC.delegate = self;
    settingVC.masterViewController = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    nav.view.frame = CGRectMake(0, 0, 400, 500);
    
    [self presentPopupViewController:nav animated:YES completion:^(void) {
        NSLog(@"popup view settingViewController");
    }];
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

- (IBAction)backButtonTouched:(id)sender {
    if ([_contentViewController respondsToSelector:@selector(actionBack:)]) {
        [_contentViewController actionBack:sender];
    }
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
        }
    }];
}

#pragma mark - present view NotificationDetailView
- (void)popupNotificationDetailView:(NSDictionary *)notification {
    NotificationDetailView *notificationDetailView = [[NotificationDetailView alloc] init];
    notificationDetailView.dict = notification;
    notificationDetailView.masterViewController = self;
    [self presentPopupViewController:notificationDetailView animated:YES completion:^{
        //self.coverView.hidden = NO;
    }];
}
- (void)dimmissPopupNotificationDetailView {
    [self dismissPopupViewControllerAnimated:YES completion:^{
        //self.coverView.hidden = YES;
        
        NSLog(@"dismiss NotificationDetailView.");
    }];
}
#pragma mark - supportedInterfaceOrientationsForWindow

-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
@end
