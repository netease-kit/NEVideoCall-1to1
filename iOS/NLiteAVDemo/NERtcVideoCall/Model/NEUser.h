// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEUser : NSObject <NSCoding, NSCopying>

/// 用户系统手机号
@property(strong, nonatomic) NSString *mobile;
/// 用户头像
@property(strong, nonatomic) NSString *avatar;
/// 云信IM 账号ID
@property(strong, nonatomic, nonnull) NSString *imAccid;
/// 云信IM token
@property(strong, nonatomic, nonnull) NSString *imToken;
/// 用户系统登录token
@property(strong, nonatomic) NSString *accessToken;
/// 音视频房间ID
@property(assign, nonatomic) NSString *avRoomUid;
// 主叫
@property(assign, nonatomic) BOOL isCaller;

#pragma mark - 群组呼叫

@property(assign, nonatomic) NSInteger
    state;  // 呼叫者通话状态 0 不在房间中，待接听，1 已经在房间中， 2 用户已经挂断，3 邀请失败

@property(assign, nonatomic) uint64_t uid;

@property(assign, nonatomic) NSInteger isShowLocalVideo;

@property(assign, nonatomic) BOOL isOpenVideo;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (NEUser *)getCopy;

@end

NS_ASSUME_NONNULL_END
