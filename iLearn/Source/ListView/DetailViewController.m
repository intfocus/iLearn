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

    [self.actionButton.layer setCornerRadius:15.0];
    [self.contentView.layer setBorderWidth:1.0];
    self.descTextView.userInteractionEnabled = NO;

    UIColor *borderColor = RGBCOLOR(190.0, 190.0, 190.0);
    [self.contentView.layer setBorderColor:borderColor.CGColor];

    self.titleLabel.text   = _titleString;
    self.descTextView.text = _descString;

    self.actionButton.hidden = !self.showActionButton;
    self.removeButton.hidden = !self.showRemoveButton;
    if(self.actionString) {
        [self.actionButton setTitle:self.actionString forState:UIControlStateNormal];
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
- (IBAction)removeTouched:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(actionRemove)]) {
            [self.delegate actionRemove];
        }
    }];
}

@end
