//
//  ExamUtil.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/28.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExamUtil : NSObject

+ (NSArray*)loadExams;
+ (NSString*)titleFromContent:(NSDictionary*)content;
+ (NSString*)descFromContent:(NSDictionary*)content;
+ (NSInteger)expirationDateFromContent:(NSDictionary*)content;
+ (void)parseContentIntoDB:(NSDictionary*)content;

@end
