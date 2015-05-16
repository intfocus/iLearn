//
//  SettingsViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "SettingsViewController.h"

static const NSInteger kNumberOfSection = 2;
static const NSInteger kNumberOfPersonalSettings = 2;
static const NSInteger kNumberOfApplicationSettings = 2;

static NSString *const kCellIdentifier = @"SettingsTableViewCell";

static NSString *const kShowPersonalInfoSegue = @"showPersonalInfo";
static NSString *const kShowPersonalQRCodeSegue = @"showPersonalQRCode";
static NSString *const kShowApplicationInfoSegue = @"showApplicationInfo";

typedef NS_ENUM(NSUInteger, TableSection) {
    TableSectionPersonal = 0,
    TableSectionApplication,
};

typedef NS_ENUM(NSUInteger, PersonalSection) {
    PersonalSectionInfo = 0,
    PersonalSectionQRCode,
};

typedef NS_ENUM(NSUInteger, ApplicationSection) {
    ApplicationSectionCleanCache = 0,
    ApplicationSectionAbout,
};

typedef NS_ENUM(NSUInteger, TableViewCellTag) {
    TableViewCellPersonalInfo = 1,
    TableViewCellPersonalQRCode,
    TableViewCellApplicationCleanCache,
    TableViewCellApplicationAbout,
};


@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = NSLocalizedString(@"SETTINGS_TITLE", nil);
    [self.closeButton setTitle:NSLocalizedString(@"SETTINGS_BUTTON_CLOSE", nil)];

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

- (IBAction)closeTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSection;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case TableSectionPersonal:
            return NSLocalizedString(@"SETTINGS_PERSONAL_TITLE", nil);
            break;
        case TableSectionApplication:
            return NSLocalizedString(@"SETTINGS_APPLICATION_TITLE", nil);
            break;
        default:
            return @"";
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TableSectionPersonal:
            return kNumberOfPersonalSettings;
            break;
        case TableSectionApplication:
            return kNumberOfApplicationSettings;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }

    switch (indexPath.section) {
        case TableSectionPersonal:
            cell = [self personalSectionCell:cell ofRow:indexPath.row];
            break;

        case TableSectionApplication:
            cell = [self applicationSectionCell:cell ofRow:indexPath.row];
            break;

        default:
            break;
    }

    return cell;
}

- (UITableViewCell*)personalSectionCell:(UITableViewCell*)cell ofRow:(NSInteger)row
{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    switch (row) {
        case PersonalSectionInfo:
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_PERSONAL_INFO", nil);
            cell.tag = TableViewCellPersonalInfo;
            break;
        case PersonalSectionQRCode:
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_PERSONAL_QRCODE", nil);
            cell.tag = TableViewCellPersonalQRCode;
            break;
        default:
            break;
    }
    return cell;
}

- (UITableViewCell*)applicationSectionCell:(UITableViewCell*)cell ofRow:(NSInteger)row
{
    switch (row) {
        case ApplicationSectionCleanCache:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_APPLICATION_CLEAN_CACHE", nil);
            cell.tag = TableViewCellApplicationCleanCache;
            break;
        case ApplicationSectionAbout:
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_APPLICATION_ABOUT", nil);
            cell.tag = TableViewCellApplicationAbout;
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    TableViewCellTag tag = cell.tag;

    switch (tag) {
        case TableViewCellPersonalInfo:
            [self performSegueWithIdentifier:kShowPersonalInfoSegue sender:nil];
            break;
        case TableViewCellPersonalQRCode:
            [self performSegueWithIdentifier:kShowPersonalQRCodeSegue sender:nil];
            break;
        case TableViewCellApplicationCleanCache:

            break;
        case TableViewCellApplicationAbout:
            [self performSegueWithIdentifier:kShowApplicationInfoSegue sender:nil];
            break;
        default:
            break;
    }
}

@end
