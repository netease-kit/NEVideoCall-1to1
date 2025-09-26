// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "AppDelegate.h"
#import <NERtcCallKit/NECallEngine.h>
#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import <NIMSDK/NIMSDK.h>
#import <UserNotifications/UserNotifications.h>
#import "CustomVideoCallingController.h"
#import "NECallCustomController.h"
#import "NEMenuViewController.h"
#import "NENavigator.h"
#import "NEPSTNViewController.h"
#import "SettingManager.h"
#import <PushKit/PushKit.h>
#import "NEGroupContactsController.h"

@interface AppDelegate () <NERtcCallKitDelegate,
                           UNUserNotificationCenterDelegate,
                           NIMSDKConfigDelegate,
                           NECallUIKitDelegate,
                           PKPushRegistryDelegate>

@property(nonatomic, strong) NSDictionary *blockDictionary;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) PKPushRegistry *pushRegistry;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self initWindow];
  [self setupSDK];
  [self registerAPNS];
  [self registerPushKit];
  return YES;
}

- (void)initWindow {
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.backgroundColor = UIColor.whiteColor;
  NEMenuViewController *menuVC = [[NEMenuViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menuVC];
  self.window.rootViewController = nav;
  [NENavigator shared].navigationController = nav;
  [self.window makeKeyAndVisible];
  /*
// 外部注册自定义UI示例代码
NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, NSString *> *> *stateConfigDic =
[[NSMutableDictionary alloc] init]; NSMutableDictionary<NSString *, NSString *> *uiConfig =
[[NSMutableDictionary alloc] init]; [uiConfig
setObject:NSStringFromClass(NEAudioCallingController.class) forKey:kAudioCalling]; [stateConfigDic
setObject:uiConfig forKey:@(kNormalUIType)];

// 内部初始化获取
NSMutableDictionary<NSString *, NSString *> *getConfig = [stateConfigDic
objectForKey:@(kNormalUIType)]; NSString *className = [getConfig objectForKey:kAudioCalling];
NSLog(@"class name : %@", className);

// 动态构建外部实例
Class cls = NSClassFromString(className);
UIViewController *controller = [[cls alloc] init];
NSLog(@"class instance : %@", controller);
   */
}

/*
- (void)setupCallKit {

    // 美颜设置
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    NSDictionary *params = @{
        kNERtcKeyPublishSelfStreamEnabled: @YES,    // 打开推流
        kNERtcKeyVideoCaptureObserverEnabled: @YES  // 将摄像头采集的数据回调给用户
    };
    [coreEngine setParameters:params];

    // 呼叫组件初始化
    NERtcCallOptions *option = [NERtcCallOptions new];
    option.APNSCerName = @"your apns cer name";
    NERtcCallKit *callkit = [NERtcCallKit sharedInstance];
    [callkit setupAppKey:@"your app key" options:option];

    //呼叫组件设置rtc代理中转
    callkit.engineDelegate = self;
}

// 在代理方法中对视频数据进行处理
- (void)onNERtcEngineVideoFrameCaptured:(CVPixelBufferRef)bufferRef
rotation:(NERtcVideoRotationType)rotation
{
    // 对视频数据 bufferRef 进行处理, 务必保证 CVPixelBufferRef 的地址值不变，分辨率不变
}*/

- (void)setupSDK {
  NIMSDKOption *option = [NIMSDKOption optionWithAppKey:kAppKey];
  option.apnsCername = kAPNSCerName;
  //pushkit 证书， 实现 LiveCommunicationKit 接听电话
  if (@available(iOS 17.4, *)) {
    option.pkCername = VoIPCerName;
  }

  option.v2 = YES;

  [NIMSDK.sharedSDK registerWithOptionV2:option v2Option:nil];

  NESetupConfig *setupConfig = [[NESetupConfig alloc] initWithAppkey:kAppKey];
  [[NECallEngine sharedInstance] setup:setupConfig];
  [[NECallEngine sharedInstance] setTimeout:30];

  NECallUIKitConfig *config = [[NECallUIKitConfig alloc] init];
  config.uiConfig.showCallingSwitchCallType = YES;
  config.uiConfig.enableFloatingWindow = YES;
  config.uiConfig.enableFloatingWindowOutOfApp = YES;
  config.uiConfig.language = NECallUILanguageAuto;
  [[NERtcCallUIKit sharedInstance] setupWithConfig:config];
  [NERtcCallUIKit sharedInstance].delegate = self;

  // 自定义UI示例
  [NERtcCallUIKit sharedInstance].customControllerClass = NECallCustomController.class;

  NSMutableDictionary *cusstomDic = [[NSMutableDictionary alloc] init];
  [cusstomDic setObject:CustomVideoCallingController.class forKey:kVideoCalling];
  [[NERtcCallUIKit sharedInstance] setCustomCallClass:cusstomDic];

  GroupConfigParam *param = [[GroupConfigParam alloc] init];
  param.appid = kAppKey;
  param.rtcSafeMode = YES;
  [[NEGroupCallKit sharedInstance] setupGroupCall:param];
}

- (void)didCallComingWithInviteInfo:(NEInviteInfo *)inviteInfo
                      withCallParam:(NEUICallParam *)callParam
                     withCompletion:(void (^)(BOOL))completion {
  callParam.remoteDefaultImage = [[SettingManager shareInstance] remoteDefaultImage];
  callParam.muteDefaultImage = [[SettingManager shareInstance] muteDefaultImage];
  completion(YES);
}

- (void)inviteUsersWithCallId:(NSString *)callId
                  inCallUsers:(NSArray<NSString *> *)inCallUsers
                   completion:(void (^)(NSArray<NSString *> *_Nullable users))completion {

  // 创建群组联系人控制器
  NEGroupContactsController *group = [[NEGroupContactsController alloc] init];
  group.isInvite = YES;

  // 将用户ID字符串转换为 NEUser 并添加到 inCallUserDic
  for (NSString *userId in inCallUsers) {
    // 这里需要根据用户ID创建 NEUser 对象
    // 由于我们只有用户ID，可以创建一个基本的 NEUser 对象
    NEUser *neUser = [[NEUser alloc] init];
    neUser.imAccid = userId;
    neUser.mobile = @"";  // 需要后续获取
    neUser.avatar = @"";  // 需要后续获取
    [group.inCallUserDic setObject:neUser forKey:userId];
  }
  group.totalCount = GroupCallUserLimit - inCallUsers.count;
  group.hasJoinCount = inCallUsers.count;

  // 设置完成回调
  __weak typeof(self) weakSelf = self;
  group.completion = ^(NSArray<NEUser *> *_Nonnull users) {
    // 将 NEUser 转换为用户ID字符串
    NSMutableArray<NSString *> *userIds = [[NSMutableArray alloc] init];
    for (NEUser *user in users) {
      if (user.imAccid.length > 0) {
        [userIds addObject:user.imAccid];
      }
    }

    // 回调给调用方，返回用户ID字符串数组
    if (completion) {
      completion([userIds copy]);
    }
  };

  group.title = @"邀请";
  group.modalPresentationStyle = UIModalPresentationFullScreen;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:group];

  // 获取当前窗口并展示
  UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
  UIViewController *rootVC = keyWindow.rootViewController;

  if (!keyWindow) {
    keyWindow = self.window;
    rootVC = keyWindow.rootViewController;
  }

  if (rootVC) {
    UIViewController *presentedVC = rootVC.presentedViewController;
    if (presentedVC) {
      [presentedVC presentViewController:nav animated:YES completion:nil];
    } else {
      [rootVC presentViewController:nav
                          animated:YES
                        completion:^{
                           }];
    }
  }
}



- (void)registerAPNS {
  // 1.申请权限
  if (@available(iOS 10.0, *)) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [[UNUserNotificationCenter currentNotificationCenter]
        requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound |
                                        UNAuthorizationOptionAlert
                      completionHandler:^(BOOL granted, NSError *_Nullable error) {
                        if (!granted) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                            [UIApplication.sharedApplication.keyWindow
                                ne_makeToast:@"请到设置中开启推送功能"];
                          });
                        }
                      }];
  } else {
    UIUserNotificationType types =
        UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
  }
  // 2.注册通知
  [[UIApplication sharedApplication] registerForRemoteNotifications];
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

// 3.APNS注册回调
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [[NERtcCallKit sharedInstance] updateApnsToken:deviceToken];
  [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:deviceTokenKey];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  [self.window ne_makeToast:[NSString stringWithFormat:@"注册devicetoken失败，Error%@", error]];
}

// 在后收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  completionHandler();
}
// 低于iOS 10.0
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application
    didReceiveLocalNotification:(UILocalNotification *)notification {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - PushKit
- (void)registerPushKit{
  self.pushRegistry = [[PKPushRegistry alloc]
      initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];

  self.pushRegistry.delegate = self;
  self.pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

#pragma mark - PKPushRegistryDelegate
- (void)pushRegistry:(PKPushRegistry *)registry
    didUpdatePushCredentials:(PKPushCredentials *)credentials
                     forType:(PKPushType)type {
  if ([credentials.token length] == 0) {
    NSLog(@"voip token NULL");
    return;
  }

  [[NIMSDK sharedSDK] updatePushKitToken:credentials.token];
  [[NSUserDefaults standardUserDefaults] setObject:credentials.token forKey:pushKitDeviceTokenKey];

}

- (void)pushRegistry:(PKPushRegistry *)registry
    didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
                              forType:(PKPushType)type
                withCompletionHandler:(void (^)(void))completion {
  NSDictionary *dictionaryPayload = payload.dictionaryPayload;
  // 判断是否是云信发的payload
  if (![dictionaryPayload objectForKey:@"nim"]) {
    NSLog(@"not found nim payload");
    return;
  }

  if (@available(iOS 17.4, *)) {
    NECallSystemIncomingCallParam *param = [[NECallSystemIncomingCallParam alloc] init];
    param.payload = dictionaryPayload;
    param.ringtoneName = @"avchat_ring.mp3";

    [[NECallEngine sharedInstance] reportIncomingCallWithParam:param
        acceptCompletion:^(NSError *_Nullable error, NECallInfo *_Nullable callInfo) {
          if (error) {
            NSLog(@"lck accept failed %@", error);
          } else {
            NSLog(@"lck accept success %@", error);
          }
        }
        hangupCompletion:^(NSError *_Nullable error) {
          if (error) {
            NSLog(@"lck hangup error %@", error);
          } else {
            NSLog(@"lck hangup success");
          }
        }
        muteCompletion:^(NSError *_Nullable error, BOOL mute) {
          if (error) {
            NSLog(@"lck mute error %@", error);
          } else {
            NSLog(@"lck mute success %d", mute);
          }
        }];
  }

  completion();
}



@end
