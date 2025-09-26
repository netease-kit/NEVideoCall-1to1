// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEGroupUser : NSObject

#pragma mark - 基本属性

/// 用户系统手机号
@property(strong, nonatomic) NSString *mobile;
/// 用户头像
@property(strong, nonatomic) NSString *avatar;
/// 用户昵称
@property(strong, nonatomic) NSString *nickname;
/// 云信IM 账号ID
@property(strong, nonatomic, nonnull) NSString *imAccid;

#pragma mark - 群组呼叫

@property(assign, nonatomic) NSInteger
    state;  // 呼叫者通话状态 0 不在房间中，待接听，1 已经在房间中， 2 用户已经挂断，3 邀请失败

@property(assign, nonatomic) uint64_t uid;

@property(assign, nonatomic) NSInteger isShowLocalVideo;

@property(assign, nonatomic) BOOL isOpenVideo;

@end

NS_ASSUME_NONNULL_END
