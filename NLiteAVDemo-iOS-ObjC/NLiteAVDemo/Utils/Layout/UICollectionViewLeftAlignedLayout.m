// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UICollectionViewLeftAlignedLayout.h"

@interface UICollectionViewLayoutAttributes (LeftAligned)

- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset;

@end

@implementation UICollectionViewLayoutAttributes (LeftAligned)

- (void)leftAlignFrameWithSectionInset:(UIEdgeInsets)sectionInset {
  CGRect frame = self.frame;
  frame.origin.x = sectionInset.left;
  self.frame = frame;
}

@end

#pragma mark -

@implementation UICollectionViewLeftAlignedLayout

#pragma mark - UICollectionViewLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSArray *originalAttributes = [super layoutAttributesForElementsInRect:rect];
  NSMutableArray *updatedAttributes = [NSMutableArray arrayWithArray:originalAttributes];
  for (UICollectionViewLayoutAttributes *attributes in originalAttributes) {
    if (!attributes.representedElementKind) {
      NSUInteger index = [updatedAttributes indexOfObject:attributes];
      updatedAttributes[index] = [self layoutAttributesForItemAtIndexPath:attributes.indexPath];
    }
  }
  return updatedAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *currentItemAttributes =
      [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
  UIEdgeInsets sectionInset = [self evaluatedSectionInsetForItemAtIndex:indexPath.section];

  BOOL isFirstItemInSection = indexPath.item == 0;
  CGFloat layoutWidth =
      CGRectGetWidth(self.collectionView.frame) - sectionInset.left - sectionInset.right;

  if (isFirstItemInSection) {
    [currentItemAttributes leftAlignFrameWithSectionInset:sectionInset];
    return currentItemAttributes;
  }

  NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:indexPath.item - 1
                                                       inSection:indexPath.section];
  CGRect previousFrame = [self layoutAttributesForItemAtIndexPath:previousIndexPath].frame;
  CGFloat previousFrameRightPoint = previousFrame.origin.x + previousFrame.size.width;
  CGRect currentFrame = currentItemAttributes.frame;
  CGRect strecthedCurrentFrame =
      CGRectMake(sectionInset.left, currentFrame.origin.y, layoutWidth, currentFrame.size.height);
  // if the current frame, once left aligned to the left and stretched to the full collection view
  // width intersects the previous frame then they are on the same line
  BOOL isFirstItemInRow = !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame);

  if (isFirstItemInRow) {
    // make sure the first item on a line is left aligned
    [currentItemAttributes leftAlignFrameWithSectionInset:sectionInset];
    return currentItemAttributes;
  }

  CGRect frame = currentItemAttributes.frame;
  frame.origin.x = previousFrameRightPoint +
                   [self evaluatedMinimumInteritemSpacingForSectionAtIndex:indexPath.section];
  currentItemAttributes.frame = frame;
  return currentItemAttributes;
}

- (CGFloat)evaluatedMinimumInteritemSpacingForSectionAtIndex:(NSInteger)sectionIndex {
  if ([self.collectionView.delegate
          respondsToSelector:@selector(collectionView:
                                               layout:minimumInteritemSpacingForSectionAtIndex:)]) {
    id<UICollectionViewDelegateLeftAlignedLayout> delegate =
        (id<UICollectionViewDelegateLeftAlignedLayout>)self.collectionView.delegate;

    return [delegate collectionView:self.collectionView
                                          layout:self
        minimumInteritemSpacingForSectionAtIndex:sectionIndex];
  } else {
    return self.minimumInteritemSpacing;
  }
}

- (UIEdgeInsets)evaluatedSectionInsetForItemAtIndex:(NSInteger)index {
  if ([self.collectionView.delegate
          respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
    id<UICollectionViewDelegateLeftAlignedLayout> delegate =
        (id<UICollectionViewDelegateLeftAlignedLayout>)self.collectionView.delegate;
    return [delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:index];
  } else {
    return self.sectionInset;
  }
}

@end
