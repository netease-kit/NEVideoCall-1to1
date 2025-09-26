// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcSDK/NERtcSDK.h>
#import <NIMSDK/NIMSDK.h>
#import "AppKey.h"
#import "NERtcVideoCallDelegate.h"
#import "NERtcVideoCallModel.h"
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, NECallStatus) {
  NECallStatusNone = 0,          // 闲置
  NECallStatusCall = 1 << 0,     // 呼叫
  NECallStatusCalled = 1 << 1,   // 被呼叫
  NECallStatusCalling = 1 << 2,  // 通话中
};

static NSString *const token =
    @"";  // 请输入NERtcSDK 频道Token 如果没有 请联系云信商务经理开通非安全模式
@interface NERtcVideoCall : NSObject <NIMSignalManagerDelegate, NERtcEngineDelegateEx>

@property(assign, nonatomic) NECallStatus callStatus;

/// 单位:秒,IM服务器邀请2分钟后无响应为超时,最大值不超过2分钟。
@property(assign, nonatomic) NSInteger timeOutSeconds;

/// 单例
+ (instancetype)shared;

/// 初始化，所有功能需要先初始化
- (void)setupAppKey:(NSString *)appKey;

/// 初始化
/// @param appKey 云信后台注册的appKey
/// @param APNSCerName 推送证书名字(包含公钥和私钥的.p12),需和云信控制台上传名字一致
/// @param VoIPCerName VoIP证书名字
- (void)setupAppKey:(NSString *)appKey
        APNSCerName:(NSString *__nullable)APNSCerName
        VoIPCerName:(NSString *__nullable)VoIPCerName;

/// 登录IM接口，所有功能需要先进行登录后才能使用
/// @param user 用户信息 在 account、token信息的基础上扩展了用户手机号、头像信息
/// @param success 成功回调
/// @param failed 失败回调
- (void)login:(NEUser *)user
      success:(void (^)(void))success
       failed:(void (^)(NSError *error))failed;

/// 更新APNS deviceToken
/// @param deviceToken 注册获得的deviceToken
- (void)updateApnsToken:(NSData *)deviceToken;

/// 登出
- (void)logout;

/// 开始呼叫
- (void)call:(NEUser *)user completion:(void (^)(NSError *__nullable error))completion;

/// 取消呼叫
- (void)cancel:(void (^)(NSError *__nullable error))completion;

/// 接受呼叫
- (void)accept:(void (^)(NSError *__nullable error))completion;

/// 拒绝呼叫
- (void)reject:(void (^)(NSError *__nullable error))completion;

/// 挂断
- (void)hangup;

/// 设置自己画面
/// @param localView 渲染自己画面的View
- (void)setupLocalView:(UIView *)localView;

/// 设置其他用户画面
/// @param remoteView 渲染其他画面的View
/// @param userID 其他用户ID
- (void)setupRemoteView:(UIView *)remoteView userID:(uint64_t)userID;

/// 开关摄像头
- (void)enableCamera:(BOOL)enable;

/// 切换摄像头
- (void)switchCamera;

/// 关闭麦克风
/// @param mute YES：关闭 NO：开启
- (void)setMicMute:(BOOL)mute;

/// 添加代理 接受回调
/// @param delegate 代理对象
- (void)addDelegate:(id<NERtcVideoCallDelegate>)delegate;
/// 移除代理
/// @param delegate 代理对象
- (void)removeDelegate:(id<NERtcVideoCallDelegate>)delegate;
/// 移除所有代理对象
- (void)removeAllDelegte;

@end

NS_ASSUME_NONNULL_END
