//
//  NERtcVideoCallDelegate.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/19.
//  Copyright © 2020 Netease. All rights reserved.
//

#ifndef NERtcVideoCallDelegate_h
#define NERtcVideoCallDelegate_h
#import "NEUser.h"

@protocol NERtcVideoCallDelegate <NSObject>

@optional

/// 收到邀请
/// @param user 邀请方
- (void)onInvitedByUser:(NEUser *)user;

/// 接受邀请
/// @param user 接受者
- (void)onUserEnter:(NEUser *)user;

/// 拒绝邀请通知
/// @param userId 拒绝者
- (void)onRejectByUserId:(NSString *)userId;

/// 取消邀请通知
/// @param userId 邀请方
- (void)onCancelByUserId:(NSString *)userId;

/// 忙线
/// @param userId 忙线的用户ID
- (void)onUserBusy:(NSString *)userId;

/// 呼叫超时
- (void)timeOut;

/// 启用&禁用相机
/// @param available 是否可用
/// @param userId 用户ID
- (void)onCameraAvailable:(BOOL)available userId:(NSString *)userId;

/// 启用&仅用麦克风
/// @param available 是否可用
/// @param userId 用户ID
- (void)onAudioAvailable:(BOOL)available userId:(NSString *)userId;

/// 用户挂断
/// @param userId 用户Id
- (void)onUserHangup:(NSString *)userId;

@end

#endif /* NERtcVideoCallDelegate_h */
