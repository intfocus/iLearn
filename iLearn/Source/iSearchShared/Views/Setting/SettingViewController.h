//
//  SettingViewController.h
//  iSearch
//
//  Created by lijunjie on 15/6/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SettingViewController_h
#define iSearch_SettingViewController_h
#import <UIKit/UIKit.h>
@class DashboardViewController;

@interface SettingViewController : UIViewController
@property (nonatomic,nonatomic) DashboardViewController *masterViewController;
@property (nonatomic,nonatomic) UIViewController *containerViewController;

- (void)actionCloseSettingView;
@end
#endif
