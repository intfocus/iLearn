//
//  SettingUserInfo.m
//  iSearch
//
//  Created by lijunjie on 15/7/5.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingDataInfo.h"
#import "SettingViewController.h"
#import "User.h"
#import "Version.h"
#import "FileUtils+Setting.h"
#import "DatabaseUtils+ActionLog.h"
#import "ViewUtils.h"
#import "ActionLog.h"
#import "ActionLogDetailViewController.h"

@interface SettingDataInfo()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataList;
@property (nonatomic, strong) NSArray *appFiles;
@end

@implementation SettingDataInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     *  实例变量初始化
     */
    _dataList = [NSArray array];
    _appFiles = [NSArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initData];
}

- (void)initData {
    NSString *title;
    
    switch (self.indexRow) {
        case SettingUserInfoIndex: {
            title = @"用户信息";
            
            User *user = [[User alloc] init];
            self.dataList = @[
                              @[@"用户信息",
                                @[
                                    @[@"名称", user.name, @0],
                                    @[@"邮箱", user.email, @0],
                                    @[@"员工编号", user.employeeID, @0],
                                    @[@"上次登录时间", user.loginLast, @0]
                                    ]
                                ]
                              ];
            break;
        }
        case SettingAppInfoIndex: {
            title = @"应用信息";
            
            Version *version = [[Version alloc] init];
            self.dataList = @[
                              @[@"应用信息",
                                @[
                                    @[@"应用名称", version.appName, @0],
                                    @[@"应用版本", version.current, @0]
                                    ]
                                ],
                              @[@"设备信息",
                                @[
                                    @[@"设备型号", [version machineHuman], @0],
                                    @[@"系统语言", version.lang, @0],
                                    @[@"支持最低IOS版本",version.suport, @0],
                                    @[@"当前IOS版本",  [version.sdkName stringByReplacingOccurrencesOfString:version.platform withString:@""], @0],
                                    @[@"系统空间", [FileUtils humanFileSize:version.fileSystemSize], @0],
                                    @[@"系统可用空间", [FileUtils humanFileSize:version.fileSystemFreeSize], @0]
                                    ]
                                ]
                              ];
            break;
        }
        case SettingAppFilesIndex: {
            title = @"本地文件";
            
            NSMutableArray *array = [NSMutableArray array];
            NSString *userInfo, *humainSize;
            User *user;
            _appFiles = [FileUtils appFiles];
            for(NSArray *temp in _appFiles) {
                user = temp[0];
                userInfo = [NSString stringWithFormat:@"%@(%@)", user.name, user.employeeID];
                humainSize = [FileUtils humanFileSize:[NSString stringWithFormat:@"%lli", [temp[1] longLongValue]]];
                [array addObject:@[userInfo, humainSize, @0]];
            }
            self.dataList = @[@[@"文件列表", array]];
            
            break;
        }
        case SettingActionLogIndex: {
            title = @"本地记录";
            self.dataList = @[@[@"记录列表", [[[DatabaseUtils alloc] init] records:NO]]];
            
            UIBarButtonItem *navBtnRefresh = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(actionNavRefresh:)];
            self.navigationItem.rightBarButtonItem = navBtnRefresh;
            break;
        }
    }
    
    self.navigationItem.title = title;
}

#pragma mark - controls action
//- (IBAction)actionBackToMain:(id)sender {
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

- (IBAction)actionNavRefresh:(id)sender {
    if(self.indexRow == SettingActionLogIndex) {
        if([HttpUtils isNetworkAvailable]) {
            [ViewUtils showPopupView:self.view Info:@"同步中..." while:^{
                [ActionLog syncRecords];
                [self initData];
                [self.tableView reloadData];
            }];
        }
        else {
            [ViewUtils showPopupView:self.view Info:@"无网络，不刷新"];
        }
    }
}
#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataList count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList[section][1] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.dataList[section][0];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellID";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if(self.indexRow == SettingActionLogIndex) {
        NSDictionary *dict        = self.dataList[section][1][row];
        cell.textLabel.text       = [NSString stringWithFormat:@"%@/%@", dict[ACTIONLOG_FIELD_ACTNAME], dict[ACTIONLOG_FIELD_ACTOBJ]];
        cell.detailTextLabel.text = ([dict[ACTIONLOG_COLUMN_ISSYNC] boolValue] ? @"Y" : @"N");
        // cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        NSArray *array            = self.dataList[section][1][row];
        cell.textLabel.text       = array[0];
        cell.detailTextLabel.text = array[1];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 18.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (self.indexRow == SettingAppFilesIndex);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger row = [indexPath row];
        User *user = self.appFiles[row][0];
        
        [FileUtils removeUser:user];
        
        [self initData];
        [tableView reloadData];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.indexRow == SettingActionLogIndex) {
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        ActionLogDetailViewController *viewController = [[ActionLogDetailViewController alloc] init];
        viewController.actionLog = self.dataList[section][1][row];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
@end