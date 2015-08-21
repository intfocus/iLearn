//
//  ViewController.m
//  WebView-1
//
//  Created by lijunjie on 15-4-1.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "DisplayViewController.h"
#import "const.h"
#import "FileUtils+Course.h"
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
    
    NSString *coursePath;
    if([FileUtils isCourseDownloaded:self.packageDetail.courseID Type:kPackageCourse Ext:self.packageDetail.courseExt]) {
        if([self.packageDetail isHTML]) {
            NSError *error;
            coursePath = [FileUtils coursePath:self.packageDetail.courseID Type:kPackageCourse Ext:self.packageDetail.courseExt UseExt:NO];
            NSString *htmlPath = [NSString stringWithFormat:@"%@/%@", coursePath, @"index.html"];
            NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
            NSURL *baseURL = [NSURL fileURLWithPath:coursePath];
            if(error) {
                htmlString = [NSString stringWithFormat:@" \
                              <html>                    \
                                <body>                     \
                                  <div style = 'position:fixed;left:40%%;top:40%%;font-size:20px;'> \
                                    load %@ failed for %@.         \
                                  </div>            \
                                </body>               \
                              </html>", htmlPath, [error localizedDescription]];
            }
            [self.webView loadHTMLString:htmlString baseURL:baseURL];
        } else {
            coursePath = [FileUtils coursePath:self.packageDetail.courseID Type:kPackageCourse Ext:self.packageDetail.courseExt UseExt:YES];
            NSURL *targetURL = [NSURL fileURLWithPath:coursePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [self.webView loadRequest:request];
        }
    }
    else {
        NSString *htmlString = [NSString stringWithFormat:@" \
                 <html>                    \
                   <body>                  \
                     <div style = 'position:fixed;left:40%%;top:40%%;font-size:20px;'> \
                        未找到页面: %@.      \
                     </div>                \
                   </body>                 \
                 </html>", [self.packageDetail to_s]];
        [self.webView loadHTMLString:htmlString baseURL:nil];
    }
    self.webView.scalesPageToFit = YES;
    
    self.labelCourseName.text = self.packageDetail.courseName;
    [self.view bringSubviewToFront:self.btnBack];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.packageDetail isVideo] || [self.packageDetail isPDF]) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleShowStatusPanel)];
        tapGesture.numberOfTapsRequired = 1; //点击次数
        tapGesture.numberOfTouchesRequired = 1; //点击手指数
        tapGesture.delegate = self;
        [self.webView addGestureRecognizer:tapGesture];
        
        if([self.packageDetail isPDF]) {
            self.offsetY = [self.packageDetail pdfProgress];
            [self.webView.scrollView setContentOffset:CGPointMake(0, self.offsetY) animated:NO];
        }
    }
//    else if([self.packageDetail isPDF]) {
//        self.webView.scrollView.delegate = self;
//        
//        self.offsetY = [self.packageDetail pdfProgress];
//        [self.webView.scrollView setContentOffset:CGPointMake(0, self.offsetY) animated:NO];
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSString *html = [NSString stringWithFormat:@"<html><body>loading...</body></html>"];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    NSString *html = [NSString stringWithFormat:@"<html><body>收到IOS系统内存警告，请关闭该界面，重新打开，谢谢</body></html>"];
    [self.webView loadHTMLString:html baseURL:nil];
}

- (IBAction)actionDismiss:(id)sender {
    NSDictionary *dict;
    if([self.packageDetail isPDF]) {
        self.offsetY         = self.webView.scrollView.contentOffset.y;
        float totalHeight    = self.webView.scrollView.contentSize.height;
        float screentHeight  = [[UIScreen mainScreen] bounds].size.height;
        float readPercentage = (self.offsetY + screentHeight * 1.5) / totalHeight * 100.0;
        dict = @{@"totalHeight": [NSNumber numberWithFloat:totalHeight],
                 @"currentHeight": [NSNumber numberWithFloat:self.offsetY],
                 @"screenHeight":[NSNumber numberWithFloat:screentHeight],
                 @"readPercentage":[NSNumber numberWithFloat:readPercentage]};
    }
    else {
        dict = @{};
    }
    [self.packageDetail recordProgress:dict];
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.webView = nil;
    }];
}

/**
 *  播放视频时，点击视频界面，交替显示状态面板
 */
- (void)toggleShowStatusPanel {
    self.statusPanel.hidden = !self.statusPanel.hidden;
}
    
#pragma mark - UIWebview - UIScrollView Delgate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    float currentY = scrollView.contentOffset.y;
//    BOOL isHidden  = (currentY > self.offsetY);
//    if(isHidden != self.statusPanel.hidden) {
//        self.statusPanel.hidden = isHidden;
//    }
//    //NSLog(@"currentY: %f, lastY: %f", currentY, self.offsetY);
//    self.offsetY   = currentY;
//}

#pragma mark - UIWebview - UIGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIButton Drag
//- (void)actionSwitchPanel:(UIButton *)sender {
//    self.statusPanel.hidden = !self.statusPanel.hidden;
//    NSString *imageName = self.statusPanel.hidden ? @"iconArrowLeft" : @"iconArrowRight";
//}
//
//- (void)dragMoving:(UIButton *)btn withEvent:ev {
//    btn.tag = 1;
//    btn.center = [[[ev allTouches] anyObject] locationInView:self.view];
//}
//
//- (void)dragEnded:(UIButton *)btn withEvent:ev {
//    btn.tag = 0;
//    btn.center = [[[ev allTouches] anyObject] locationInView:self.view];
//}
@end
