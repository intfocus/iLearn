//
//  SettingViewController.h
//  iSearch
//
//  Created by lijunjie on 15/6/25.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SettingMainView_h
#define iSearch_SettingMainView_h
#import <UIKit/UIKit.h>
@class DashboardViewController;
@class SettingViewController;

@interface SettingMainView : UIViewController
@property (nonatomic,nonatomic) DashboardViewController *mainViewController;
@property (nonatomic,nonatomic) SettingViewController *settingViewController;
@end
#endif
