// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "SettingManager.h"
#import <NERtcCallKit/NERtcCallKit.h>
NSString *const kYXOTOTimeOut = @"kYXOTOTimeOut";

NSString *const kShowCName = @"kShowCName";

@interface SettingManager ()

@property(nonatomic, assign, readwrite) NSInteger timeout;

@property(nonatomic, assign, readwrite) BOOL supportAutoJoinWhenCalled;

@property(nonatomic, assign, readwrite) BOOL rejectBusyCode;

@property(nonatomic, assign, readwrite) BOOL openCustomTokenAndChannelName;

@property(nonatomic, assign, readwrite) bool incallShowCName;

@property(nonatomic, assign, readwrite) BOOL useEnableLocalMute;

@property(nonatomic, assign, readwrite) BOOL isGlobalInit;

@end

@implementation SettingManager

+ (id)shareInstance {
  static SettingManager *shareInstance = nil;
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    if (!shareInstance) {
      shareInstance = [[self alloc] init];
    }
  });
  return shareInstance;
}

- (void)setCallKitUid:(uint64_t)uid {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithUnsignedLongLong:uid]
                               forKeyPath:@"context.currentUserUid"];

  //  if ([[NECallEngine sharedInstance] respondsToSelector:@selector(changeStatusIdle)]) {
  //    [[NECallEngine sharedInstance] changeStatusIdle];
  //  }
}

- (uint64_t)getCallKitUid {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.currentUserUid"]
      unsignedLongLongValue];
}

- (void)setAutoJoin:(BOOL)autoJoin {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:autoJoin]
                               forKeyPath:@"context.supportAutoJoinWhenCalled"];
  [[NERtcCallUIKit sharedInstance] setValue:[NSNumber numberWithInt:autoJoin]
                                 forKeyPath:@"config.uiConfig.showCallingSwitchCallType"];
  self.supportAutoJoinWhenCalled = autoJoin;
}

- (void)setBusyCode:(BOOL)open {
  self.rejectBusyCode = open;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.isGroupPush = YES;
    self.supportAutoJoinWhenCalled = [[[NECallEngine sharedInstance]
        valueForKeyPath:@"context.supportAutoJoinWhenCalled"] boolValue];
    self.rejectBusyCode = NO;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSNumber *showCname = [userDefault objectForKey:kShowCName];
    if (showCname != nil) {
      self.incallShowCName = [showCname boolValue];
    }
    NSLog(@"current accid : %@", [NIMSDK.sharedSDK.v2LoginService getLoginUser]);
  }
  return self;
}

- (void)setTimeoutWithSecond:(NSInteger)second {
  [[NECallEngine sharedInstance] setTimeOutSeconds:second];
}

- (NSInteger)timeout {
  return [[NECallEngine sharedInstance] timeOutSeconds];
}

- (BOOL)isGlobalInit {
  return !([[[NECallEngine sharedInstance] valueForKeyPath:@"context.initRtcMode"] intValue] == 1);
}

- (void)setIsGlobalInit:(BOOL)isGlobalInit
            withApnsCer:(NSString *)apnsCer
             withAppkey:(NSString *)appkey {
  NSNumber *number = [NSNumber numberWithInteger:2];
  if (isGlobalInit == NO) {
    number = [NSNumber numberWithInteger:1];
  }
  [[NECallEngine sharedInstance] setValue:number forKeyPath:@"context.initRtcMode"];
}

- (BOOL)isJoinRtcWhenCall {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.joinRtcWhenCall"] boolValue];
}

- (void)setIsJoinRtcWhenCall:(BOOL)isJoinRtcWhenCall {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:isJoinRtcWhenCall]
                               forKeyPath:@"context.joinRtcWhenCall"];
}

- (BOOL)isAudioConfirm {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.confirmAudio"] boolValue];
}

- (void)setIsAudioConfirm:(BOOL)isAudioConfirm {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:isAudioConfirm]
                               forKeyPath:@"context.confirmAudio"];
}

- (BOOL)isVideoConfirm {
  return [[[NECallEngine sharedInstance] valueForKeyPath:@"context.confirmVideo"] boolValue];
}

- (void)setIsVideoConfirm:(BOOL)isVideoConfirm {
  [[NECallEngine sharedInstance] setValue:[NSNumber numberWithBool:isVideoConfirm]
                               forKeyPath:@"context.confirmVideo"];
}

- (NSString *)getRtcCName {
  return [[NECallEngine sharedInstance] valueForKeyPath:@"context.channelInfo.channelName"];
}

- (void)setShowCName:(BOOL)show {
  self.incallShowCName = show;
  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  [userDefault setObject:[NSNumber numberWithBool:show] forKey:kShowCName];
  [userDefault synchronize];
}

// 1.5.6 add
- (void)setEnableLocal:(BOOL)enable {
  self.useEnableLocalMute = enable;
}

@end
