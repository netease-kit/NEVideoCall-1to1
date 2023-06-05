// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEBaseViewController.h"
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEGroupCallViewController : UIViewController

@property(nonatomic, strong) NSString *callId;

@property(nonatomic, assign) NSInteger startTimestamp;

/// isCalled  是否是被叫  YES 为被叫
/// caller 主叫
- (instancetype)initWithCalled:(BOOL)isCalled withCaller:(NEUser *)caller;

- (void)addUser:(NSArray<NEUser *> *)users;

@end

NS_ASSUME_NONNULL_END
