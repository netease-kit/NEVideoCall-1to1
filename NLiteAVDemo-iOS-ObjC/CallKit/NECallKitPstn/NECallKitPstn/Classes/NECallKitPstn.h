// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import <NERtcSDK/NERtcSDK.h>

//! Project version number for NECallKitPstn.
FOUNDATION_EXPORT double NECallKitPstnVersionNumber;

//! Project version string for NECallKitPstn.
FOUNDATION_EXPORT const unsigned char NECallKitPstnVersionString[];

// In this header, you should import all the public headers of your framework using statements like
// #import <NECallKitPstn/PublicHeader.h>

typedef void (^NECallKitPstnCallBack)(NSError *_Nullable error);

@protocol NECallKitPstnDelegate <NSObject>

/// rtc 超时，开始进入pstn 流程
- (void)pstnWillStart;

/// 开始进入pstn呼叫流程回调，主叫通话相关操作需要调用pstn api(挂断 取消等)
- (void)pstnDidStart;

- (void)pstnOnError:(NSError *_Nullable)error;

// 回调呼叫组件的超时，不是pstn的超时回调(因为内部hook呼叫组件的超时，如果使用pstn拿不到呼叫组件的超时，无法做统计之类的操作)
- (void)onTimeOut;

@optional
/// 转接pstn接口有返回回调，rtc转 pstn
/// 呼叫接口需要等待异步回调有返回才能做取消/挂断操作，UI可根据此回调判断是否有返回
- (void)directCallStartCallFinish;

@end

@interface NECallKitPstn : NSObject

/// 单例
+ (instancetype _Nonnull)sharedInstance;

/// 添加代理 接受回调
/// @param delegate   呼叫组件代理对象
- (void)addDelegate:(id<NERtcCallKitDelegate> _Nonnull)delegate;

/// 移除代理
- (void)removeDelegate;

/// 添加代理，接受Pstn回调
/// @param delegate 实现pstn协议的对象
- (void)addPstnDelegate:(id<NERtcLinkEngineDelegate, NECallKitPstnDelegate> _Nonnull)delegate;

/// 移除Pstn代理
- (void)removePstnDelegate;

/// 设置呼叫手机号码
- (void)setCallee:(NSString *_Nonnull)phone;

/// 初始化，所有功能需要先初始化
/// @param appKey 云信后台注册的appKey
//- (void)setupAppKey:(NSString *)appKey options:(nullable NERtcCallOptions *)options;

/// 挂断或取消呼叫(针对pstn是同一个接口)
/// @param completion 回调
- (void)hangupWithCompletion:(NECallKitPstnCallBack _Nonnull)completion;

- (void)cleanUp;

@end
