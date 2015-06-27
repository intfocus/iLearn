//
//  ScoreQRCodeViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/6/11.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ScoreQRCodeViewController.h"

@interface ScoreQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *QRCodeImageView;

@end

@implementation ScoreQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _QRCodeImageView.image = _scoreQRCodeImage;
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
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
