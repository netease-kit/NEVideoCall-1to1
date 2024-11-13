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

@interface AppDelegate () <NERtcCallKitDelegate,
                           UNUserNotificationCenterDelegate,
                           NIMSDKConfigDelegate,
                           NECallUIKitDelegate>

@property(nonatomic, strong) NSDictionary *blockDictionary;
@property(nonatomic, strong) NSTimer *timer;

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self initWindow];
  [self setupSDK];
  [self registerAPNS];
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

@end
