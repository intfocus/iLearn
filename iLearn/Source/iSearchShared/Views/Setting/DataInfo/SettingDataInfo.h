//
//  SettingUserInfo.h
//  iSearch
//
//  Created by lijunjie on 15/7/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#ifndef iSearch_SettingUserInfo_h
#define iSearch_SettingUserInfo_h
#import <UIKit/UIKit.h>
@class SettingViewController;

@interface SettingDataInfo : UIViewController
@property (nonatomic,assign) NSInteger indexRow;
@property (nonatomic,nonatomic) SettingViewController *settingViewController;
@property (nonatomic, weak) UIViewController *masterViewController;
@end

#endif
