//
//  ListTableViewCell.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTableViewController.h"

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) UIViewController<ListTableViewCellDelegate> *delegate;

- (void)actionTouched;
- (void)infoTouched;

@end
