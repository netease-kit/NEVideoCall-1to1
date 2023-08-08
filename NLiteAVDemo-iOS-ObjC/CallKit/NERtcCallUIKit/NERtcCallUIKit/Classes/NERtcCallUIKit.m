// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcCallUIKit.h"
#import <NECommonUIKit/UIView+YXToast.h>
#import <NECoreKit/NECoreKit-Swift.h>
#import <NECoreKit/XKit.h>
#import "NetManager.h"

NSString *kAudioCalling = @"kAudioCalling";

NSString *kVideoCalling = @"kVideoCalling";

NSString *kAudioInCall = @"kAudioInCall";

NSString *kVideoInCall = @"kVideoInCall";

NSString *kCalledState = @"kCalledState";

NSString *kMouldName = @"NERtcCallUIKit";

@interface NERtcCallUIKit () <NECallEngineDelegate, XKitService>

@property(nonatomic, strong) NECallUIKitConfig *config;

@property(nonatomic, strong) UIWindow *keywindow;

@property(nonatomic, strong, readwrite) NSMutableDictionary *uiConfigDic;

@property(nonatomic, strong) NSBundle *bundle;

@end

@implementation NERtcCallUIKit

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static NERtcCallUIKit *instance;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (NSString *)serviceName {
  return kMouldName;
}

- (NSString *)versionName {
  return [NERtcCallUIKit version];
}

- (NSString *)appKey {
  return self.config.appKey;
}

- (void)setupWithConfig:(NECallUIKitConfig *)config {
  if (nil != config.config) {
    [[NECallEngine sharedInstance] setup:config.config];
  }
  [[XKit instance] registerService:self];
  self.config = config;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [NetManager shareInstance];
    [[NECallEngine sharedInstance] addCallDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismiss:)
                                                 name:kCallKitDismissNoti
                                               object:nil];
    self.uiConfigDic = [[NSMutableDictionary alloc] init];
    [self.uiConfigDic setObject:NEAudioCallingController.class forKey:kAudioCalling];
    [self.uiConfigDic setObject:NEAudioInCallController.class forKey:kAudioInCall];
    [self.uiConfigDic setObject:NEVideoCallingController.class forKey:kVideoCalling];
    [self.uiConfigDic setObject:NEVideoInCallController.class forKey:kVideoInCall];
    [self registerRouter];
    [NERtcCallKit sharedInstance].recordHandler = ^(NIMMessage *message) {
      if ([[NetManager shareInstance] isClose] == YES) {
        NIMRtcCallRecordObject *object = (NIMRtcCallRecordObject *)message.messageObject;
        object.callStatus = NIMRtcCallStatusCanceled;
      }
    };
    self.bundle = [NSBundle bundleForClass:NERtcCallUIKit.class];
  }
  return self;
}

- (NSString *)localizableWithKey:(NSString *)key {
  return [self.bundle localizedStringForKey:key value:nil table:@"Localizable"];
}

- (void)registerRouter {
  [[Router shared] register:@"imkit://callkit.page"
                    closure:^(NSDictionary<NSString *, id> *_Nonnull param) {
                      if ([[NetManager shareInstance] isClose] == YES) {
                        [UIApplication.sharedApplication.keyWindow
                            ne_makeToast:[self localizableWithKey:@"network_error"]];
                        return;
                      }
                      NEUICallParam *callParam = [[NEUICallParam alloc] init];
                      callParam.currentUserAccid = [param objectForKey:@"currentUserAccid"];
                      callParam.remoteUserAccid = [param objectForKey:@"remoteUserAccid"];
                      callParam.remoteShowName = [param objectForKey:@"remoteShowName"];
                      callParam.remoteAvatar = [param objectForKey:@"remoteAvatar"];

                      NSNumber *type = [param objectForKey:@"type"];
                      NECallType callType = NECallTypeAudio;
                      if (type.intValue == 1) {
                        callType = NECallTypeAudio;
                      } else if (type.intValue == 2) {
                        callType = NECallTypeVideo;
                      }
                      callParam.callType = callType;
                      [self callWithParam:callParam];
                    }];
}

- (void)setCustomCallClass:(NSMutableDictionary<NSString *, Class> *)customDic {
  for (NSString *key in customDic.allKeys) {
    Class cls = customDic[key];
    [self.uiConfigDic setObject:cls forKey:key];
  }
}

- (void)callWithParam:(NEUICallParam *)callParam {
  NECallViewController *callVC = [[NECallViewController alloc] init];
  if (callParam.remoteShowName.length <= 0) {
    callParam.remoteShowName = callParam.remoteUserAccid;
  }
  callParam.enableAudioToVideo = self.config.uiConfig.enableAudioToVideo;
  callParam.enableVideoToAudio = self.config.uiConfig.enableVideoToAudio;
  callParam.useEnableLocalMute = self.config.uiConfig.useEnableLocalMute;
  callParam.isCaller = YES;
  if (self.customControllerClass != nil) {
    [self showCustomClassController:callParam];
    return;
  }
  callVC.status = NERtcCallStatusCalling;
  callVC.callParam = callParam;
  callVC.uiConfigDic = self.uiConfigDic;
  callVC.config = self.config.uiConfig;
  [self showCallView:callVC];
}

- (void)onReceiveInvited:(NEInviteInfo *)info {
  if (self.config.uiConfig.disableShowCalleeView == YES) {
    return;
  }

  [NIMSDK.sharedSDK.userManager
      fetchUserInfos:@[ info.callerAccId ]
          completion:^(NSArray<NIMUser *> *_Nullable users, NSError *_Nullable error) {
            if (error) {
              [UIApplication.sharedApplication.keyWindow ne_makeToast:error.description];
              return;
            } else {
              NIMUser *imUser = users.firstObject;
              NEUICallParam *callParam = [[NEUICallParam alloc] init];
              callParam.remoteUserAccid = imUser.userId;
              callParam.remoteShowName = self.config.uiConfig.calleeShowPhone == YES
                                             ? imUser.userInfo.mobile
                                             : imUser.userInfo.nickName;
              callParam.remoteAvatar = imUser.userInfo.avatarUrl;
              callParam.currentUserAccid = NIMSDK.sharedSDK.loginManager.currentAccount;
              callParam.enableAudioToVideo = self.config.uiConfig.enableAudioToVideo;
              callParam.enableVideoToAudio = self.config.uiConfig.enableVideoToAudio;
              callParam.callType = info.callType;
              callParam.isCaller = NO;
              if (self.customControllerClass != nil) {
                if (self.delegate != nil &&
                    [self.delegate respondsToSelector:@selector
                                   (didCallComingWithInviteInfo:withCallParam:withCompletion:)]) {
                  [self.delegate didCallComingWithInviteInfo:info
                                               withCallParam:callParam
                                              withCompletion:^(BOOL success) {
                                                if (success) {
                                                  [self showCustomClassController:callParam];
                                                }
                                              }];

                  return;
                }
                [self showCustomClassController:callParam];
                return;
              }
              NECallViewController *callVC = [[NECallViewController alloc] init];
              callVC.callParam = callParam;
              callVC.status = NERtcCallStatusCalled;
              callVC.uiConfigDic = self.uiConfigDic;
              callVC.config = self.config.uiConfig;
              if (self.delegate != nil &&
                  [self.delegate respondsToSelector:@selector
                                 (didCallComingWithInviteInfo:withCallParam:withCompletion:)]) {
                [self.delegate didCallComingWithInviteInfo:info
                                             withCallParam:callParam
                                            withCompletion:^(BOOL success) {
                                              if (success) {
                                                [self showCustomClassController:callParam];
                                              }
                                            }];

                return;
              }
              [self showCallView:callVC];
            }
          }];
}

- (void)showCalled:(NIMUser *)imUser callType:(NECallType)type attachment:(NSString *)attachment {
  if (self.keywindow != nil) {
    return;
  }
  NECallViewController *callVC = [[NECallViewController alloc] init];
  NEUICallParam *callParam = [[NEUICallParam alloc] init];
  callParam.remoteUserAccid = imUser.userId;
  callParam.remoteShowName = imUser.userInfo.mobile;
  callParam.remoteAvatar = imUser.userInfo.avatarUrl;
  callParam.currentUserAccid = NIMSDK.sharedSDK.loginManager.currentAccount;
  callParam.enableVideoToAudio = self.config.uiConfig.enableVideoToAudio;
  callParam.enableAudioToVideo = self.config.uiConfig.enableAudioToVideo;
  callParam.callType = type;
  callParam.isCaller = NO;
  if (self.customControllerClass != nil) {
    [self showCustomClassController:callParam];
    return;
  }
  callVC.callParam = callParam;
  callVC.status = NERtcCallStatusCalled;
  callVC.uiConfigDic = self.uiConfigDic;
  callVC.config = self.config.uiConfig;
  [self showCallView:callVC];
}

- (void)showCallView:(UIViewController *)callVC {
  UINavigationController *nav = [self getKeyWindowNav];
  UINavigationController *callNav =
      [[UINavigationController alloc] initWithRootViewController:callVC];
  callNav.modalPresentationStyle = UIModalPresentationFullScreen;
  [callNav.navigationBar setHidden:YES];
  [nav presentViewController:callNav animated:YES completion:nil];
}

- (UINavigationController *)getKeyWindowNav {
  UIWindow *window = [[UIWindow alloc] init];
  window.frame = [[UIScreen mainScreen] bounds];
  window.windowLevel = UIWindowLevelStatusBar - 1;
  UIViewController *root = [[UIViewController alloc] init];
  root.view.backgroundColor = [UIColor clearColor];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
  nav.navigationBar.tintColor = [UIColor clearColor];
  nav.view.backgroundColor = [UIColor clearColor];
  [nav.navigationBar setHidden:YES];
  self.keywindow = window;
  window.rootViewController = nav;
  window.backgroundColor = [UIColor clearColor];
  [window makeKeyAndVisible];
  return nav;
}

- (void)didDismiss:(NSNotification *)noti {
  UINavigationController *nav = (UINavigationController *)self.keywindow.rootViewController;
  __weak typeof(self) weakSelf = self;
  [nav dismissViewControllerAnimated:YES
                          completion:^{
                            __strong typeof(self) strongSelf = weakSelf;
                            NSLog(@"self window %@", strongSelf.keywindow);
                            [strongSelf.keywindow resignKeyWindow];
                            strongSelf.keywindow = nil;
                          }];
}

+ (NSString *)version {
  return @"2.1.0";
}

- (void)showCustomClassController:(NEUICallParam *)callParam {
  NECallViewBaseController *callViewController = [[self.customControllerClass alloc] init];
  callViewController.callParam = callParam;
  if ([callViewController isKindOfClass:[NECallViewController class]]) {
    NECallViewController *callVC = (NECallViewController *)callViewController;
    callVC.status = callParam.isCaller == YES ? NERtcCallStatusCalling : NERtcCallStatusCalled;
    callVC.callParam = callParam;
    callVC.uiConfigDic = self.uiConfigDic;
    callVC.config = self.config.uiConfig;
  }
  [self showCallView:callViewController];
}

@end
