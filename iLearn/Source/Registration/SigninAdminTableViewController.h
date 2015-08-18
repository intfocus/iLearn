//
//  SigninAdminTableViewController.h
//  iLearn
//
//  Created by lijunjie on 15/8/17.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "ContentViewController.h"
#import "ExamTabelViewCell.h"
#import "SigninFormViewController.h"
#import "QRCodeReaderViewController.h"

@interface SigninAdminTableViewController : ContentViewController <ContentViewProtocal, UITableViewDataSource, UITableViewDelegate, ContentTableViewCellDelegate, SigninFormViewControllerProtocol, QRCodeReaderDelegate>

@end
