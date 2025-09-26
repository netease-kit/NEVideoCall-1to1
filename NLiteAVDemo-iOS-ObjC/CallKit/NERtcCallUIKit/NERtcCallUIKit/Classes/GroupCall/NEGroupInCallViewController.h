// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEGroupUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEGroupInCallViewController : UIViewController

- (void)changeUsers:(NSArray<NSArray<NEGroupUser *> *> *)users;

/// 切换大画面用户
- (void)switchToLargeViewUser:(NEGroupUser *)user atIndex:(NSInteger)index;

/// 取消大画面模式
- (void)clearLargeView;

@end

NS_ASSUME_NONNULL_END
