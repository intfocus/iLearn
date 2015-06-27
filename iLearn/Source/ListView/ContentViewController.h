//
//  ContentViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/6/27.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContentViewProtocal <NSObject>

@optional

- (void)syncData;
- (void)scanQRCode;

@end


@class ListTableViewController;

@interface ContentViewController : UIViewController

@property (weak, nonatomic) ListTableViewController *listViewController;

@end
