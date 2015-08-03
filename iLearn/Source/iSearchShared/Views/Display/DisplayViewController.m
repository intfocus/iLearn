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
//#import <JavaScriptCore/JavaScriptCore.h>

@interface DisplayViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView; // 演示pdf/视频/html
@property (weak, nonatomic) IBOutlet UIView *statusPanel;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *labelCourseName;
@property (assign, nonatomic) float offsetY;
@end

@implementation DisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.offsetY = 0.0;
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
        <html>                    \
            <body>                \
                <div style = 'position:fixed;left:40%;top:40%;font-size:20px;'> \
                该页面为空.         \
                </div>            \
            </body>               \
        </html>";
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
    
    self.labelCourseName.text = self.packageDetail.courseName;
    [self.view bringSubviewToFront:self.btnBack];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.packageDetail isVideo]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleShowStatusPanel)];
        tapGesture.numberOfTapsRequired = 1; //点击次数
        tapGesture.numberOfTouchesRequired = 1; //点击手指数
        [self.webView addGestureRecognizer:tapGesture];
    }
    else if([self.packageDetail isPDF]) {
        self.webView.scrollView.delegate = self;
        
        self.offsetY = [self.packageDetail pdfProgress];
        [self.webView.scrollView setContentOffset:CGPointMake(0, self.offsetY) animated:NO];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.webView reload];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSString *html = [NSString stringWithFormat:@"<html><body>loading...</body></html>"];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (IBAction)actionDismiss:(id)sender {
    NSDictionary *dict;
    if([self.packageDetail isPDF]) {
        dict = @{@"totalHeight": [NSNumber numberWithFloat:self.webView.scrollView.contentSize.height], @"currentHeight": [NSNumber numberWithFloat:self.offsetY]};
    }
    else {
        dict = @{};
    }
    [self.packageDetail recordProgress:dict];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  播放视频时，点击视频界面，交替显示状态面板
 */
- (void)toggleShowStatusPanel {
    self.statusPanel.hidden = !self.statusPanel.hidden;
}
    
#pragma mark - UIScrollView Delgate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float currentY = scrollView.contentOffset.y;
    BOOL isHidden  = (currentY > self.offsetY);
    if(isHidden != self.statusPanel.hidden) {
        self.statusPanel.hidden = isHidden;
    }
    //NSLog(@"currentY: %f, lastY: %f", currentY, self.offsetY);
    self.offsetY   = currentY;
}
@end
