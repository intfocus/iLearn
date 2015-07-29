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

- (void)popupNotificationDetailView:(NSDictionary *)notification;
- (void)dimmissPopupNotificationDetailView;

@end
