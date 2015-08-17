//
//  QuestionnaireTableViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/7/4.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ConnectionManager.h"
#import "QuestionnaireTableViewCell.h"
#import "ContentViewController.h"

@interface QuestionnaireTableViewController : ContentViewController <ContentViewProtocal, UITableViewDataSource, UITableViewDelegate, ContentTableViewCellDelegate, ConnectionManagerDelegate>

@end
