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

@end

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *descString;

@property (assign, nonatomic) BOOL shownFromBeginTest;
@property (weak, nonatomic) id <DetailViewControllerProtocol> delegate;

@end
