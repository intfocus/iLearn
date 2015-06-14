//
//  ListTableViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "QRCodeReaderViewController.h"
#import "ConnectionManager.h"

@class ListTableViewCell;

@protocol ListTableViewCellDelegate <NSObject>

- (void)didSelectInfoButtonOfCell:(ListTableViewCell*)cell;
- (void)didSelectActionButtonOfCell:(ListTableViewCell*)cell;
- (void)didSelectQRCodeButtonOfCell:(ListTableViewCell*)cell;

@end

@interface ListTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ListTableViewCellDelegate, QRCodeReaderDelegate, ConnectionManagerDelegate>

@property (assign, nonatomic) ListViewType listType;

@end
