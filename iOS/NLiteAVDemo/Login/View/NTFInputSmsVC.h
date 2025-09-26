// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/**
 输入验证码VC
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NELoginOptions;

@interface NTFInputSmsVC : UIViewController

/**
 实例化登录视图(输入手机号)
 @param mobile  - 登录手机号
 @param options - 登录配置项
 */
- (instancetype)initWithMobile:(NSString *)mobile options:(NELoginOptions *_Nullable)options;

@end

NS_ASSUME_NONNULL_END
