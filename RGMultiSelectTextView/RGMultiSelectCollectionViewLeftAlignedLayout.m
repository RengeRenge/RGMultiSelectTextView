
// Copyright (c) 2014 Giovanni Lodi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RGMultiSelectCollectionViewLeftAlignedLayout.h"

@interface UICollectionViewLayoutAttributes (LeftAligned)

- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset;

@end

@implementation UICollectionViewLayoutAttributes (LeftAligned)

- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset
{
    CGRect frame = self.frame;
    frame.origin.x = sectionInset.left;
    self.frame = frame;
}

@end

#pragma mark -

@implementation RGMultiSelectCollectionViewLeftAlignedLayout

#pragma mark - UICollectionViewLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *originalAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *updatedAttributes = [NSMutableArray arrayWithArray:originalAttributes];
    CGFloat contentHeight = 0.f;
    for (UICollectionViewLayoutAttributes *attributes in originalAttributes) {
        if (!attributes.representedElementKind) {
            NSUInteger index = [updatedAttributes indexOfObject:attributes];
            UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:attributes.indexPath];
            
            contentHeight = MAX(contentHeight, CGRectGetMaxY(layoutAttributes.frame));
            
            updatedAttributes[index] = layoutAttributes;
        }
    }
    
    if (originalAttributes.count) {
        id<RGMultiSelectTextViewCollectionViewDelegateLeftAlignedLayout> delegate = (id<RGMultiSelectTextViewCollectionViewDelegateLeftAlignedLayout>)self.collectionView.delegate;
        
        [delegate collectionView:self.collectionView didLayoutFinished:CGSizeMake(self.collectionView.frame.size.width, contentHeight)];
    }
    
    return updatedAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* currentItemAttributes = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    UIEdgeInsets sectionInset = [self evaluatedSectionInsetForItemAtIndex:indexPath.section];

    BOOL isFirstItemInSection = indexPath.item == 0;
    CGFloat layoutWidth = CGRectGetWidth(self.collectionView.frame) - sectionInset.left - sectionInset.right;

    if (isFirstItemInSection) {
        [currentItemAttributes leftAlignFrameWithSectionInset:sectionInset];
        
        // modify by LD : 每组的最后一个 Cell 占据剩下的全部宽度
        BOOL isLastItemInSection = [self.collectionView numberOfItemsInSection:indexPath.section] - 1 == currentItemAttributes.indexPath.row;
        if (isLastItemInSection) {
            currentItemAttributes = [self __configLastLayoutAttributes:currentItemAttributes];
        }
        return currentItemAttributes;
    }

    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item-1 inSection:indexPath.section];
    CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
    CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width;
    CGRect currentFrame = currentItemAttributes.frame;
    CGRect strecthedCurrentFrame = CGRectMake(sectionInset.left,
                                              currentFrame.origin.y,
                                              layoutWidth,
                                              currentFrame.size.height);
    // if the current frame, once left aligned to the left and stretched to the full collection view
    // widht intersects the previous frame then they are on the same line
    BOOL isFirstItemInRow = !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame);

    if (isFirstItemInRow) {
        // make sure the first item on a line is left aligned
        [currentItemAttributes leftAlignFrameWithSectionInset:sectionInset];
        
        // modify by LD : 每组的最后一个 Cell 占据剩下的全部宽度
        BOOL isLastItemInSection = [self.collectionView numberOfItemsInSection:indexPath.section] - 1 == currentItemAttributes.indexPath.row;
        if (isLastItemInSection) {
            currentItemAttributes = [self __configLastLayoutAttributes:currentItemAttributes];
        }
        return currentItemAttributes;
    }

    CGRect frame = currentItemAttributes.frame;
    frame.origin.x = previousFrameRightPoint + [self evaluatedMinimumInteritemSpacingForSectionAtIndex:indexPath.section];
    currentItemAttributes.frame = frame;
    
    // modify by LD : 每组的最后一个 Cell 占据剩下的全部宽度
    BOOL isLastItemInSection = [self.collectionView numberOfItemsInSection:indexPath.section] - 1 == currentItemAttributes.indexPath.row;
    if (isLastItemInSection) {
        currentItemAttributes = [self __configLastLayoutAttributes:currentItemAttributes];
    }
    
    return currentItemAttributes;
}

- (UICollectionViewLayoutAttributes *)__configLastLayoutAttributes:(UICollectionViewLayoutAttributes *)currentItemAttributes {
    
    CGRect frame = currentItemAttributes.frame;
    frame.size.width = self.collectionView.frame.size.width - currentItemAttributes.frame.origin.x;
    currentItemAttributes.frame = frame;
    
    return currentItemAttributes;
}

- (CGFloat)evaluatedMinimumInteritemSpacingForSectionAtIndex:(NSInteger)sectionIndex
{
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        id<RGMultiSelectTextViewCollectionViewDelegateLeftAlignedLayout> delegate = (id<RGMultiSelectTextViewCollectionViewDelegateLeftAlignedLayout>)self.collectionView.delegate;

        return [delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:sectionIndex];
    } else {
        return self.minimumInteritemSpacing;
    }
}

- (UIEdgeInsets)evaluatedSectionInsetForItemAtIndex:(NSInteger)index
{
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        id<RGMultiSelectTextViewCollectionViewDelegateLeftAlignedLayout> delegate = (id<RGMultiSelectTextViewCollectionViewDelegateLeftAlignedLayout>)self.collectionView.delegate;

        return [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
    } else {
        return self.sectionInset;
    }
}

@end
