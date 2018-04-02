//
//  RGMultiSelectViewUtils.m
//  RGMultiSelectTextView
//
//  Created by LD on 2017/7/12.
//  Copyright © 2017年 ld. All rights reserved.
//

#import "RGMultiSelectViewUtils.h"

@implementation RGMTCommenUtils

+ (UIColor *)normalTitleColor {
    return [UIColor blackColor];
}

+ (UIColor *)selectedTitleColor {
    return [UIColor whiteColor];
}

+ (UIColor *)normalBackgroundColor {
    return [UIColor groupTableViewBackgroundColor];
}

+ (UIColor *)selectedBackgroundColor {
    return [UIColor lightGrayColor];
}

+ (UIFont *)defaultFont {
    return [UIFont systemFontOfSize:16.0f];
}

+ (CGSize)sizeWithString:(NSString *)string fits:(CGSize)size multiSelectView:(RGMultiSelectTextView *) multiSelectView {
    CGSize textSize = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[self attributes:multiSelectView] context:nil].size;
    if (textSize.height < 20) {
        textSize.height = 20;
    }
    return textSize;
}

+ (CGSize)sizeWithAttributeString:(NSAttributedString *)attributeString fits:(CGSize)size {
    CGSize textSize = [attributeString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    if (textSize.height < 20) {
        textSize.height = 20;
    }
    return textSize;
}


+ (NSDictionary<NSString *, id> *)attributes:(RGMultiSelectTextView *)multiSelectView {
    
    UIColor *color = multiSelectView.titleNormalColor ? multiSelectView.titleNormalColor : [self normalTitleColor];
    UIFont *font = multiSelectView.font ? multiSelectView.font : [self defaultFont];
    NSDictionary *attributeDict = @{
                                    NSFontAttributeName : font,
                                    NSForegroundColorAttributeName : color,
                                    };
    return attributeDict;
}

+ (NSDictionary<NSString *, id> *)attributesSelected:(RGMultiSelectTextView *) multiSelectView {
    
    UIColor *color = multiSelectView.titleSelectedColor ? multiSelectView.titleSelectedColor : [self selectedTitleColor];
    
    UIFont *font = multiSelectView.font ? multiSelectView.font : [self defaultFont];
    
    NSDictionary *attributeDict = @{
                                    NSFontAttributeName : font,
                                    NSForegroundColorAttributeName : color,
                                    };
    return attributeDict;
}

@end

@interface RGMTLabelCell ()

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIColor *normalBackgroundColor;

@end

@implementation RGMTLabelCell

+ (NSString *)identifier {
    return @"MTLabelCell";
}

- (instancetype)init {
    if (self = [super init]) {
        [self __config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self __config];
    }
    return self;
}

- (void)__config {
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [self.contentView addSubview:_button];
        _button.userInteractionEnabled = NO;
    }
}

- (void)setHideBorder:(BOOL)hideBorder {
    _hideBorder = hideBorder;
    if (_hideBorder) {
        _button.layer.borderWidth = 0.0f;
    } else {
        _button.layer.borderWidth = 1.0f;
    }
}

- (void)setHideBackgroundColor:(BOOL)hideBackgroundColor {
    if (_hideBackgroundColor != hideBackgroundColor) {
        _hideBackgroundColor = hideBackgroundColor;
        self.selected = self.selected;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_button sizeToFit];
    _button.frame = self.contentView.bounds;
    _button.layer.cornerRadius = _button.frame.size.height / 2.0f;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (_hideBackgroundColor) {
        [_button setBackgroundColor:nil];
    } else {
        if (selected) {
            [_button setBackgroundColor:_selectedBackgroundColor ? _selectedBackgroundColor : RGMTCommenUtils.selectedBackgroundColor];
        } else {
            [_button setBackgroundColor:_normalBackgroundColor ? _normalBackgroundColor : RGMTCommenUtils.normalBackgroundColor];
        }
    }
    _button.selected = selected;
}

- (void)setTitle:(NSString *)title withMultiSelectView:(RGMultiSelectTextView *)multiSelectTextView {
    
    _button.layer.borderColor = multiSelectTextView.titleNormalColor.CGColor;
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:[RGMTCommenUtils attributes:multiSelectTextView]];
    NSAttributedString *selectedString = [[NSAttributedString alloc] initWithString:title attributes:[RGMTCommenUtils attributesSelected:multiSelectTextView]];
    
    [_button setAttributedTitle:string forState:UIControlStateNormal];
    [_button setAttributedTitle:selectedString forState:UIControlStateSelected];
    
    _normalBackgroundColor = multiSelectTextView.titleNormalBackgroudColor;
    _selectedBackgroundColor = multiSelectTextView.titleSelectedBackgroudColor;
    [self setNeedsLayout];
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    [_button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [_button setAttributedTitle:attributedTitle forState:UIControlStateSelected];
    [self setNeedsLayout];
}

@end

@interface RGMTDeleteTextField ()

@property (nonatomic, assign) BOOL observer;

@property (nonatomic, strong) UIColor *color;

@end

@implementation RGMTDeleteTextField

- (instancetype)init {
    if (self = [super init]) {
        self.observer = YES;
        self.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.observer = YES;
        self.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

- (void)setObserver:(BOOL)observer {
    if (_observer == observer) {
        return;
    }
    _observer = observer;
    if (_observer) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    }
}

- (void)configWithMultiSelectView:(RGMultiSelectTextView *)multiSelectTextView {
    self.defaultTextAttributes = [RGMTCommenUtils attributes:multiSelectTextView];
    self.color = multiSelectTextView.titleSelectedBackgroudColor;
    self.cursorHide = self.cursorHide;
}

- (void)textDidChange {
    
    if (self.deleteTextFieldDelegate && [self.deleteTextFieldDelegate respondsToSelector:@selector(textDidChange:)]) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performTextDidChangeDelegate) object:nil];
        [self performSelector:@selector(performTextDidChangeDelegate) withObject:nil afterDelay:0.15];
    }
}

- (void)performTextDidChangeDelegate {
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        if (self.deleteTextFieldDelegate && [self.deleteTextFieldDelegate respondsToSelector:@selector(textDidChange:)]) {
            [self.deleteTextFieldDelegate textDidChange:self];
        }
    });
}

- (void)deleteBackward {
    if (self.deleteTextFieldDelegate && [self.deleteTextFieldDelegate respondsToSelector:@selector(deleteBackward:)]) {
        [self.deleteTextFieldDelegate deleteBackward:self];
    }
    [super deleteBackward];
}

- (void)setCursorHide:(BOOL)cursorHide {
    if (cursorHide) {
        self.tintColor = [UIColor clearColor];
    } else {
        self.tintColor = _color ? _color : [RGMTCommenUtils selectedBackgroundColor];
    }
    _cursorHide = cursorHide;
}

- (void)dealloc {
    self.observer = NO;
}

@end

@implementation RGMTTextFiledCell

+ (NSString *)identifier {
    return @"MTTextFiledCell";
}

- (instancetype)init {
    if (self == [super init]) {
        [self __config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self __config];
    }
    return self;
}

- (void)__config {
    if (!_textFiled) {
        _textFiled = [[RGMTDeleteTextField alloc] init];
        [self.contentView addSubview:_textFiled];
    }
    [_textFiled setCursorHide:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textFiled.frame = self.contentView.bounds;
}

@end
