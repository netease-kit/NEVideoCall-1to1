//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUICallParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallViewBaseController : UIViewController

@property(nonatomic, strong, nullable) NEUICallParam *callParam;

/// 只用于跟未接通原因(话单)相关的toast，可根据外部配置是否显示toast
- (void)showToastWithContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
