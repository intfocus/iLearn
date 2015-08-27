//
//  ActionLogDetailViewController.m
//  iLearn
//
//  Created by lijunjie on 15/8/27.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "ActionLogDetailViewController.h"
#import "const.h"

@interface ActionLogDetailViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation ActionLogDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"记录明细";
    self.textView.text = [NSString stringWithFormat:@"模块: %@\n行为: %@\n时间: %@\n明细:\n        %@\n\n用户ID: %@\n行为ID: %@\n同步否: %@",
                          self.actionLog[ACTIONLOG_FIELD_ACTNAME],
                          self.actionLog[ACTIONLOG_FIELD_ACTOBJ],
                          self.actionLog[ACTIONLOG_FIELD_ACTTIME],
                          self.actionLog[ACTIONLOG_FIELD_ACTRET],
                          self.actionLog[ACTIONLOG_FIELD_UID],
                          self.actionLog[@"id"],
                          self.actionLog[ACTIONLOG_COLUMN_ISSYNC]];;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
