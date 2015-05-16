//
//  AppInfoViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"SETTINGS_APPLICATION_ABOUT", nil);
    [self.logoImageView.layer setCornerRadius:20.0];
    [self.logoImageView setClipsToBounds:YES];

    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];

    NSString *versionString = [NSString stringWithFormat:@"%@: %@.%@", NSLocalizedString(@"SETTINGS_APPLICATION_VERSION", nil), version, build];

    self.versionLabel.text = versionString;
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

@end
