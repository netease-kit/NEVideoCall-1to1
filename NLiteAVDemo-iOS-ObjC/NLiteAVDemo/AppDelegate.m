// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "AppDelegate.h"
#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import <NIMSDK/NIMSDK.h>
#import <UserNotifications/UserNotifications.h>
#import "CustomVideoCallingController.h"
#import "LocalServerManager.h"
#import "NEMenuViewController.h"
#import "NENavigator.h"
#import "NEPSTNViewController.h"
#import <NERtcCallUIKit/SettingManager.h>

@interface AppDelegate () <NERtcCallKitDelegate,
                           UNUserNotificationCenterDelegate,
                           NIMSDKConfigDelegate>

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
}

- (void)setupSDK {

  NERtcCallOptions *option = [NERtcCallOptions new];
  option.APNSCerName = kAPNSCerName;
  NERtcCallKit *callkit = [NERtcCallKit sharedInstance];
  [callkit setupAppKey:kAppKey options:option];
  [callkit setTimeOutSeconds:30];

  NERtcCallUIConfig *config = [[NERtcCallUIConfig alloc] init];
  [[NERtcCallUIKit sharedInstance] setupWithConfig:config];

  NSMutableDictionary *cusstomDic = [[NSMutableDictionary alloc] init];
  [cusstomDic setObject:CustomVideoCallingController.class forKey:kVideoCalling];
  [[NERtcCallUIKit sharedInstance] setCustomCallClass:cusstomDic];

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
                                makeToast:@"请到设置中开启推送功能"];
                          });
                          //[UIApplication.sharedApplication.keyWindow
                          // makeToast:@"请到设置中开启推送功能"];
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
  [self.window makeToast:[NSString stringWithFormat:@"注册devicetoken失败，Error%@", error]];
}

- (void)commonInit {
  [[LocalServerManager shareInstance] startServer];
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
