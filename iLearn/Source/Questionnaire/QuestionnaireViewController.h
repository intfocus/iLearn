//
//  QuestionnaireViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/7/4.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupSelectionView.h"
#import "UploadQuestionnaireViewController.h"

@interface QuestionnaireViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextViewDelegate, GroupSelectionViewDelegate, UploadQuestionnaireViewControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary *questionnaireContent;

@end
