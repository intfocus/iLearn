//
//  PersonalInfoViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "LicenseUtil.h"

static NSString *const kCellIdentifier = @"PersonalInfoTableViewCell";

static const NSInteger kNumberOfSection = 1;
static const NSInteger kNumberOfRow = 1;

typedef NS_ENUM(NSUInteger, TableRow) {
    TableRowAccount = 0,
};

@interface PersonalInfoViewController ()

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"SETTINGS_TITLE", nil);


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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRow;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier];
    }

    switch (indexPath.row) {
        case TableRowAccount:
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_PERSONAL_ACCOUNT", nil);
            cell.detailTextLabel.text = [LicenseUtil userAccount];
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

@end
