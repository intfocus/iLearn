//
//  ListTableViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@class ListTableViewCell;

@protocol ListTableViewCellDelegate <NSObject>

- (void)didSelectInfoButtonOfCell:(ListTableViewCell*)cell;
- (void)didSelectActionButtonOfCell:(ListTableViewCell*)cell;

@end

@interface ListTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ListTableViewCellDelegate>

@property (assign, nonatomic) ListViewType listType;

@end
