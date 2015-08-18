//
//  UploadQuestionnaireViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/8/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@protocol UploadQuestionnaireViewControllerDelegate <NSObject>

- (void)backToListView;

@end


@interface UploadQuestionnaireViewController : UIViewController <ConnectionManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) NSString *questionnaireID;
@property (weak, nonatomic) id <UploadQuestionnaireViewControllerDelegate> delegate;

@end
