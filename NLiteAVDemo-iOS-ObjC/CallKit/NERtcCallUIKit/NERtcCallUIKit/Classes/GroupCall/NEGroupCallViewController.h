// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEGroupUser.h"

@class GroupPushParam;

extern NSString *const kGroupCallKitDismissNoti;

NS_ASSUME_NONNULL_BEGIN

@protocol NEGroupCallViewControllerDelegate <NSObject>

/// 群组通话邀请用户回调
- (void)inviteUsersWithCallId:(NSString *)callId
                  inCallUsers:(NSArray<NSString *> *)inCallUsers
                   completion:(void (^)(NSArray<NSString *> *_Nullable users))completion;

@end

@interface NEGroupCallViewController : UIViewController

@property(nonatomic, strong) NSString *callId;

@property(nonatomic, assign) NSInteger startTimestamp;

/// 代理
@property(nonatomic, weak) id<NEGroupCallViewControllerDelegate> delegate;

/// 是否显示邀请按钮，默认YES，显示邀请按钮
@property(nonatomic, assign) BOOL showInviteButton;

/// 推送配置参数
@property(nonatomic, strong) GroupPushParam *pushParam;

/// isCalled  是否是被叫  YES 为被叫
/// caller 主叫
- (instancetype)initWithCalled:(BOOL)isCalled withCaller:(NEGroupUser *)caller;

- (void)addUser:(NSArray<NEGroupUser *> *)users;

@end

NS_ASSUME_NONNULL_END
