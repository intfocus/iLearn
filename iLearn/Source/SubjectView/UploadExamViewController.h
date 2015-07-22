//
//  DetailViewController.h
//  iLearn
//
//  Created by lijunjie on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@protocol UploadExamViewControllerProtocol <NSObject>

- (void)backToListView;

@end

@interface UploadExamViewController : UIViewController <ConnectionManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) NSNumber *examScore;
@property (strong, nonatomic) NSString *examID;

@property (weak, nonatomic) id <UploadExamViewControllerProtocol> delegate;

@end
