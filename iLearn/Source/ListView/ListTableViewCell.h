//
//  ListTableViewCell.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ListTableViewCellAction) {
    ListTableViewCellActionView,
    ListTableViewCellActionDownload,
};

@class ListTableViewCell;

@protocol ListTableViewCellDelegate <NSObject>

- (void)didSelectInfoButtonOfCell:(ListTableViewCell*)cell;
- (void)didSelectActionButtonOfCell:(ListTableViewCell*)cell;
- (void)didSelectQRCodeButtonOfCell:(ListTableViewCell*)cell;

@end

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) UIViewController<ListTableViewCellDelegate> *delegate;
@property (assign, nonatomic) ListTableViewCellAction actionButtonType;

- (void)actionTouched;
- (void)infoTouched;
- (void)qrCodeTouched;

@end
