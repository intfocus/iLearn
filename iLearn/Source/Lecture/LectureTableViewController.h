//
//  LectureTableViewController.h
//  iLearn
//
//  Created by lijunjie on 15/7/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ConnectionManager.h"
#import "ExamTabelViewCell.h"
#import "ContentViewController.h"


@interface LectureTableViewController : ContentViewController <ContentViewProtocal, UITableViewDataSource, UITableViewDelegate, ContentTableViewCellDelegate, ConnectionManagerDelegate>

@end