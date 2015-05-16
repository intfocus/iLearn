//
//  DashboardViewController.m
//  iLearn
//
//  Created by Charlie Hung on 2015/5/13.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "DashboardViewController.h"
#import "ListTableViewController.h"

static NSString *const kShowQuestionnaireSegue = @"showQuestionnairePage";
static NSString *const kShowSettingsSegue = @"showSettingsPage";

@interface DashboardViewController ()

// Button Area Views
@property (weak, nonatomic) IBOutlet UIView *coursePackView;
@property (weak, nonatomic) IBOutlet UIView *lectureView;
@property (weak, nonatomic) IBOutlet UIView *reminderView;
@property (weak, nonatomic) IBOutlet UIView *questionnaireView;
@property (weak, nonatomic) IBOutlet UIView *examView;

// Button Labels
@property (weak, nonatomic) IBOutlet UILabel *coursePackLabel;
@property (weak, nonatomic) IBOutlet UILabel *lectureLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionnaireLabel;
@property (weak, nonatomic) IBOutlet UILabel *examLabel;

@property (weak, nonatomic) IBOutlet UILabel *serviceCallLabel;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSString *serviceCallNumber = @"400-400-400";

    // Setup label contents
    self.title = NSLocalizedString(@"DASHBOARD_TITLE", nil);
    self.coursePackLabel.text = NSLocalizedString(@"DASHBOARD_COURSE_PACK", nil);
    self.lectureLabel.text = NSLocalizedString(@"DASHBOARD_LECTURE", nil);
    self.reminderLabel.text = NSLocalizedString(@"DASHBOARD_REMINDER", nil);
    self.questionnaireLabel.text = NSLocalizedString(@"DASHBOARD_QUESTIONNAIRE", nil);
    self.examLabel.text = NSLocalizedString(@"DASHBOARD_EXAM", nil);
    self.serviceCallLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DASHBOARD_SERVICE_CALL", nil), serviceCallNumber];

    // Setup border of button area views
    [self setupBorderOfView:_coursePackView];
    [self setupBorderOfView:_lectureView];
    [self setupBorderOfView:_reminderView];
    [self setupBorderOfView:_questionnaireView];
    [self setupBorderOfView:_examView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowQuestionnaireSegue]) {
        ListTableViewController* listVC = (ListTableViewController*)segue.destinationViewController;
        listVC.listType = ListViewTypeQuestionnaire;
    }
}

#pragma mark - Helper Functions

- (void)setupBorderOfView:(UIView*)view {
    view.layer.cornerRadius = 10.0;
    view.layer.borderWidth = 2.0;
    view.layer.borderColor = [[UIColor darkGrayColor] CGColor];
}

#pragma mark - IBActions

- (IBAction)settingsTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowSettingsSegue sender:nil];
}

- (IBAction)coursePackTouced:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)lectureTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)reminderTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)questionnaireTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self performSegueWithIdentifier:kShowQuestionnaireSegue sender:nil];
}

- (IBAction)examTouched:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
