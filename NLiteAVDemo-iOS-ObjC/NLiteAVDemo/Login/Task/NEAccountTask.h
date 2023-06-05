// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NETask.h"

NS_ASSUME_NONNULL_BEGIN

// 手机验证码登录
@interface NESmsLoginTask : NETask
@property(nonatomic, copy) NSString *req_mobile;
@property(nonatomic, copy) NSString *req_smsCode;
@end

// 登出
@interface NELogoutTask : NETask
@property(nonatomic, copy) NSString *mobile;
@end

// 刷新令牌
@interface NETokenLoginTask : NETask

@end

NS_ASSUME_NONNULL_END
