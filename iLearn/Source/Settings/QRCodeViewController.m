//
//  QRCodeViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "QRCodeViewController.h"
#import "UIImage+MDQRCode.h"
#import "Constants.h"
#import "LicenseUtil.h"

@interface QRCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"SETTINGS_PERSONAL_QRCODE", nil);

    CGFloat size = self.qrCodeImageView.frame.size.width;
    UIImage *qrCodeImage = [UIImage mdQRCodeForString:[LicenseUtil userAccount] size:size];

    self.qrCodeImageView.image = qrCodeImage;
    self.qrCodeImageView.backgroundColor = RGBCOLOR(230.0, 230.0, 230.0);

    NSString *accountString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"COMMON_ACCOUNT", nil), [LicenseUtil userAccount]];
    self.accountLabel.text = accountString;

    self.closeButton.hidden = !_showCloseButton;
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

- (IBAction)closeTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
