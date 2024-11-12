// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallKitPstn.h"
#import <YXAlog_iOS/YXAlog.h>
#import <objc/message.h>
#import "NERtcCallKit+Pstn.h"

#define kNERtcCallKitErrorDomain @"com.netease.nmc.rtc.pstn.error"

static const NSUInteger kNERtcCallKitPstnAccidError = 30001;  // im accid 获取失败

static const NSUInteger kNERtcCallKitPstnRtcUidError = 30002;  // rtc uid 获取失败

static const NSUInteger kNERtcCallKitPstnTokenError = 30003;  // 安全模式 token 获取失败

static const NSUInteger kNERtcCallKitPstnAppkeyError = 30004;  // IM SDK Appkey 为空

static const NSUInteger kNERtcCallKitPstnPhoneError = 30004;  // 手机号为空

@interface NECallKitPstn () <NERtcCallKitDelegate, NERtcLinkEngineDelegate>

@property(nonatomic, weak) id<NERtcCallKitDelegate> delegate;

@property(nonatomic, weak) id<NERtcLinkEngineDelegate, NECallKitPstnDelegate> pstnDelegate;

/// 安全模式音视频房间token获取，nil表示非安全模式. Block中一定要调用complete
@property(nonatomic, copy, nullable) NERtcCallKitTokenHandler tokenHandler;

@property(nonatomic, strong) NSString *phoneNumber;

@property(nonatomic, strong) NECallKitPstnCallBack completion;

@property(nonatomic, assign) NSInteger uid;

@property(nonatomic, strong) NSString *token;

@end

@implementation NECallKitPstn

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static NECallKitPstn *instance;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [[NERtcCallKit sharedInstance] addDelegate:self];
    self.tokenHandler = [[NERtcCallKit sharedInstance] tokenHandler];
    NERtcLinkEngineContext *context = [[NERtcLinkEngineContext alloc] init];
    context.delegate = self;
    [[NERtcLinkEngine sharedEngine] setUpEngineWithContext:context];
    self.token = @"";
  }
  return self;
}

- (void)dealloc {
  [[NERtcCallKit sharedInstance] removeDelegate:self];
}

- (void)addDelegate:(id<NERtcCallKitDelegate>)delegate {
  self.delegate = delegate;
}

- (void)removeDelegate {
  self.delegate = nil;
}

- (void)addPstnDelegate:(id<NERtcLinkEngineDelegate, NECallKitPstnDelegate>)delegate {
  self.pstnDelegate = delegate;
}

- (void)removePstnDelegate {
  self.pstnDelegate = nil;
}

- (void)hangupWithCompletion:(NECallKitPstnCallBack)completion {
  YXAlogInfo(@"hangupWithCompletion");
  dispatch_queue_t queue = dispatch_queue_create("pstn_hangup", NULL);
  self.completion = completion;
  dispatch_async(queue, ^{
    YXAlogInfo(@"pstn start hangup");
    int ret = [[NERtcLinkEngine sharedEngine] directCallHangupCall];
    YXAlogInfo(@"pstn hangup ret : %d", ret);
  });
  [self cleanUp];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  BOOL respond = class_respondsToSelector([self class], aSelector);
  if (respond == YES) {
    return YES;
  }
  if (self.delegate != nil && [self.delegate respondsToSelector:aSelector]) {
    return YES;
  }
  return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
  if (class_respondsToSelector([self class], aSelector)) {
    return self;
  }
  if (self.delegate != nil && [self.delegate respondsToSelector:aSelector]) {
    return self.delegate;
  }
  return [super forwardingTargetForSelector:aSelector];
}

- (void)setupAppKey:(NSString *)appKey options:(NERtcCallOptions *)options {
  [[NERtcCallKit sharedInstance] setupAppKey:appKey options:options];
}

#pragma mark - callkit delegate

- (void)onCallingTimeOut {
  YXAlogInfo(@"pstn onCallingTimeOut");
  if (self.pstnDelegate == nil) {
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self.pstnDelegate respondsToSelector:@selector(onTimeOut)]) {
      [self.pstnDelegate onTimeOut];
    }
  });
  NSString *rtcToken = [[NERtcCallKit sharedInstance] valueForKeyPath:@"context.token"];
  if (rtcToken.length > 0) {
    YXAlogInfo(@"pstn get rtc token : %@", rtcToken);
    self.token = rtcToken;
  }
  if (self.pstnDelegate != nil && [self.pstnDelegate respondsToSelector:@selector(pstnWillStart)]) {
    [self.pstnDelegate pstnWillStart];
  }
  [self setCallKitStatusCalling];
  NSString *accid = [[NIMSDK sharedSDK].v2LoginService getLoginUser];
  if (accid.length <= 0) {
    [self callKitErrorWithMsg:@"get im accid is empty" withCode:kNERtcCallKitPstnAccidError];
    return;
  }
  __weak typeof(self) weakSelf = self;
  [[NERtcCallKit sharedInstance] memberOfAccid:accid
                                    completion:^(NIMSignalingMemberInfo *_Nullable info) {
                                      if (info == nil) {
                                        [weakSelf callKitErrorWithMsg:@"get rtc uid failed"
                                                             withCode:kNERtcCallKitPstnRtcUidError];
                                      } else {
                                        [weakSelf pstnCallWithUid:info.uid];
                                      }
                                    }];
}

#pragma mark - pstn delegate

- (void)onDirectCallRing {
  if (self.pstnDelegate != nil &&
      [self.pstnDelegate respondsToSelector:@selector(onDirectCallRing)]) {
    [self.pstnDelegate onDirectCallRing];
  }
}

- (void)onDirectCallAccept {
  if (self.pstnDelegate != nil &&
      [self.pstnDelegate respondsToSelector:@selector(onDirectCallAccept)]) {
    [self.pstnDelegate onDirectCallAccept];
  }
  [self setCallKitStatusInCall];
}

- (void)onDirectCallDisconnectWithError:(NSError *)error {
  if (self.pstnDelegate != nil &&
      [self.pstnDelegate respondsToSelector:@selector(onDirectCallDisconnectWithError:)]) {
    [self.pstnDelegate onDirectCallDisconnectWithError:error];
  }
  [self didOnError:error];
}

- (void)onDirectCallHangupWithReason:(int)reason
                               error:(NSError *)error
                   isCallEstablished:(BOOL)isCallEstablished {
  YXAlogInfo(@"onDirectCallHangupWithReason : %ld", reason);
  YXAlogInfo(@"onDirectCallHangupWithReason error : %@", error);
  if (error != nil) {
    [self callkitOnErrorCallback:error];
  }

  if (self.pstnDelegate != nil &&
      [self.pstnDelegate
          respondsToSelector:@selector(onDirectCallHangupWithReason:error:isCallEstablished:)]) {
    [self.pstnDelegate onDirectCallHangupWithReason:reason
                                              error:error
                                  isCallEstablished:isCallEstablished];
  }

  [self callKitEndCallback];
  [self setCallKitStatusIdle];
}

#pragma mark - private

- (void)setCallKitStatusInCall {
  if ([[NERtcCallKit sharedInstance] respondsToSelector:@selector(changeStatusInCall)]) {
    [[NERtcCallKit sharedInstance] changeStatusInCall];
    YXAlogInfo(@"pstn setCallkitStatusInCall");
  }
}

- (void)setCallKitStatusIdle {
  if ([[NERtcCallKit sharedInstance] respondsToSelector:@selector(changeStatusIdle)]) {
    [[NERtcCallKit sharedInstance] changeStatusIdle];
    YXAlogInfo(@"pstn setCallKitStatusIdle");
  }
}

- (void)setCallKitStatusCalling {
  if ([[NERtcCallKit sharedInstance] respondsToSelector:@selector(changeStatusCalling)]) {
    [[NERtcCallKit sharedInstance] changeStatusCalling];
    YXAlogInfo(@"pstn setCallKitStatusCalling");
  }
}

- (void)callKitEndCallback {
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onCallEnd)]) {
    [self.delegate onCallEnd];
  }
  [[NERtcEngine sharedEngine] leaveChannel];
  self.phoneNumber = nil;
}

- (void)callkitOnErrorCallback:(NSError *)error {
  //    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onError:)]) {
  //        [self.delegate onError:error];
  //    }
  if (self.pstnDelegate != nil && [self.pstnDelegate respondsToSelector:@selector(pstnOnError:)]) {
    [self.pstnDelegate pstnOnError:error];
  }
}

- (void)callKitErrorWithMsg:(NSString *)errorMsg withCode:(NSInteger)code {
  NSError *error = [NSError errorWithDomain:kNERtcCallKitErrorDomain
                                       code:code
                                   userInfo:@{NSLocalizedDescriptionKey : errorMsg}];
  [self didOnError:error];
}

- (void)didOnError:(NSError *)error {
  YXAlogInfo(@"pstn didOnError : %@", error);
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(onError:)]) {
    [self callkitOnErrorCallback:error];
  }
  [self callKitEndCallback];
  [self setCallKitStatusIdle];
}

- (void)pstnCallWithUid:(int64_t)uid {
  __weak typeof(self) weakSelf = self;

  if (self.tokenHandler) {
    if (self.token.length > 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf didPstnCallWithUid:uid withToken:self.token];
      });
    } else {
      self.tokenHandler(uid, [NSString stringWithFormat:@"%lld", uid],
                        ^(NSString *token, NSError *error) {
                          if (error) {
                            [weakSelf callKitErrorWithMsg:@"安全模式token获取失败"
                                                 withCode:kNERtcCallKitPstnTokenError];
                          } else {
                            [weakSelf didPstnCallWithUid:uid withToken:token];
                          }
                        });
    }
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf didPstnCallWithUid:uid withToken:self.token];
    });
  }
}

- (void)didPstnCallWithUid:(int64_t)uid withToken:(NSString *)token {
  NSString *appkey = [NIMSDK sharedSDK].appKey;
  if (appkey.length <= 0) {
    [self callKitErrorWithMsg:@"im sdk appkey is empty" withCode:kNERtcCallKitPstnAppkeyError];
    return;
  }

  if (self.phoneNumber.length <= 0) {
    [self callKitErrorWithMsg:@"callee phone number is empty" withCode:kNERtcCallKitPstnPhoneError];
    return;
  }

  NSString *channelName = [NSString stringWithFormat:@"%llu", uid];

  __weak typeof(self) weakSelf = self;

  YXAlogInfo(@"pstn join channel uid : %llu", uid);
  YXAlogInfo(@"pstn join channel channel name : %@", channelName);
  YXAlogInfo(@"pstn join token : %@", token);

  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NERtcCallKit sharedInstance] enableLocalVideo:NO];
        [[NERtcEngine sharedEngine]
            joinChannelWithToken:token
                     channelName:channelName
                           myUid:uid
                      completion:^(NSError *_Nullable error, uint64_t channelId, uint64_t elapesd,
                                   uint64_t uid) {
                        if (error) {
                          YXAlogInfo(@"pstn join rtc cahnnel error : %@", error);
                          [weakSelf didOnError:error];
                        } else {
                          YXAlogInfo(@"join rtc cahnnel success channelid : %lld", channelId);
                          weakSelf.uid = uid;
                          NERtcLinkEngineDirectCallCallParam *param =
                              [[NERtcLinkEngineDirectCallCallParam alloc] init];
                          param.uid = uid;
                          param.token = token;
                          param.appKey = appkey;
                          param.callee = self.phoneNumber;
                          param.mediaType = kNERtcLinkCallMediaTypeAudio;
                          param.channelName = channelName;
                          if (weakSelf.pstnDelegate != nil &&
                              [weakSelf.pstnDelegate respondsToSelector:@selector(pstnDidStart)]) {
                            [weakSelf.pstnDelegate pstnDidStart];
                          }

                          [[NERtcLinkEngine sharedEngine]
                              directCallStartCallWithParam:param
                                           completionBlock:^(NSError *_Nullable error) {
                                             if (weakSelf.pstnDelegate != nil &&
                                                 [weakSelf.pstnDelegate
                                                     respondsToSelector:@selector
                                                     (directCallStartCallFinish)]) {
                                               [weakSelf.pstnDelegate directCallStartCallFinish];
                                             }
                                             if (error) {
                                               YXAlogError(
                                                   @"directCallStartCallWithParam error : %@",
                                                   error);
                                               [weakSelf didOnError:error];
                                             } else {
                                               YXAlogInfo(@"directCallStartCallWithParam success");
                                             }
                                           }];
                        }
                      }];
      });
}

- (void)setCallee:(NSString *)phone {
  self.phoneNumber = phone;
}

- (void)cleanUp {
  self.token = @"";
  self.phoneNumber = nil;
}

@end
