//
//  LectureDescViewController.m
//  iLearn
//
//  Created by lijunjie on 15/7/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "LectureDescViewController.h"
#import "Constants.h"

@interface LectureDescViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation LectureDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.actionButton.layer setCornerRadius:15.0];
    
    [self.contentView.layer setBorderWidth:1.0];
    
    UIColor *borderColor = RGBCOLOR(190.0, 190.0, 190.0);
    [self.contentView.layer setBorderColor:borderColor.CGColor];
    
    self.titleLabel.text = _titleString;
    self.descTextView.text = _descString;
    //self.descLabel.text = _descString;
    if (self.shownFromBeginTest) {
        self.actionButton.hidden = NO;
    }
    else {
        self.actionButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)actionTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(begin)]) {
            [self.delegate begin];
        }
    }];
}

@end
