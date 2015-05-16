//
//  ListTableViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/16.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "ListTableViewController.h"
#import "QuestionnaireCell.h"
#import "DetailViewController.h"
#import "QuestionnaireUtil.h"

static NSString *const kShowDetailSegue = @"showDetailPage";

static NSString *const kQuestionnaireCellIdentifier = @"QuestionnaireCell";

@interface ListTableViewController ()

@property (strong, nonatomic) NSArray *contents;

@end


@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    switch (_listType) {
        case ListViewTypeExam:
            break;
        case ListViewTypeQuestionnaire:
            self.contents = [QuestionnaireUtil loadQuestionaires];
            break;
        default:
            break;
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowDetailSegue]) {

        DetailViewController *detailVC = (DetailViewController*)segue.destinationViewController;

        switch (_listType) {
            case ListViewTypeExam:
                break;
            case ListViewTypeQuestionnaire:
                detailVC.titleString = [[QuestionnaireUtil titleFromContent:sender] stringByAppendingString:NSLocalizedString(@"LIST_DETAIL", nil)];
                detailVC.descString = [QuestionnaireUtil descFromContent:sender];
                break;
            default:
                break;
        }
    }

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contents count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_listType) {
        case ListViewTypeExam:
            return nil;
            break;
        case ListViewTypeQuestionnaire:
            return [self tableView:tableView cellForQuestionnaireRowAtIndexPath:indexPath];
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForQuestionnaireRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionnaireCell *cell = [tableView dequeueReusableCellWithIdentifier:kQuestionnaireCellIdentifier];
    cell.delegate = self;

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

    cell.titleLabel.text = [QuestionnaireUtil titleFromContent:content];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd"];
    NSInteger epochTime = [QuestionnaireUtil expirationDateFromContent:content];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:epochTime];
    NSString *expirationDateString = [formatter stringFromDate:date];

    cell.expirationDateLabel.text = expirationDateString;

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)didSelectInfoButtonOfCell:(ListTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSLog(@"didSelectInfoButtonOfCell:");
    NSLog(@"indexPath.row: %d", indexPath.row);

    NSDictionary *content = [_contents objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:kShowDetailSegue sender:content];
}

- (void)didSelectActionButtonOfCell:(ListTableViewCell*)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSLog(@"didSelectActionButtonOfCell:");
    NSLog(@"indexPath.row: %d", indexPath.row);
}

@end
