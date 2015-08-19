//
//  ListViewController.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "ContentViewController.h"

@interface ListViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (assign, nonatomic) ListViewType listType;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (void)popupNotificationDetailView:(NSDictionary *)notification;
- (void)dimmissPopupNotificationDetailView;
- (void)refreshContentView;

@end
