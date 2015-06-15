//
//  ListTableViewCell.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTableViewController.h"

typedef NS_ENUM(NSUInteger, ListTableViewCellAction) {
    ListTableViewCellActionView,
    ListTableViewCellActionDownload,
};

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) UIViewController<ListTableViewCellDelegate> *delegate;
@property (assign, nonatomic) ListTableViewCellAction actionButtonType;

- (void)actionTouched;
- (void)infoTouched;
- (void)qrCodeTouched;

@end
