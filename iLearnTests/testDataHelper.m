//
//  testDataHelper.m
//  iLearn
//
//  Created by lijunjie on 15/7/30.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DataHelper.h"
#import "CoursePackage.h"

@interface testDataHelper : XCTestCase

@end

@implementation testDataHelper

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCoursePackages {
    NSArray *dataList = [DataHelper coursePackages:NO];
}

@end
