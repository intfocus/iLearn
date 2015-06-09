//
//  QuestionnaireUtil.h
//  iLearn
//
//  Created by Charlie Hung on 2015/5/17.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionnaireUtil : NSObject

+ (NSArray*)loadQuestionaires;
+ (NSString*)titleFromContent:(NSDictionary*)content;
+ (NSString*)descFromContent:(NSDictionary*)content;
+ (NSInteger)expirationDateFromContent:(NSDictionary*)content;

@end
