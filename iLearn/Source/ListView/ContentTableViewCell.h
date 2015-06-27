//
//  ContentTableViewCell.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ContentTableViewCellAction) {
    ContentTableViewCellActionView,
    ContentTableViewCellActionDownload,
};

@class ContentTableViewCell;

@protocol ContentTableViewCellDelegate <NSObject>

- (void)didSelectInfoButtonOfCell:(ContentTableViewCell*)cell;
- (void)didSelectActionButtonOfCell:(ContentTableViewCell*)cell;
- (void)didSelectQRCodeButtonOfCell:(ContentTableViewCell*)cell;

@end

@interface ContentTableViewCell : UITableViewCell

@property (weak, nonatomic) UIViewController<ContentTableViewCellDelegate> *delegate;
@property (assign, nonatomic) ContentTableViewCellAction actionButtonType;

- (void)actionTouched;
- (void)infoTouched;
- (void)qrCodeTouched;

@end
