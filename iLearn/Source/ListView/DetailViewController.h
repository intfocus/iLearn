//
//  DetailViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailViewControllerProtocol <NSObject>

- (void)begin;

@optional
- (void)actionRemove;

@end

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
// 武田学院，课件已下载时，通过[明细]界面移除
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *descString;

@property (assign, nonatomic) BOOL showFromBeginTest;
@property (assign, nonatomic) BOOL showRemoveButton;
@property (weak, nonatomic) id <DetailViewControllerProtocol> delegate;

@end
