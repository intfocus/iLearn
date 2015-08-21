//
//  SigninFormViewController.h
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrainCourse.h"
//#import "ListViewController.h"
@protocol SigninFormViewControllerProtocol <NSObject>

@optional
- (void)actionSubmit;
- (void)actionEdit;
- (void)actionRemove;
@end

@interface SigninFormViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;


//@property (strong, nonatomic) ListViewController *listViewController;
@property (strong, nonatomic) TrainCourse *trainCourse;
@property (strong, nonatomic) NSDictionary *trainSignin;
@property (assign, nonatomic) BOOL isCreated;
@property (assign, nonatomic) BOOL isEdit;
@property (weak, nonatomic) id <SigninFormViewControllerProtocol> delegate;
@end
