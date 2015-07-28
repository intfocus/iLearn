//
//  NotificationDetailView.h
//  iSearch
//
//  Created by lijunjie on 15/7/28.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ListViewController;

@interface NotificationDetailView : UIViewController
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) ListViewController *masterViewController;
@end
