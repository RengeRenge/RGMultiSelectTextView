//
//  MultiSelectTextView.m
//  MultiSelectTextView
//
//  Created by LD on 2017/7/11.
//  Copyright © 2017年 ld. All rights reserved.
//

#import "RGMultiSelectTextView.h"
#import "RGMultiSelectViewUtils.h"
#import "RGMultiSelectCollectionViewLeftAlignedLayout.h"

@interface RGMultiSelectTextView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, RGMTDeleteTextFieldDelegate, UIGestureRecognizerDelegate, RGMultiSelectTextViewCollectionViewDelegateLeftAlignedLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) RGMTDeleteTextField *textField;
@property (nonatomic, assign) CGRect textFieldFrame;

@property (nonatomic, assign) NSInteger currentSelectedIndex;
@property (nonatomic, assign) BOOL isFirstLayout;

@end

@implementation RGMultiSelectTextView

@synthesize font = _font;

- (instancetype)init {
    if (self = [super init]) {
        [self __init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0) {
        frame.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    if (frame.size.height == 0) {
        frame.size.height = 44;
    }
    if (self == [super initWithFrame:frame]) {
        [self __init];
    }
    return self;
}

- (void)__init {
    if (!self.collectionView) {
        self.isFirstLayout = YES;
        self.currentSelectedIndex = -1;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[[RGMultiSelectCollectionViewLeftAlignedLayout alloc] init]];
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource  = self;
        [self.collectionView registerClass:[RGMTLabelCell class] forCellWithReuseIdentifier:[RGMTLabelCell identifier]];
        [self.collectionView registerClass:[RGMTTextFiledCell class] forCellWithReuseIdentifier:[RGMTTextFiledCell identifier]];
        
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        _bottomLine.backgroundColor = RGMTCommenUtils.normalBackgroundColor;
        
        [self addSubview:self.collectionView];
        [self addSubview:self.textField];
        [self addSubview:_bottomLine];
        self.clipsToBounds = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    CGRect rect = self.collectionView.frame;
    rect.size = frame.size;
    self.collectionView.frame = rect;
    _bottomLine.frame = CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if ([view isKindOfClass:[UICollectionView class]] || [view isKindOfClass:[RGMTDeleteTextField class]]) {
        [self beginEdit];
//        return self;
    }
    return [super hitTest:point withEvent:event];
}

- (RGMTDeleteTextField *)textField {
    if (!_textField) {
        _textField = [[RGMTDeleteTextField alloc] init];
        [_textField setCursorHide:NO];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.delegate = self;
        _textField.deleteTextFieldDelegate = self;
        [_textField configWithMultiSelectView:self];
    }
    return _textField;
}

- (void)setTitleNormalColor:(UIColor *)titleNormalColor {
    _titleNormalColor = titleNormalColor;
    [self.textField configWithMultiSelectView:self];
    [self.collectionView reloadData];
    _bottomLine.backgroundColor = titleNormalColor;
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor {
    _titleSelectedColor = titleSelectedColor;
    _bottomLine.backgroundColor = titleSelectedColor;
    [self.textField configWithMultiSelectView:self];
    [self.collectionView reloadData];
}

- (void)setTitleNormalBackgroudColor:(UIColor *)titleNormalBackgroudColor {
    _titleNormalBackgroudColor = titleNormalBackgroudColor;
    [self.textField configWithMultiSelectView:self];
    [self.collectionView reloadData];
}

- (void)setTitleSelectedBackgroudColor:(UIColor *)titleSelectedBackgroudColor {
    _titleSelectedBackgroudColor = titleSelectedBackgroudColor;
    [self.textField configWithMultiSelectView:self];
    [self.collectionView reloadData];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self.textField configWithMultiSelectView:self];
    self.placeHoderOnTextField = self.placeHoderOnTextField;
    [self.collectionView reloadData];
}

- (UIFont *)font {
    if (_font) {
        return _font;
    }
    return [RGMTCommenUtils defaultFont];
}

- (void)setPlaceHoder:(NSString *)placeHoder {
    _placeHoder = placeHoder;
    _attributePlaceHoder = nil;
    self.placeHoderOnTextField = self.placeHoderOnTextField;
}

- (void)setAttributePlaceHoder:(NSAttributedString *)attributePlaceHoder {
    _placeHoder = nil;
    _attributePlaceHoder = attributePlaceHoder;
    self.placeHoderOnTextField = self.placeHoderOnTextField;
}

- (void)setPlaceHoderOnTextField:(BOOL)placeHoderOnTextField {
    if (placeHoderOnTextField) {
        
        if (!_placeHoderOnTextField) {
            if (self.placeHoder) {
                RGMultiSelectedObject *object = [RGMultiSelectedObject objectwithTitle:_placeHoder identifier:@""];
                [self.titlesArray removeObject:object];
            }
            if (self.attributePlaceHoder) {
                RGMultiSelectedObject *object = [RGMultiSelectedObject objectwithAttributedTitle:_attributePlaceHoder identifier:@""];
                [self.titlesArray removeObject:object];
            }
        }
        
        if (self.titlesArray.count <= 0) {
            if (self.placeHoder) {
                
                self.textField.placeholder = self.placeHoder;
                
            } else if (self.attributePlaceHoder) {
                
                self.textField.attributedPlaceholder = _attributePlaceHoder;
                
            }
        } else {
            
            self.textField.placeholder = nil;
            self.textField.attributedPlaceholder = nil;
        }
        
    } else {
        if (self.placeHoder) {
            
            RGMultiSelectedObject *object = [RGMultiSelectedObject objectwithTitle:_placeHoder identifier:@""];
            [self.titlesArray removeObject:object];
            [self.titlesArray insertObject:object atIndex:0];
            
        } else if (self.attributePlaceHoder) {
            
            RGMultiSelectedObject *object = [RGMultiSelectedObject objectwithAttributedTitle:_attributePlaceHoder identifier:@""];
            [self.titlesArray removeObject:object];
            [self.titlesArray insertObject:object atIndex:0];
        }
    }
    _placeHoderOnTextField = placeHoderOnTextField;
}

- (NSMutableArray<RGMultiSelectedObject *> *)titlesArray {
    if (!_titlesArray) {
        _titlesArray = [NSMutableArray array];
    }
    return _titlesArray;
}

- (void)setCurrentSelectedIndex:(NSInteger)currentSelectedIndex {
    _currentSelectedIndex = currentSelectedIndex;
    if (_currentSelectedIndex == -1 || _currentSelectedIndex != self.titlesArray.count) {
        [self.textField setCursorHide:YES];
    } else {
        [self.textField setCursorHide:NO];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)resignFirstResponder {
    if ([self.textField isFirstResponder]) {
        return [self.textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isTextFieldCell:indexPath]) {
        CGSize size = [RGMTCommenUtils sizeWithString:self.textField.text fits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) multiSelectView:self];
        
        size.width += 16;
        if (size.width < self.minimumTitleWidth) {
            size.width = self.minimumTitleWidth;
        }
        
        if (size.width > collectionView.frame.size.width - self.edgeInsets.left) {
            size.width = collectionView.frame.size.width - self.edgeInsets.left;
        }
        
        size.height += 12;
        
        return size;
        
    } else {
        
        NSString *title = self.titlesArray[indexPath.row].title;
        NSAttributedString *attTitle = self.titlesArray[indexPath.row].attributedTitle;
        
        CGSize size = CGSizeZero;
        
        if (title) {
            
            size = [RGMTCommenUtils sizeWithString:title fits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) multiSelectView:self];
            
        } else if (attTitle){
            
            size = [RGMTCommenUtils sizeWithAttributeString:attTitle fits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        }
        
        size.width += 16;
        if (size.width < self.minimumTitleWidth) {
            size.width = self.minimumTitleWidth;
        }
        if (size.width > self.collectionView.frame.size.width - self.edgeInsets.right - self.edgeInsets.left) {
            size.width = self.collectionView.frame.size.width - self.edgeInsets.right - self.edgeInsets.left;
        }
        
        size.height += 12;
        
        return size;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return self.titleInterItmeSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.titleLineSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.edgeInsets;
}

#pragma mark - RGMultiSelectTextView CollectionViewDelegateLeftAlignedLayout

- (void)collectionView:(UICollectionView *)collection didLayoutFinished:(CGSize)contentSize {
    if (CGSizeEqualToSize(_contentSize, contentSize)) {
        return;
    }
    _contentSize = contentSize;
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextViewContentSizeWillChange:contentSize:)]) {
        [self performMultiSelectTextViewContentSizeWillChangeDelegate];
    }
    if (_isFirstLayout) {
        _isFirstLayout = NO;
        [self.collectionView reloadData];
    }
}

- (void)performMultiSelectTextViewContentSizeWillChangeDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextViewContentSizeWillChange:contentSize:)]) {
        CGSize contentSize = CGSizeMake(self.collectionView.frame.size.width, _contentSize.height + self.edgeInsets.bottom);
        [self.delegate multiSelectTextViewContentSizeWillChange:self contentSize:contentSize];
        [self setNeedsLayout];
    }
}

#pragma mark - CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titlesArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isTextFieldCell:indexPath]) {
        
        RGMTTextFiledCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RGMTTextFiledCell identifier] forIndexPath:indexPath];
        cell.textFiled.userInteractionEnabled = NO;
        [cell.textFiled configWithMultiSelectView:self];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    } else if ([self isPlaceHoderCell:indexPath]) {
        
        RGMTLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RGMTLabelCell identifier] forIndexPath:indexPath];
        if (self.placeHoder) {
            [cell setTitle:self.placeHoder withMultiSelectView:self];
        } else if (self.attributePlaceHoder) {
            cell.attributedTitle = self.attributePlaceHoder;
        }
        cell.hideBackgroundColor = YES;
        
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        
        return cell;
        
    } else {
        
        RGMTLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RGMTLabelCell identifier] forIndexPath:indexPath];
        
        NSString *title = self.titlesArray[indexPath.row].title;
        NSAttributedString *attTitle = self.titlesArray[indexPath.row].attributedTitle;
        
        if (title) {
            [cell setTitle:title withMultiSelectView:self];
        } else if (attTitle){
            cell.attributedTitle = attTitle;
        }
        
        if (self.currentSelectedIndex == indexPath.row) {
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        } else {
            [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        cell.hideBackgroundColor = NO;
        
        cell.selected = (self.currentSelectedIndex == indexPath.row);
        
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isPlaceHoderCell:indexPath]) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self showKeyBoardAtIndexPath:[NSIndexPath indexPathForItem:self.titlesArray.count inSection:0] collectionView:collectionView];
    } else {
        [self showKeyBoardAtIndexPath:indexPath collectionView:collectionView];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.titlesArray.count) {
        _textFieldFrame = [cell.superview convertRect:cell.frame toView:self];
        self.textField.frame = _textFieldFrame;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.titlesArray.count inSection:0]];
    if (cell) {
        _textFieldFrame = [cell.superview convertRect:cell.frame toView:self];
        self.textField.frame = _textFieldFrame;
    }
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self beginEdit];
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextViewDidBeginEditing:)]) {
        [self.delegate multiSelectTextViewDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    [self hideKeyBoard];
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextViewDidEndEditing:)]) {
        [self.delegate multiSelectTextViewDidEndEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyBoard];
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextViewDidReturn:)]) {
        [self.delegate multiSelectTextViewDidReturn:self];
    }
    return YES;
}

- (void)textDidChange:(RGMTDeleteTextField *)deleteTextField {
    _text = deleteTextField.text;
    [self textDidChange:deleteTextField changeSelectedTitle:YES];
}

- (void)textDidChange:(RGMTDeleteTextField *)deleteTextField changeSelectedTitle:(BOOL)changeSelectedTitle {
    if (changeSelectedTitle) {
        self.currentSelectedIndex = self.titlesArray.count;
        [self reloadTextViewPositionWithScroll:YES animated:NO];
    } else {
        [self reloadTextViewPositionWithScroll:NO animated:NO];
    }
    [self scrollViewDidScroll:self.collectionView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextViewTextDidChange:)]) {
        [self.delegate multiSelectTextViewTextDidChange:self];
    }
}

- (void)deleteBackward:(RGMTDeleteTextField *)deleteTextField {
    
    if (!deleteTextField.text.length) {
        
        NSInteger deleteItem = self.currentSelectedIndex;
        
        if (deleteItem == self.titlesArray.count) {
            
            if (deleteItem - 1 < 0 || [self isPlaceHoderCell:[NSIndexPath indexPathForItem:deleteItem - 1 inSection:0]]) {
                return;
            }
            
            self.currentSelectedIndex = deleteItem - 1;
            
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentSelectedIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            return;
            
        }
        if (deleteItem >= 0 && deleteItem < self.titlesArray.count) {
            
            NSIndexPath *deletePath = [NSIndexPath indexPathForItem:deleteItem inSection:0];
            
            [self deleteTitlesAtIndexPaths:@[deletePath] performDelegate:YES];
            
        }
    }
}

#pragma mark - Update UI Method

- (void)deleteTitlesAtIndexPaths:(NSArray <NSIndexPath *> *)indexPath performDelegate:(BOOL)performDelegate {
    
    NSMutableArray <RGMultiSelectedObject *> *deleteObjects = [NSMutableArray array];
    
    [indexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [deleteObjects addObject:self.titlesArray[obj.item]];
    }];
    
    
    BOOL shouldDelete = YES;
    if (performDelegate && self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextView:shouldRemoveObejct:)]) {
        shouldDelete = [self.delegate multiSelectTextView:self shouldRemoveObejct:deleteObjects];
    }
    if (shouldDelete) {
        
        [self.titlesArray removeObjectsInArray:deleteObjects];
        
        NSInteger currentSelectedIndex = self.currentSelectedIndex;
        
        [self collectionViewUpdate:^{
            
            [self.collectionView deleteItemsAtIndexPaths:indexPath];
            
        } completion:^{
            if (currentSelectedIndex == self.currentSelectedIndex) {
                self.currentSelectedIndex = self.titlesArray.count;
            }
        }];
        
        if (performDelegate && self.delegate && [self.delegate respondsToSelector:@selector(multiSelectTextView:didRemoveObejct:)]) {
            [self.delegate multiSelectTextView:self didRemoveObejct:deleteObjects];
        }
    }
    self.placeHoderOnTextField = self.placeHoderOnTextField;
}

- (BOOL)isTextFieldCell:(NSIndexPath *)indexPath {
    return (self.titlesArray.count == indexPath.item);
}

- (BOOL)isPlaceHoderCell:(NSIndexPath *)indexPath {
    return !self.placeHoderOnTextField && (self.placeHoder || self.attributePlaceHoder) &&  indexPath.item == 0;
}

- (void)reloadTextViewPositionWithScroll:(BOOL)scroll animated:(BOOL)animated {
    NSInteger item = self.titlesArray.count;
    
    NSArray *indexPaths = nil;
    
    if (item > 0) {
        indexPaths = @[[NSIndexPath indexPathForItem:item inSection:0], [NSIndexPath indexPathForItem:item - 1 inSection:0]];
    } else {
        indexPaths = @[[NSIndexPath indexPathForItem:item inSection:0]];
    }
    
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    if (scroll) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.titlesArray.count inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}

- (void)beginEdit {
    [self showKeyBoardAtTtem:self.titlesArray.count collectionView:self.collectionView];
}

- (void)showKeyBoardAtTtem:(NSInteger)item collectionView:(UICollectionView *)collectionView {
    [self showKeyBoardAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] collectionView:collectionView];
}

- (void)showKeyBoardAtIndexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView {
    
    [self.textField becomeFirstResponder];
    
    [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentSelectedIndex inSection:0] animated:YES];
    
    if (self.currentSelectedIndex == -1) {
        
        self.currentSelectedIndex = indexPath.item;
        
    } else {
        
        if (self.currentSelectedIndex != indexPath.item) {
            
            [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            
            self.currentSelectedIndex = indexPath.row;
            
        } else {
            
            self.currentSelectedIndex = self.titlesArray.count;
        }
    }
    
    if (self.currentSelectedIndex != self.titlesArray.count) {
        if (self.textField.text.length) {
            self.textField.text = @"";
            _text = @"";
            [self textDidChange:self.textField changeSelectedTitle:NO];
        }
    }
}

- (void)hideKeyBoard {
    [self.textField endEditing:YES];
    if (self.currentSelectedIndex != -1) {
        [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentSelectedIndex inSection:0] animated:YES];
    }
    self.currentSelectedIndex = -1;
}

- (void)collectionViewUpdate:(void(^)(void))update completion:(void(^)(void))completion {
    if (_isFirstLayout) { // ignore update if collectionView is not layouted
        if (completion) {
            completion();
        }
        return;
    }
    self.textField.alpha = 0.0f;
    
    [self.collectionView performBatchUpdates:^{
        
        if (update) {
            update();
        }
        
    } completion:^(BOOL finished) {
        
        if (completion) {
            completion();
        }
        [self reloadTextViewPositionWithScroll:YES animated:YES];
        
        self.textField.alpha = 1.0;
    }];
}

#pragma mark - Public

- (void)setText:(NSString *)text {
    void(^setTextBlock)(void) = ^{
        if (![self.textField.text isEqualToString:text]) {
            self.textField.text = text;
            [self textDidChange:self.textField];
        }
    };
    
    if ([NSThread isMainThread]) {
        setTextBlock();
    } else {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            setTextBlock();
        });
    }
}

- (void)reload {
    void(^reloadBlock)(void) = ^{
        [self.collectionView reloadData];
        self.placeHoderOnTextField = self.placeHoderOnTextField;
    };
    
    if ([NSThread isMainThread]) {
        reloadBlock();
    } else {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            reloadBlock();
        });
    }
}

- (void)setTitles:(NSArray<RGMultiSelectedObject *> *)titles {
    void(^setTitlesBlock)(void) = ^{
        NSMutableArray *titlesArray = [titles mutableCopy];
        if (!self.placeHoderOnTextField && (self.placeHoder || self.attributePlaceHoder)) {
            [titlesArray insertObject:self.titlesArray.firstObject atIndex:0];
        }
        _titlesArray = titlesArray;
        [self.collectionView reloadData];
        self.placeHoderOnTextField = self.placeHoderOnTextField;
    };
    
    if ([NSThread isMainThread]) {
        setTitlesBlock();
    } else {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            setTitlesBlock();
        });
    }
}

- (void)insertTitles:(NSArray<RGMultiSelectedObject *> *)titles {
    void(^insertTitlesBlock)(void) = ^{
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSMutableArray *filterTitles = [NSMutableArray array];
        
        [titles enumerateObjectsUsingBlock:^(RGMultiSelectedObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (![self.titlesArray containsObject:obj]) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:idx + self.titlesArray.count inSection:0]];
                [filterTitles addObject:obj];
            }
        }];
        if (filterTitles.count) {
            
            [self.titlesArray addObjectsFromArray:filterTitles];
            
            [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentSelectedIndex inSection:0] animated:YES];
            self.currentSelectedIndex = self.titlesArray.count;
            
            [self collectionViewUpdate:^{
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            } completion:^{
                
            }];
            self.placeHoderOnTextField = self.placeHoderOnTextField;
        }
    };
    
    if ([NSThread isMainThread]) {
        insertTitlesBlock();
    } else {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            insertTitlesBlock();
        });
    }
}

- (void)deleteTitles:(NSArray<RGMultiSelectedObject *> *)titles {
    void(^deleteTitlesBlock)(void) = ^{
        NSMutableArray *deleteIndexPaths = [NSMutableArray array];
        [titles enumerateObjectsUsingBlock:^(RGMultiSelectedObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger index = [self.titlesArray indexOfObject:obj];
            if (index != NSNotFound) {
                [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            }
        }];
        if (deleteIndexPaths.count) {
            [self deleteTitlesAtIndexPaths:deleteIndexPaths performDelegate:NO];
        }
    };
    
    if ([NSThread isMainThread]) {
        deleteTitlesBlock();
    } else {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            deleteTitlesBlock();
        });
    }
}

- (void)updateTitles:(NSArray<RGMultiSelectedObject *> *)titles {
    void(^updateTitlesBlock)(void) = ^{
        
        if (!titles.count) {
            return;
        }
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        
        [titles enumerateObjectsUsingBlock:^(RGMultiSelectedObject * _Nonnull updateTitle, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.titlesArray enumerateObjectsUsingBlock:^(RGMultiSelectedObject * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([title.identifier isEqualToString:updateTitle.identifier]) {
                    [self.titlesArray replaceObjectAtIndex:idx withObject:updateTitle];
                    [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                }
            }];
        }];
        
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        [self scrollViewDidScroll:self.collectionView];
    };
    
    if ([NSThread isMainThread]) {
        updateTitlesBlock();
    } else {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            updateTitlesBlock();
        });
    }
}

- (CGSize)maxSize {
    CGRect frame = self.collectionView.frame;
    CGSize contentSize = CGSizeMake(frame.size.width, _contentSize.height + self.edgeInsets.bottom);
    return contentSize;
}

@end

@implementation RGMultiSelectedObject

+ (instancetype)objectwithTitle:(NSString *)title identifier:(NSString *)identifier {
    RGMultiSelectedObject *object = [[RGMultiSelectedObject alloc] init];
    object.title = title;
    object.identifier = identifier;
    return object;
}

+ (instancetype)objectwithAttributedTitle:(NSAttributedString *)title identifier:(NSString *)identifier {
    RGMultiSelectedObject *object = [[RGMultiSelectedObject alloc] init];
    object.attributedTitle = title;
    object.identifier = identifier;
    return object;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _attributedTitle = nil;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _title = nil;
    _attributedTitle = attributedTitle;
}

#pragma mark - overwrite

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        return YES;
    } else {
        if ([object isKindOfClass:[RGMultiSelectedObject class]]) {
            if (_identifier || [object identifier]) {
                return [[object identifier] isEqualToString:_identifier];
            }
        }
    }
    return NO;
}

@end

