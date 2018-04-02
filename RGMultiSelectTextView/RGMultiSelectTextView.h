//
//  MultiSelectTextView.h
//  MultiSelectTextView
//
//  Created by LD on 2017/7/11.
//  Copyright © 2017年 ld. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RGMultiSelectTextView;
@class RGMultiSelectedObject;
@protocol RGMultiSelectTextViewDelegate;

@interface RGMultiSelectTextView : UIView

@property (nonatomic, weak) id<RGMultiSelectTextViewDelegate> delegate;

@property (nonatomic, strong) UIColor *titleNormalColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;

@property (nonatomic, strong) UIColor *titleNormalBackgroudColor;
@property (nonatomic, strong) UIColor *titleSelectedBackgroudColor;

@property (nonatomic, assign) BOOL placeHoderOnTextField;

@property (nonatomic, copy) NSString *placeHoder;
@property (nonatomic, copy) NSAttributedString *attributePlaceHoder;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, assign) CGFloat minimumTitleWidth;
@property (nonatomic, assign) CGFloat titleLineSpacing;
@property (nonatomic, assign) CGFloat titleInterItmeSpacing;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@property (nonatomic, assign, readonly) CGSize contentSize;

@property (nonatomic, strong) NSMutableArray<RGMultiSelectedObject *> *titlesArray;

- (void)reload;

- (void)setTitles:(NSArray <RGMultiSelectedObject *> *)titles;

- (void)insertTitles:(NSArray <RGMultiSelectedObject *> *)titles;

- (void)deleteTitles:(NSArray <RGMultiSelectedObject *> *)titles;

- (void)updateTitles:(NSArray <RGMultiSelectedObject *> *)titles;

- (CGSize)maxSize;

@end

@protocol RGMultiSelectTextViewDelegate <NSObject>

@optional

- (void)multiSelectTextViewDidBeginEditing:(RGMultiSelectTextView *)multiSelectTextView;

- (void)multiSelectTextViewTextDidChange:(RGMultiSelectTextView *)multiSelectTextView;

- (void)multiSelectTextViewDidReturn:(RGMultiSelectTextView *)multiSelectTextView;

- (void)multiSelectTextViewDidEndEditing:(RGMultiSelectTextView *)multiSelectTextView;

- (BOOL)multiSelectTextView:(RGMultiSelectTextView *)multiSelectTextView shouldRemoveObejct:(NSArray <RGMultiSelectedObject *> *)object;
- (void)multiSelectTextView:(RGMultiSelectTextView *)multiSelectTextView didRemoveObejct:(NSArray <RGMultiSelectedObject *> *)object;

- (void)multiSelectTextViewContentSizeWillChange:(RGMultiSelectTextView *)multiSelectTextView contentSize:(CGSize)contentSize;
@end


@interface RGMultiSelectedObject : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSAttributedString *attributedTitle;
@property (nonatomic, strong) NSString *identifier;

+ (instancetype)objectwithTitle:(NSString *)title identifier:(NSString *)identifier;
+ (instancetype)objectwithAttributedTitle:(NSAttributedString *)title identifier:(NSString *)identifier;

@end
