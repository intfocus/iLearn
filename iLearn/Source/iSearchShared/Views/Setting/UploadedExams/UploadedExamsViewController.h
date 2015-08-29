//
//  UploadedExamsViewController.h
//  iLearn
//
//  Created by lijunjie on 15/8/26.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionManager.h"

@class SettingViewController;

@interface UploadedExamsViewController : UIViewController<ConnectionManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,nonatomic) SettingViewController *settingViewController;
@property (nonatomic, weak) UIViewController *masterViewController;
@end
