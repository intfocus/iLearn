//
//  ViewController.m
//  WebView-1
//
//  Created by lijunjie on 15-4-1.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "DisplayViewController.h"
#import "const.h"
#import "FileUtils.h"
#import "MBProgressHUD.h"
#import "CoursePackageDetail.h"
#import "ExtendNSLogFunctionality.h"

@interface DisplayViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView; // 演示pdf/视频/html
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSString *coursePath = [FileUtils coursePath:self.packageDetail.courseId Ext:self.packageDetail.courseExt];
    if([FileUtils checkFileExist:coursePath isDir:NO]) {
        NSURL *targetURL = [NSURL fileURLWithPath:coursePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [self.webView loadRequest:request];
    }
    else {
        NSString *htmlString = @" \
        <html>                \
        <body>                \
        <div style = 'position:fixed;left:40%;top:40%;font-size:20px;'> \
        该页面为空.             \
        </div>                \
        </body>               \
        </html>";
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
    
    self.labelCourseName.text = self.packageDetail.courseName;
    [self.view bringSubviewToFront:self.btnBack];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSString *html = [NSString stringWithFormat:@"<html><body>loading...</body></html>"];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (IBAction)actionDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
