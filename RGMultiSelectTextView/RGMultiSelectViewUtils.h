//
//  RGMultiSelectViewUtils.h
//  RGMultiSelectTextView
//
//  Created by LD on 2017/7/12.
//  Copyright © 2017年 ld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGMultiSelectTextView.h"

// UI Default Config

@interface RGMTCommenUtils : NSObject

+ (CGSize)sizeWithString:(NSString *)string fits:(CGSize)size multiSelectView:(RGMultiSelectTextView *) multiSelectView;
+ (CGSize)sizeWithAttributeString:(NSAttributedString *)attributeString fits:(CGSize)size;

+ (NSDictionary<NSString *, id> *)attributes:(RGMultiSelectTextView *)multiSelectView;

// default color
+ (UIColor *)normalTitleColor;
+ (UIColor *)selectedTitleColor;
+ (UIColor *)normalBackgroundColor;
+ (UIColor *)selectedBackgroundColor;

+ (UIFont *)defaultFont;

@end

// RGMTLabelCell
// display selected cell

@interface RGMTLabelCell : UICollectionViewCell

@property (nonatomic, assign) BOOL hideBorder;
@property (nonatomic, assign) BOOL hideBackgroundColor;

+ (NSString *)identifier;

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle;

- (void)setTitle:(NSString *)title withMultiSelectView:(RGMultiSelectTextView *)multiSelectTextView;

@end

// RGMTDeleteTextField
// RGMTDeleteTextFieldDelegate will be called when text is deleted or changed

@class RGMTDeleteTextField;

@protocol RGMTDeleteTextFieldDelegate <NSObject>

- (void)textDidChange:(RGMTDeleteTextField *)deleteTextField;
- (void)deleteBackward:(RGMTDeleteTextField *)deleteTextField;

@end

@interface RGMTDeleteTextField : UITextField

@property (nonatomic, assign) BOOL cursorHide;

@property (nonatomic, weak) id<RGMTDeleteTextFieldDelegate> deleteTextFieldDelegate;

- (void)configWithMultiSelectView:(RGMultiSelectTextView *)multiSelectTextView;

@end


// RGMTTextFiledCell
// RGMTTextFiledCell wapper RGMTDeleteTextField and is showed at last

@interface RGMTTextFiledCell : UICollectionViewCell;

+ (NSString *)identifier;

@property (nonatomic, strong) RGMTDeleteTextField *textFiled;

@end
