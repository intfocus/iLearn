//
//  ExamViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExamViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSDictionary *examContent;

@end
