//
//  RegistrationTableViewController.h
//  iLearn
//
//  Created by lijunjie on 15/8/14.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "ContentViewController.h"
#import "ConnectionManager.h"
#import "ExamTabelViewCell.h"
#import "ContentViewController.h"
/**
 *  培训报名
 */
@interface RegistrationTableViewController : ContentViewController<ContentViewProtocal, UITableViewDataSource, UITableViewDelegate, ContentTableViewCellDelegate, ConnectionManagerDelegate>

@end
