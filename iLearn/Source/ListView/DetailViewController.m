//
//  DetailViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "DetailViewController.h"
#import "Constants.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UIColor *borderColor = RGBCOLOR(190.0, 190.0, 190.0);
    [self.contentView.layer setBorderColor:borderColor.CGColor];
    [self.contentView.layer setBorderWidth:1.0];

    self.titleLabel.text = _titleString;
    self.descLabel.text = _descString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
