//
//  LectureDescViewController.h
//  iLearn
//
//  Created by lijunjie on 15/7/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LectureDescViewControllerProtocol <NSObject>

- (void)begin;

@end

@interface LectureDescViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *descString;

@property (assign, nonatomic) BOOL shownFromBeginTest;
@property (weak, nonatomic) id <LectureDescViewControllerProtocol> delegate;

@end
