//
//  GroupSelectionView.m
//  iLearn
//
//  Created by Charlie Hung on 2015/8/12.
//  Copyright (c) 2015年 intFocus. All rights reserved.
//

#import "GroupSelectionView.h"

static const CGFloat kFontSize = 15.0;
static const CGFloat kOptionHeightOffset = 10.0;
static const NSInteger kMaxTextNumberPerColumn = 5;
static const CGFloat kDescColumnWidth = 150.0;
static const CGFloat kOptionColumnWidth = 56.0;


@interface GroupSelectionView ()

@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSArray *questions;

@end

@implementation GroupSelectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawGrid
{
    self.options = @[@"非常不滿意非常不滿意", @"不滿意不滿意", @"普通普通", @"滿意", @"非常滿意非常滿意", @"非常不滿意非常不滿意", @"不滿意不滿意", @"普通普通", @"滿意"];
    self.questions = @[@"question_1", @"question_2", @"question_3", @"question_4", @"question_5"];

    [self addOptionLabels];
    [self addQuestionLables];
    [self addSeparators];
    [self addCheckButtons];
}

- (CGFloat)maxHeightOfOptions:(NSArray*)options
{
    CGFloat maxHeight = 0;

    for (int i = 0; i < [options count]; i++) {

        NSString *option = options[i];

        if ([option length] > kMaxTextNumberPerColumn) {
            option = [option substringToIndex:kMaxTextNumberPerColumn];
        }

        CGFloat height = [self heightOfString:option];
        if (height > maxHeight) {
            maxHeight = height;
        }
    }

    return maxHeight;
}

- (CGFloat)heightOfString:(NSString*)string
{
    CGSize constraint = CGSizeMake(kFontSize, 20000.0f);
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:kFontSize] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    return size.height;
}

- (CGFloat)totalHeightOfContent
{
    CGFloat totalHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    for (int i = 0; i < [_questions count]; i++) {
        totalHeight += 50.0;
    }

    return totalHeight;
}

- (CGFloat)totalWidthOfContent
{
    CGFloat totalWidth = kDescColumnWidth;

    for (int i = 0; i < [_options count]; i++) {
        totalWidth += kOptionColumnWidth;
    }

    return totalWidth;
}

- (void)addOptionLabels
{
    for (int i = 0; i < [_options count]; i++) {

        NSString *option = _options[i];

        if ([option length] > kMaxTextNumberPerColumn) {

            NSString *subString = [option substringToIndex:kMaxTextNumberPerColumn];

            CGFloat height = [self heightOfString:subString];
            UILabel *selectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDescColumnWidth + (kOptionColumnWidth/2 - kFontSize) + kOptionColumnWidth*i, 0, kFontSize, height)];
            selectionLabel.text = subString;
            selectionLabel.textColor = [UIColor blackColor];
            selectionLabel.font = [UIFont systemFontOfSize:kFontSize];
            selectionLabel.lineBreakMode = NSLineBreakByCharWrapping;
            selectionLabel.numberOfLines = 0;

            [self addSubview:selectionLabel];

            NSString *subString2 = [option substringFromIndex:kMaxTextNumberPerColumn];

            height = [self heightOfString:subString2];
            UILabel *selectionLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(kDescColumnWidth + kOptionColumnWidth/2 + kOptionColumnWidth*i, 0, kFontSize, height)];
            selectionLabel2.text = subString2;
            selectionLabel2.textColor = [UIColor blackColor];
            selectionLabel2.font = [UIFont systemFontOfSize:kFontSize];
            selectionLabel2.lineBreakMode = NSLineBreakByCharWrapping;
            selectionLabel2.numberOfLines = 0;

            [self addSubview:selectionLabel2];

        }
        else {
            CGFloat height = [self heightOfString:option];
            UILabel *selectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDescColumnWidth + (kOptionColumnWidth/2 - kFontSize/2) + kOptionColumnWidth*i, 0, kFontSize, height)];
            selectionLabel.text = option;
            selectionLabel.textColor = [UIColor blackColor];
            selectionLabel.font = [UIFont systemFontOfSize:kFontSize];
            selectionLabel.lineBreakMode = NSLineBreakByCharWrapping;
            selectionLabel.numberOfLines = 0;
            
            [self addSubview:selectionLabel];
        }
    }
}

- (void)addQuestionLables
{
    CGFloat optionHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    for (int i = 0; i < [_questions count]; i++) {

        NSString *question = _questions[i];
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, optionHeight + 50*i, kDescColumnWidth, 50)];
        descLabel.text = question;
        descLabel.textColor = [UIColor blackColor];
        descLabel.font = [UIFont systemFontOfSize:kFontSize];
        descLabel.lineBreakMode = NSLineBreakByCharWrapping;
        descLabel.numberOfLines = 0;

        [self addSubview:descLabel];
    }
}

- (void)addSeparators
{
    [self addRowSeparators];
    [self addColumnSeparators];
}

- (void)addRowSeparators
{
    CGFloat totalWidth = [self totalWidthOfContent];
    CGFloat optionHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, optionHeight, totalWidth, 1)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:separator];

    for (int i = 0; i < [_questions count]; i++) {

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, optionHeight + (i + 1) * 50, totalWidth, 1)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
    }
}

- (void)addColumnSeparators
{
    CGFloat totalHeight = [self totalHeightOfContent];
    CGFloat optionHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kDescColumnWidth, optionHeight, 1, totalHeight - optionHeight)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:separator];

    for (int i = 0; i < [_options count]; i++) {

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kDescColumnWidth + (i + 1) * kOptionColumnWidth, optionHeight, 1, totalHeight - optionHeight)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
    }
}

- (void)addCheckButtons
{
    CGFloat optionHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    for (int rowIndex = 0; rowIndex < [_questions count]; rowIndex++) {


        for (int columnIndex = 0; columnIndex < [_options count]; columnIndex++) {

            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kDescColumnWidth + 5 + columnIndex * kOptionColumnWidth, optionHeight + 5 + rowIndex * 50, 32, 32)];

            [button setImage:[UIImage imageNamed:@"img_unchecked"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"img_checked"] forState:UIControlStateSelected];
            button.tag = rowIndex * 100 + columnIndex;
            [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];

            [self addSubview:button];
        }

    }

}

- (void)buttonTouched:(id)sender
{
    UIButton *button = sender;
    button.selected = !button.selected;
}

@end
