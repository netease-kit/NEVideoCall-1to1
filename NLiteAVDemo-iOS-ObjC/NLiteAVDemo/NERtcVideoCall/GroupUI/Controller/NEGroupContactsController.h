// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NECallBaseViewController.h"
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^InviteCompletion)(NSArray<NEUser *> *users);

@interface NEGroupContactsController : NECallBaseViewController

@property(nonatomic, assign) BOOL isInvite;

// 已经在通话中的成员，在通话中选择成员使用
@property(nonatomic, strong) NSMutableDictionary<NSString *, NEUser *> *inCallUserDic;

/// 待呼叫用户
@property(nonatomic, strong) NSMutableArray<NEUser *> *calledUsers;

@property(nonatomic, strong) InviteCompletion completion;

@property(nonatomic, assign) NSInteger totalCount;

@property(nonatomic, assign) NSInteger hasJoinCount;

@end

NS_ASSUME_NONNULL_END
