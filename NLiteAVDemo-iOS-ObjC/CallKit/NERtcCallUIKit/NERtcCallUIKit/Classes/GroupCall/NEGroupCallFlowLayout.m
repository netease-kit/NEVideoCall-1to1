// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupCallFlowLayout.h"
#import <YXAlog_iOS/YXAlog.h>

@implementation NEGroupCallFlowLayout {
  NSMutableArray<NSIndexPath *> *_deletingIndexPaths;
  NSMutableArray<NSIndexPath *> *_insertingIndexPaths;
  CGRect _contentBounds;
  NSMutableArray<UICollectionViewLayoutAttributes *> *_cachedAttributes;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.participantCount = 1;
    self.largeViewIndex = -1;
    self.showLargeViewUserId = @"";
    _deletingIndexPaths = [NSMutableArray array];
    _insertingIndexPaths = [NSMutableArray array];
    _contentBounds = CGRectZero;
    _cachedAttributes = [NSMutableArray array];
  }
  return self;
}

#pragma mark - Layout Calculation (完全仿造 Swift 版本)

- (void)prepareLayout {
  [super prepareLayout];

  if (!self.collectionView) return;

  YXAlogInfo(
      @"[GroupCallLayout] 🔄 prepareLayout 开始 - largeViewIndex: %ld, showLargeViewUserId: %@",
      (long)self.largeViewIndex, self.showLargeViewUserId);

  [_cachedAttributes removeAllObjects];
  _contentBounds = CGRectMake(0, 0, self.collectionView.bounds.size.width,
                              self.collectionView.bounds.size.height);

  NSInteger count = [self.collectionView numberOfItemsInSection:0];
  NSInteger currentIndex = 0;
  NEGroupCallLayoutMode segment = [self getSegmentForCount:count currentIndex:currentIndex];
  CGFloat cvWidth = self.collectionView.bounds.size.width;
  CGRect lastFrame =
      (count != 2 || self.largeViewIndex >= 0) ? CGRectZero : CGRectMake(0, cvWidth / 5, 0, 0);

  YXAlogInfo(@"[GroupCallLayout] 📊 布局参数 - count: %ld, cvWidth: %.2f, lastFrame: %@",
             (long)count, cvWidth, NSStringFromCGRect(lastFrame));

  while (currentIndex < count) {
    NSMutableArray<NSValue *> *segmentRects = [NSMutableArray array];

    YXAlogInfo(@"[GroupCallLayout] 🔍 处理 currentIndex: %ld, segment: %ld, largeViewIndex: %ld",
               (long)currentIndex, (long)segment, (long)self.largeViewIndex);

    switch (segment) {
      case NEGroupCallLayoutModeFullWidth: {
        CGRect rect =
            CGRectMake(0, lastFrame.origin.y + lastFrame.size.height + 1.0, cvWidth, cvWidth);
        [segmentRects addObject:[NSValue valueWithCGRect:rect]];
        YXAlogInfo(@"[GroupCallLayout] 📐 FullWidth - currentIndex: %ld, rect: %@",
                   (long)currentIndex, NSStringFromCGRect(rect));
        break;
      }

      case NEGroupCallLayoutModeFiftyFifty: {
        CGRect segmentFrame =
            CGRectMake(0, lastFrame.origin.y + lastFrame.size.height + 1.0, cvWidth, cvWidth / 2);
        // 仿造 dividedIntegral(fraction: 0.5, from: .minXEdge)
        CGRect leftRect = CGRectMake(segmentFrame.origin.x, segmentFrame.origin.y,
                                     segmentFrame.size.width / 2, segmentFrame.size.height);
        CGRect rightRect =
            CGRectMake(segmentFrame.origin.x + segmentFrame.size.width / 2, segmentFrame.origin.y,
                       segmentFrame.size.width / 2, segmentFrame.size.height);
        [segmentRects addObject:[NSValue valueWithCGRect:leftRect]];
        [segmentRects addObject:[NSValue valueWithCGRect:rightRect]];
        YXAlogInfo(
            @"[GroupCallLayout] 📐 FiftyFifty - currentIndex: %ld, leftRect: %@, rightRect: %@",
            (long)currentIndex, NSStringFromCGRect(leftRect), NSStringFromCGRect(rightRect));
        break;
      }

      case NEGroupCallLayoutModeOneThird: {
        CGRect rect = CGRectMake(cvWidth / 4.0, lastFrame.origin.y + lastFrame.size.height + 1.0,
                                 cvWidth / 2.0, cvWidth / 2.0);
        [segmentRects addObject:[NSValue valueWithCGRect:rect]];
        break;
      }

      case NEGroupCallLayoutModeThreeOneThirds: {
        CGRect segmentFrame =
            CGRectMake(0, lastFrame.origin.y + lastFrame.size.height + 1.0, cvWidth, cvWidth / 3);
        // 仿造 dividedIntegral(fraction: 1.0 / 3, from: .minXEdge)
        CGRect firstRect = CGRectMake(segmentFrame.origin.x, segmentFrame.origin.y,
                                      segmentFrame.size.width / 3, segmentFrame.size.height);
        CGRect remainingFrame =
            CGRectMake(segmentFrame.origin.x + segmentFrame.size.width / 3, segmentFrame.origin.y,
                       segmentFrame.size.width * 2 / 3, segmentFrame.size.height);
        // 仿造 dividedIntegral(fraction: 0.5, from: .minXEdge)
        CGRect secondRect = CGRectMake(remainingFrame.origin.x, remainingFrame.origin.y,
                                       remainingFrame.size.width / 2, remainingFrame.size.height);
        CGRect thirdRect = CGRectMake(remainingFrame.origin.x + remainingFrame.size.width / 2,
                                      remainingFrame.origin.y, remainingFrame.size.width / 2,
                                      remainingFrame.size.height);
        [segmentRects addObject:[NSValue valueWithCGRect:firstRect]];
        [segmentRects addObject:[NSValue valueWithCGRect:secondRect]];
        [segmentRects addObject:[NSValue valueWithCGRect:thirdRect]];
        break;
      }

      case NEGroupCallLayoutModeTwoThirdsOneThirdRight: {
        CGRect segmentFrame = CGRectMake(0, lastFrame.origin.y + lastFrame.size.height + 1.0,
                                         cvWidth, cvWidth * 2 / 3);
        // 仿造 dividedIntegral(fraction: (1.0 / 3), from: .minXEdge)
        CGRect leftFrame = CGRectMake(segmentFrame.origin.x, segmentFrame.origin.y,
                                      segmentFrame.size.width / 3, segmentFrame.size.height);
        CGRect rightFrame =
            CGRectMake(segmentFrame.origin.x + segmentFrame.size.width / 3, segmentFrame.origin.y,
                       segmentFrame.size.width * 2 / 3, segmentFrame.size.height);
        // 仿造 dividedIntegral(fraction: 0.5, from: .minYEdge)
        CGRect topLeftRect = CGRectMake(leftFrame.origin.x, leftFrame.origin.y,
                                        leftFrame.size.width, leftFrame.size.height / 2);
        CGRect bottomLeftRect =
            CGRectMake(leftFrame.origin.x, leftFrame.origin.y + leftFrame.size.height / 2,
                       leftFrame.size.width, leftFrame.size.height / 2);
        [segmentRects addObject:[NSValue valueWithCGRect:topLeftRect]];
        [segmentRects addObject:[NSValue valueWithCGRect:bottomLeftRect]];
        [segmentRects addObject:[NSValue valueWithCGRect:rightFrame]];
        break;
      }

      case NEGroupCallLayoutModeTwoThirdsOneThirdCenter: {
        CGRect segmentFrame = CGRectMake(0, lastFrame.origin.y + lastFrame.size.height + 1.0,
                                         cvWidth, cvWidth * 2 / 3);
        // 仿造 dividedIntegral(fraction: (1.0 / 3), from: .minXEdge)
        CGRect leftFrame = CGRectMake(segmentFrame.origin.x, segmentFrame.origin.y,
                                      segmentFrame.size.width / 3, segmentFrame.size.height);
        CGRect rightFrame =
            CGRectMake(segmentFrame.origin.x + segmentFrame.size.width / 3, segmentFrame.origin.y,
                       segmentFrame.size.width * 2 / 3, segmentFrame.size.height);
        // 仿造 dividedIntegral(fraction: 0.5, from: .minYEdge)
        CGRect topLeftRect = CGRectMake(leftFrame.origin.x, leftFrame.origin.y,
                                        leftFrame.size.width, leftFrame.size.height / 2);
        CGRect bottomLeftRect =
            CGRectMake(leftFrame.origin.x, leftFrame.origin.y + leftFrame.size.height / 2,
                       leftFrame.size.width, leftFrame.size.height / 2);
        [segmentRects addObject:[NSValue valueWithCGRect:topLeftRect]];
        [segmentRects addObject:[NSValue valueWithCGRect:rightFrame]];
        [segmentRects addObject:[NSValue valueWithCGRect:bottomLeftRect]];
        break;
      }

      case NEGroupCallLayoutModeOneThirdTwoThirds: {
        CGRect segmentFrame = CGRectMake(0, lastFrame.origin.y + lastFrame.size.height + 1.0,
                                         cvWidth, cvWidth * 2 / 3);
        // 仿造 dividedIntegral(fraction: (2.0 / 3), from: .minXEdge)
        CGRect leftFrame = CGRectMake(segmentFrame.origin.x, segmentFrame.origin.y,
                                      segmentFrame.size.width * 2 / 3, segmentFrame.size.height);
        CGRect rightFrame = CGRectMake(segmentFrame.origin.x + segmentFrame.size.width * 2 / 3,
                                       segmentFrame.origin.y, segmentFrame.size.width / 3,
                                       segmentFrame.size.height);
        // 仿造 dividedIntegral(fraction: 0.5, from: .minYEdge)
        CGRect topRightRect = CGRectMake(rightFrame.origin.x, rightFrame.origin.y,
                                         rightFrame.size.width, rightFrame.size.height / 2);
        CGRect bottomRightRect =
            CGRectMake(rightFrame.origin.x, rightFrame.origin.y + rightFrame.size.height / 2,
                       rightFrame.size.width, rightFrame.size.height / 2);
        [segmentRects addObject:[NSValue valueWithCGRect:leftFrame]];
        [segmentRects addObject:[NSValue valueWithCGRect:topRightRect]];
        [segmentRects addObject:[NSValue valueWithCGRect:bottomRightRect]];
        break;
      }
    }

    // Create and cache layout attributes for calculated frames.
    for (NSValue *rectValue in segmentRects) {
      UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes
          layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:currentIndex
                                                                   inSection:0]];
      attributes.frame = [rectValue CGRectValue];

      BOOL isLargeView = (currentIndex == self.largeViewIndex);
      YXAlogInfo(@"[GroupCallLayout] 📍 创建布局属性 - index: %ld, frame: %@, 是否为大画面: %@",
                 (long)currentIndex, NSStringFromCGRect(attributes.frame),
                 isLargeView ? @"是" : @"否");

      [_cachedAttributes addObject:attributes];
      _contentBounds = CGRectUnion(_contentBounds, lastFrame);

      currentIndex++;
      lastFrame = [rectValue CGRectValue];
    }

    segment = [self getSegmentForCount:count currentIndex:currentIndex];
  }

  YXAlogInfo(@"[GroupCallLayout] ✅ prepareLayout 完成 - 缓存了 %ld 个布局属性",
             (long)_cachedAttributes.count);
}

- (CGSize)collectionViewContentSize {
  CGSize contentSize = _contentBounds.size;
  CGSize boundsSize = self.collectionView.bounds.size;

  YXAlogInfo(
      @"[GroupCallLayout] 📏 collectionViewContentSize - bounds: %@, contentBounds: %@, final: %@",
      NSStringFromCGSize(boundsSize), NSStringFromCGSize(_contentBounds.size),
      NSStringFromCGSize(contentSize));

  return contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  if (!self.collectionView) return NO;
  return !CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.item < _cachedAttributes.count) {
    return _cachedAttributes[indexPath.item];
  }
  return nil;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *attributesArray = [NSMutableArray array];

  // Find any cell that sits within the query rect.
  if (_cachedAttributes.count == 0) return attributesArray;

  NSInteger lastIndex = _cachedAttributes.count - 1;
  NSInteger firstMatchIndex = [self binSearchRect:rect start:0 end:lastIndex];
  if (firstMatchIndex == NSNotFound) return attributesArray;

  // Starting from the match, loop up and down through the array until all the attributes
  // have been added within the query rect.
  for (NSInteger i = firstMatchIndex - 1; i >= 0; i--) {
    UICollectionViewLayoutAttributes *attributes = _cachedAttributes[i];
    if (attributes.frame.origin.y + attributes.frame.size.height < rect.origin.y) break;
    [attributesArray addObject:attributes];
  }

  for (NSInteger i = firstMatchIndex; i < _cachedAttributes.count; i++) {
    UICollectionViewLayoutAttributes *attributes = _cachedAttributes[i];
    if (attributes.frame.origin.y > rect.origin.y + rect.size.height) break;
    [attributesArray addObject:attributes];
  }

  return attributesArray;
}

// Perform a binary search on the cached attributes array.
- (NSInteger)binSearchRect:(CGRect)rect start:(NSInteger)start end:(NSInteger)end {
  if (end < start) return NSNotFound;

  NSInteger mid = (start + end) / 2;
  UICollectionViewLayoutAttributes *attributes = _cachedAttributes[mid];

  if (CGRectIntersectsRect(attributes.frame, rect)) {
    return mid;
  } else {
    if (attributes.frame.origin.y + attributes.frame.size.height < rect.origin.y) {
      return [self binSearchRect:rect start:(mid + 1) end:end];
    } else {
      return [self binSearchRect:rect start:start end:(mid - 1)];
    }
  }
}

#pragma mark - Layout Mode Selection (完全仿造 Swift 版本)

- (NEGroupCallLayoutMode)getSegmentForCount:(NSInteger)count currentIndex:(NSInteger)currentIndex {
  NEGroupCallLayoutMode segment;

  // Determine first segment style.
  if (currentIndex == 0) {
    segment = NEGroupCallLayoutModeThreeOneThirds;

    if (count == 1) {
      segment = NEGroupCallLayoutModeFullWidth;
    } else if (count >= 2 && count <= 4) {
      if (self.largeViewIndex >= 0) {
        segment = NEGroupCallLayoutModeFullWidth;
      } else {
        segment = NEGroupCallLayoutModeFiftyFifty;
      }
    } else if (self.largeViewIndex == 0) {
      segment = NEGroupCallLayoutModeOneThirdTwoThirds;
    } else if (self.largeViewIndex == 1) {
      segment = NEGroupCallLayoutModeTwoThirdsOneThirdCenter;
    } else if (self.largeViewIndex == 2) {
      segment = NEGroupCallLayoutModeTwoThirdsOneThirdRight;
    }

    YXAlogInfo(@"[GroupCallLayout] 🎯 getSegment - currentIndex: %ld, count: %ld, largeViewIndex: "
               @"%ld, 选择segment: %ld",
               (long)currentIndex, (long)count, (long)self.largeViewIndex, (long)segment);
    return segment;
  }

  switch (count - currentIndex) {
    case 1:
      if (count == 3) {
        segment = NEGroupCallLayoutModeOneThird;
      } else if (count > 4 && self.largeViewIndex == (count - 1)) {
        segment = NEGroupCallLayoutModeOneThirdTwoThirds;
      } else {
        segment = NEGroupCallLayoutModeThreeOneThirds;
      }
      break;
    case 2:
      if (count == 4) {
        segment = NEGroupCallLayoutModeFiftyFifty;
      } else if (count > 4 && self.largeViewIndex == currentIndex) {
        segment = NEGroupCallLayoutModeOneThirdTwoThirds;
      } else if (count > 4 && (self.largeViewIndex == currentIndex + 1)) {
        segment = NEGroupCallLayoutModeTwoThirdsOneThirdCenter;
      } else if (count > 4 && (self.largeViewIndex == currentIndex + 2)) {
        segment = NEGroupCallLayoutModeTwoThirdsOneThirdRight;
      } else {
        segment = NEGroupCallLayoutModeThreeOneThirds;
      }
      break;
    default:
      if (count > 4 && self.largeViewIndex == currentIndex) {
        segment = NEGroupCallLayoutModeOneThirdTwoThirds;
      } else if (count > 4 && (self.largeViewIndex == currentIndex + 1)) {
        segment = NEGroupCallLayoutModeTwoThirdsOneThirdCenter;
      } else if (count > 4 && (self.largeViewIndex == currentIndex + 2)) {
        segment = NEGroupCallLayoutModeTwoThirdsOneThirdRight;
      } else {
        segment = NEGroupCallLayoutModeThreeOneThirds;
      }
      break;
  }

  return segment;
}

#pragma mark - Animation Support (完全仿造 Swift 版本)

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:
    (NSIndexPath *)itemIndexPath {
  UICollectionViewLayoutAttributes *attributes =
      [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];

  if (attributes && _deletingIndexPaths.count > 0) {
    if ([_deletingIndexPaths containsObject:itemIndexPath]) {
      attributes.transform = CGAffineTransformMakeScale(0.5, 0.5);
      attributes.alpha = 0.0;
      attributes.zIndex = 0;
    }
  }

  return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:
    (NSIndexPath *)itemIndexPath {
  UICollectionViewLayoutAttributes *attributes =
      [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];

  if (attributes && [_insertingIndexPaths containsObject:itemIndexPath]) {
    attributes.transform = CGAffineTransformMakeScale(0.5, 0.5);
    attributes.alpha = 0.0;
    attributes.zIndex = 0;
  }

  return attributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
  [super prepareForCollectionViewUpdates:updateItems];

  for (UICollectionViewUpdateItem *update in updateItems) {
    switch (update.updateAction) {
      case UICollectionUpdateActionDelete:
        if (update.indexPathBeforeUpdate) {
          [_deletingIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        break;
      case UICollectionUpdateActionInsert:
        if (update.indexPathAfterUpdate) {
          [_insertingIndexPaths addObject:update.indexPathAfterUpdate];
        }
        break;
      default:
        break;
    }
  }
}

- (void)finalizeCollectionViewUpdates {
  [super finalizeCollectionViewUpdates];

  [_deletingIndexPaths removeAllObjects];
  [_insertingIndexPaths removeAllObjects];
}

#pragma mark - Large View Management

- (void)setLargeViewUser:(NSString *)userId atIndex:(NSInteger)index {
  YXAlogInfo(@"[GroupCallLayout] 🔄 设置大画面用户: %@, 索引: %ld (之前: %ld)", userId, (long)index,
             (long)self.largeViewIndex);
  self.showLargeViewUserId = userId;
  self.largeViewIndex = index;
  YXAlogInfo(@"[GroupCallLayout] 🔄 设置后 - largeViewIndex: %ld, showLargeViewUserId: %@",
             (long)self.largeViewIndex, self.showLargeViewUserId);
  [self invalidateLayout];
}

- (void)clearLargeView {
  YXAlogInfo(@"[GroupCallLayout] 🔄 取消大画面模式");
  self.showLargeViewUserId = @"";
  self.largeViewIndex = -1;
  [self invalidateLayout];
}

- (void)setParticipantCount:(NSInteger)participantCount {
  YXAlogInfo(@"[GroupCallLayout] 🔧 设置 participantCount: %ld -> %ld", (long)_participantCount,
             (long)participantCount);

  // 防止participantCount被意外重置为0或负数
  if (participantCount <= 0) {
    YXAlogInfo(@"[GroupCallLayout] ⚠️ 警告：尝试设置无效的 participantCount: %ld，保持原值: %ld",
               (long)participantCount, (long)_participantCount);
    return;
  }

  _participantCount = participantCount;
}

@end
