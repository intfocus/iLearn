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

typedef NS_ENUM(NSInteger, SettingSectionIndex) {
    SettingUserInfoIndex      = 0,
    SettingAppInfoIndex       = 1,
    SettingAppFilesIndex      = 2,
    SettingActionLogIndex     = 3,
    SettingUploadedExamsIndex = 4,
    SettingUpgradeIndex       = 5
};

@protocol SettingViewProtocol <NSObject>
- (void)dismissSettingView;
@end

@interface SettingViewController : UIViewController
@property (nonatomic, weak) UIViewController *masterViewController;

@property (nonatomic, weak) id <SettingViewProtocol> delegate;
@end
#endif
