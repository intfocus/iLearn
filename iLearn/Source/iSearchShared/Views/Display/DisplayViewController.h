//
//  ViewController.h
//  WebView-1
//
//  Created by lijunjie on 15-4-1.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CoursePackageDetail;

@interface DisplayViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) CoursePackageDetail *packageDetail;
@end

