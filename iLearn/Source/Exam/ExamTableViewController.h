//
//  ExamTableViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/6/26.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "QRCodeReaderViewController.h"
#import "ConnectionManager.h"
#import "QuestionnaireCell.h"
#import "ContentViewController.h"

@interface ExamTableViewController : ContentViewController <ContentViewProtocal, UITableViewDataSource, UITableViewDelegate, ListTableViewCellDelegate, QRCodeReaderDelegate, ConnectionManagerDelegate>

@property (assign, nonatomic) ListViewType listType;

@end
