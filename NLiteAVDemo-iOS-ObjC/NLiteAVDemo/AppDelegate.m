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

- (void)setupSDK {

  NIMSDKOption *option = [NIMSDKOption optionWithAppKey:kAppKey];
  option.apnsCername = kAPNSCerName;
  [NIMSDK.sharedSDK registerWithOption:option];

  NESetupConfig *setupConfig = [[NESetupConfig alloc] initWithAppkey:kAppKey];
  [[NECallEngine sharedInstance] setup:setupConfig];
  [[NECallEngine sharedInstance] setTimeout:30];

  NECallUIKitConfig *config = [[NECallUIKitConfig alloc] init];
  config.uiConfig.showCallingSwitchCallType = YES;
  config.uiConfig.enableVideoToAudio = YES;
  config.uiConfig.enableAudioToVideo = YES;
    config.uiConfig.enableFloatingWindow = YES;
    config.uiConfig.enableFloatingWindowOutOfApp = YES;
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
                          //[UIApplication.sharedApplication.keyWindow
                          // ne_makeToast:@"请到设置中开启推送功能"];
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
  //    [self.window ne_makeToast:@"注册devicetoken成功"];
}
- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  [self.window ne_makeToast:[NSString stringWithFormat:@"注册devicetoken失败，Error%@", error]];
}

// 4.接收通知
// iOS 10.0 在前台收到通知
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center
// willPresentNotification:(UNNotification *)notification withCompletionHandler:(void
//(^)(UNNotificationPresentationOptions options))completionHandler {
//}

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
