//
//  iLearnTests.m
//  iLearnTests
//
//  Created by Charlie Hung on 2015/5/13.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface iLearnTests : XCTestCase

@end

@implementation iLearnTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testEnumerate {
    NSArray *array = @[@1, @3, @5, @7];
    // solution 1.
    for(NSNumber *num in array) NSLog(@"s1: %@", num);
    
    // solution 2.
    for(int i=0; i < [array count]; i++) NSLog(@"s2: %@", array[i]);
    
    // solution 3.
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"s3: %@ %lu", obj, (unsigned long)idx);
    }];
    
    // obj, idx all reversed
    [array enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"s3.2: %@ %lu", obj, (unsigned long)idx);
    }];
    
    // solution 4
    NSEnumerator *enumerator = [array objectEnumerator];
    NSNumber *num;
    while (num = [enumerator nextObject]) {
        NSLog(@"s4: %@", num);
    }
    
    // solution 5
    int index = 0;
    while(index < [array count]) {
        NSLog(@"s5: %@", array[index]);
        index ++;
    }

    index = 0;
    do {
        NSLog(@"s5.2: %@", array[index]);
        index ++;
    } while (index < [array count]);
}

- (void)testSort {
    NSArray *array = @[@3, @6, @5, @1, @2, @7, @4];
    
    // solution 1
    NSArray *arraySort1 = [array sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"s1. %@", arraySort1);
    
    // solution 2
    NSArray *arraySort2 = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *num1 = (NSNumber *)obj1, *num2 = (NSNumber *)obj2;
        return [num1 compare:num2];
    }];
    NSLog(@"s2. %@", arraySort2);
    
    // solution 3
    NSSortDescriptor *compare = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *arraySort3 = [array sortedArrayUsingDescriptors:@[compare]];
    NSLog(@"s3. %@", arraySort3);
}

- (void)testASCII {
    NSString *string = @"A";
    int asciiCode = [string characterAtIndex:0]; //65
    NSLog(@"A ascii: %i", asciiCode);
    
    //ASCII to NSString
    asciiCode = 66;
    string =[NSString stringWithFormat:@"%c",asciiCode]; //A
    NSLog(@"66 ascii: %@", string);
}

- (void)testCountSet {
    NSArray *array = @[@1, @1, @2, @2, @3, @3, @4, @4];
    NSCountedSet *noDuplicateSet = [NSCountedSet setWithArray:array];
    NSArray *noDuplicateArray = [noDuplicateSet allObjects];
    XCTAssertNotNil(noDuplicateArray);
}

- (void)testReverse {
    NSString *str = @"hello world";
    
}
@end
