//
//  GroupSelectionView.m
//  iLearn
//
//  Created by Charlie Hung on 2015/8/12.
//  Copyright (c) 2015 intFocus. All rights reserved.
//

#import "GroupSelectionView.h"
#import "Constants.h"

static const CGFloat kFontSize = 15.0;
static const CGFloat kOptionHeightOffset = 10.0;
static const CGFloat kQuestionHeightOffset = 16.0;
static const CGFloat kQuestionWidthOffset = 8.0;
static const NSInteger kMaxTextNumberPerColumn = 5;
static const CGFloat kQuestionColumnWidth = 150.0;
static const CGFloat kOptionColumnWidth = 56.0;
static const CGFloat kSeparatorWidth = 1.0;
static const CGFloat kMinQuestionHeight = 52.0;


@interface GroupSelectionView ()
{
    BOOL isSingleSelect;
}

@property (strong, nonatomic) NSMutableArray *questionnaires;
@property (strong, nonatomic) NSMutableArray *options;
@property (strong, nonatomic) NSMutableArray *questions;
@property (strong, nonatomic) NSMutableArray *optionHeightCache;
@property (strong, nonatomic) NSMutableArray *questionHeightCache;
@property (strong, nonatomic) NSNumber *maxHeight;
@property (strong, nonatomic) NSMutableArray *checkedOptionMatrix;

@end

@implementation GroupSelectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setQuestionnaireData:(NSMutableArray*)data
{
    self.questionnaires = data;

    NSDictionary *firstQuestion = [data firstObject];

    if (firstQuestion == nil) {
        return;
    }

    NSArray *options = firstQuestion[QuestionnaireQuestionOptions];
    self.options = [NSMutableArray array];
    for (NSDictionary *option in options) {
        [_options addObject:option[QuestionnaireQuestionOptionTitle]];
    }

    self.questions = [NSMutableArray array];
    for (NSDictionary *question in data) {
        [_questions addObject:question[QuestionnaireQuestionTitle]];
    }

    [self resetCheckedMatrix];

    QuestionnaireQuestionTypes type = [firstQuestion[QuestionnaireQuestionType] integerValue];
    isSingleSelect =  type == QuestionnaireQuestionsTypeMultiple? NO: YES;

    for (int questionIndex = 0; questionIndex < [_questions count]; questionIndex++) {

        NSDictionary *question = data[questionIndex];
        NSArray *options = question[QuestionnaireQuestionOptions];
        NSInteger selectedOptions = 0;

        for (NSInteger optionIndex = 0; optionIndex < [_options count]; optionIndex++) {

#warning bug:options.count < _options.count then crash
            NSDictionary *option = options[optionIndex];
            BOOL selected = [option[QuestionnaireQuestionOptionSelected] boolValue];

            if (selected) {
                selectedOptions |= 1 << optionIndex;
            }
        }

        _checkedOptionMatrix[questionIndex] = @(selectedOptions);
    }
}

- (void)drawGrid
{
//    _checkedOptionMatrix[1] = @7;
//    _checkedOptionMatrix[2] = @129;
//    _checkedOptionMatrix[4] = @256;

//    isSingleSelect = NO;

    [self resetCache];
    [self addOptionLabels];
    [self addQuestionLables];
    [self addSeparators];
    [self addCheckButtons];
}

- (void)resetCache
{
    self.maxHeight = @0;
    self.questionHeightCache = [NSMutableArray arrayWithCapacity:[_questions count]];
    for (int i = 0; i < [_questions count]; i++) {
        [_questionHeightCache addObject:@0];
    }
    self.optionHeightCache = [NSMutableArray arrayWithCapacity:[_options count]];
    for (int i = 0; i < [_options count]; i++) {
        [_optionHeightCache addObject:@0];
    }
}

- (void)resetCheckedMatrix
{
    self.checkedOptionMatrix = [NSMutableArray arrayWithCapacity:[_questions count]];
    for (int i = 0; i < [_questions count]; i++) {
        [_checkedOptionMatrix addObject:@0];
    }
}

- (CGFloat)maxHeightOfOptions:(NSArray*)options
{
    if (![_maxHeight isEqualToNumber:@0]) {
        return [_maxHeight floatValue];
    }

    NSNumber *maxHeight = @0;

    for (int i = 0; i < [_optionHeightCache count]; i++) {

        NSNumber *optionHeight = _optionHeightCache[i];

        if ([optionHeight compare:maxHeight] == NSOrderedDescending) {
            maxHeight = optionHeight;
        }
    }

    self.maxHeight = maxHeight;
    return [maxHeight floatValue];
}

- (CGFloat)heightOfString:(NSString*)string withFontSize:(CGFloat)fontSize inWidth:(CGFloat)width
{
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constraint lineBreakMode:NSLineBreakByCharWrapping];
    return size.height;
}

- (CGFloat)heightOfOption:(NSString*)option
{
    return [self heightOfString:option withFontSize:kFontSize inWidth:kFontSize];
}

- (CGFloat)heightOfQuestion:(NSString*)question
{
    CGFloat height = [self heightOfString:question withFontSize:kFontSize inWidth:kQuestionColumnWidth - kQuestionWidthOffset] + kQuestionHeightOffset;
    height = height < kMinQuestionHeight? kMinQuestionHeight: height;

    return height;
}

- (CGFloat)totalQuestionHeightBeforeIndex:(NSInteger)index
{
    CGFloat totalHeight = 0;

    for (int i = 0; i < index; i++) {
        totalHeight += [_questionHeightCache[i] floatValue];
    }

    return totalHeight;
}

- (CGFloat)totalHeightOfContent
{
    CGFloat totalHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    for (int i = 0; i < [_questionHeightCache count]; i++) {
        totalHeight += [_questionHeightCache[i] floatValue];
    }

    return totalHeight;
}

- (CGFloat)totalWidthOfContent
{
    CGFloat totalWidth = kQuestionColumnWidth;

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

            NSString *leftColumnString = [option substringToIndex:kMaxTextNumberPerColumn];

            CGFloat height = [self heightOfOption:leftColumnString];
            _optionHeightCache[i] = @(height);
            UILabel *optionLabelLeft = [[UILabel alloc] initWithFrame:CGRectMake(kQuestionColumnWidth + (kOptionColumnWidth/2 - kFontSize) + kOptionColumnWidth*i, 0, kFontSize, height)];
            optionLabelLeft.text = leftColumnString;
            optionLabelLeft.textColor = [UIColor blackColor];
            optionLabelLeft.font = [UIFont systemFontOfSize:kFontSize];
            optionLabelLeft.lineBreakMode = NSLineBreakByCharWrapping;
            optionLabelLeft.numberOfLines = 0;

            [self addSubview:optionLabelLeft];

            NSString *rightColumnString = [option substringFromIndex:kMaxTextNumberPerColumn];

            height = [self heightOfOption:rightColumnString];
            UILabel *optionLabelRight = [[UILabel alloc] initWithFrame:CGRectMake(kQuestionColumnWidth + kOptionColumnWidth/2 + kOptionColumnWidth*i, 0, kFontSize, height)];
            optionLabelRight.text = rightColumnString;
            optionLabelRight.textColor = [UIColor blackColor];
            optionLabelRight.font = [UIFont systemFontOfSize:kFontSize];
            optionLabelRight.lineBreakMode = NSLineBreakByCharWrapping;
            optionLabelRight.numberOfLines = 0;

            [self addSubview:optionLabelRight];
        }
        else {
            CGFloat height = [self heightOfOption:option];
            _optionHeightCache[i] = @(height);
            UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kQuestionColumnWidth + (kOptionColumnWidth/2 - kFontSize/2) + kOptionColumnWidth*i, 0, kFontSize, height)];
            optionLabel.text = option;
            optionLabel.textColor = [UIColor blackColor];
            optionLabel.font = [UIFont systemFontOfSize:kFontSize];
            optionLabel.lineBreakMode = NSLineBreakByCharWrapping;
            optionLabel.numberOfLines = 0;
            
            [self addSubview:optionLabel];
        }
    }
}

- (void)addQuestionLables
{
    CGFloat optionHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    for (int i = 0; i < [_questions count]; i++) {

        NSString *question = _questions[i];

        CGFloat height = [self heightOfQuestion:question];
        _questionHeightCache[i] = @(height);

        CGFloat totalQuestionHeightBefore = [self totalQuestionHeightBeforeIndex:i];

        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, optionHeight + totalQuestionHeightBefore, kQuestionColumnWidth - kQuestionWidthOffset, height)];
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

    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, optionHeight, totalWidth, kSeparatorWidth)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:separator];

    for (int i = 0; i < [_questions count]; i++) {

        CGFloat totalQuestionHeightToThis = [self totalQuestionHeightBeforeIndex:i+1];

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, optionHeight + totalQuestionHeightToThis, totalWidth, kSeparatorWidth)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
    }
}

- (void)addColumnSeparators
{
    CGFloat totalHeight = [self totalHeightOfContent];
    CGFloat optionHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kQuestionColumnWidth, optionHeight, kSeparatorWidth, totalHeight - optionHeight)];
    separator.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:separator];

    for (int i = 0; i < [_options count]; i++) {

        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(kQuestionColumnWidth + (i + 1) * kOptionColumnWidth, optionHeight, kSeparatorWidth, totalHeight - optionHeight)];
        separator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:separator];
    }
}

- (void)addCheckButtons
{
    CGFloat optionHeight = [self maxHeightOfOptions:_options] + kOptionHeightOffset;

    for (int rowIndex = 0; rowIndex < [_questions count]; rowIndex++) {

        NSInteger checkedOptions = [_checkedOptionMatrix[rowIndex] integerValue];

        for (int columnIndex = 0; columnIndex < [_options count]; columnIndex++) {

            CGFloat totalQuestionHeightToThis = [self totalQuestionHeightBeforeIndex:rowIndex];

            CGFloat leftX = kQuestionColumnWidth + columnIndex * kOptionColumnWidth;
            CGFloat upperY = optionHeight + totalQuestionHeightToThis;

            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(leftX, upperY, kOptionColumnWidth, [_questionHeightCache[rowIndex] floatValue])];
            NSInteger mask = 1 << columnIndex;
            BOOL checked = (checkedOptions & mask) > 0;
            button.selected = checked;

            [button setContentMode:UIViewContentModeCenter];
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
    BOOL newValue = !button.selected;

    NSInteger tag = button.tag;
    NSInteger questionIndex = tag/100;
    NSInteger optionIndex = tag%100;

    NSInteger checkedOptions = [_checkedOptionMatrix[questionIndex] integerValue];
    NSInteger mask = 1 << optionIndex;

    if (newValue) { // Is going to be checked

        if (!isSingleSelect || checkedOptions == 0) {
            NSInteger checkedStatus = checkedOptions | mask;
            _checkedOptionMatrix[questionIndex] = @(checkedStatus);
            _questionnaires[questionIndex][QuestionnaireQuestionAnswered] = checkedStatus > 0? @1: @0;
            button.selected = newValue;

            NSArray *options = _questionnaires[questionIndex][QuestionnaireQuestionOptions];
            options[optionIndex][QuestionnaireQuestionOptionSelected] = @(newValue);
        }
    }
    else {
        NSInteger checkedStatus = checkedOptions ^ mask;
        _checkedOptionMatrix[questionIndex] = @(checkedStatus);
        _questionnaires[questionIndex][QuestionnaireQuestionAnswered] = checkedStatus > 0? @1: @0;
        button.selected = newValue;

        NSArray *options = _questionnaires[questionIndex][QuestionnaireQuestionOptions];
        options[optionIndex][QuestionnaireQuestionOptionSelected] = @(newValue);
    }

    if ([_delegate respondsToSelector:@selector(groupViewButtonTouched)]) {
        [_delegate performSelector:@selector(groupViewButtonTouched)];
    }

//    [self printCheckedOptionsMatrix];
}

- (BOOL)allQuestionsAnswered
{
    BOOL allAnswered = YES;

    for (NSNumber *checked in _checkedOptionMatrix) {

        NSInteger checkedOptions = [checked integerValue];

        if (checkedOptions == 0) {
            allAnswered = NO;
            break;
        }
    }

    return allAnswered;
}

- (void)printCheckedOptionsMatrix
{
    for (NSNumber *checked in _checkedOptionMatrix) {

        NSInteger value = [checked integerValue];
        NSString *str = @"";
        for (NSUInteger i = 0; i < 9 ; i++) {
            // Prepend "0" or "1", depending on the bit
            str = [NSString stringWithFormat:@"%@%@", str, value & 1 ? @"1" : @"0"];
            value >>= 1;
        }

        NSLog(@"%@", str);
    }
    NSLog(@"=========");
    NSLog(@"allQuestionsAnswered: %@", [self allQuestionsAnswered]? @"YES": @"NO");
    NSLog(@"=========");
}

@end
