//
//  GroupSelectionView.h
//  iLearn
//
//  Created by Charlie Hung on 2015/8/12.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupSelectionViewDelegate <NSObject>

- (void)groupViewButtonTouched;

@end


@interface GroupSelectionView : UIView

@property (weak, nonatomic) id<GroupSelectionViewDelegate> delegate;

- (void)setQuestionnaireData:(NSArray*)data;
- (void)drawGrid;
- (CGFloat)totalHeightOfContent;
- (BOOL)allQuestionsAnswered;

@end
