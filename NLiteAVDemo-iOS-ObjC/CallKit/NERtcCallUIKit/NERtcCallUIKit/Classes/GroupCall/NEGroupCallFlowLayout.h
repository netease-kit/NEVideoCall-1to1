// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NEGroupCallLayoutMode) {
  NEGroupCallLayoutModeFullWidth = 0,            // 全屏布局
  NEGroupCallLayoutModeFiftyFifty,               // 50:50分屏
  NEGroupCallLayoutModeOneThird,                 // 1/3居中
  NEGroupCallLayoutModeThreeOneThirds,           // 1/3 + 1/3 + 1/3
  NEGroupCallLayoutModeTwoThirdsOneThirdRight,   // 2/3 + 1/3 (右)
  NEGroupCallLayoutModeTwoThirdsOneThirdCenter,  // 2/3 + 1/3 (中)
  NEGroupCallLayoutModeOneThirdTwoThirds         // 1/3 + 2/3
};

@interface NEGroupCallFlowLayout : UICollectionViewFlowLayout

/// 参与人数，用于计算布局
@property(nonatomic, assign) NSInteger participantCount;

///// 容器尺寸
//@property (nonatomic, assign) CGSize containerSize;

/// 大画面用户索引 (-1表示无大画面)
@property(nonatomic, assign) NSInteger largeViewIndex;

/// 大画面用户ID
@property(nonatomic, strong) NSString *showLargeViewUserId;

/// 设置大画面用户
- (void)setLargeViewUser:(NSString *)userId atIndex:(NSInteger)index;

/// 取消大画面模式
- (void)clearLargeView;

@end

NS_ASSUME_NONNULL_END
