//
//  AppDelegate.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/18.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "AppDelegate.h"
#import "NEMenuViewController.h"
//#import "NERtcVideoCall.h"
#import "NECallViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "NENavigator.h"
#import "NETokenTask.h"
#import "LocalServerManager.h"

@interface AppDelegate ()<NERtcCallKitDelegate,UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initWindow];
    [self setupSDK];
    [self registerAPNS];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf commonInit];
    });
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
    option.supportAutoJoinWhenCalled = YES;
    NERtcCallKit *callkit = [NERtcCallKit sharedInstance];
    [callkit setupAppKey:kAppKey options:option];
    callkit.tokenHandler = ^(uint64_t uid, void (^complete)(NSString *token, NSError *error)) {
        NETokenTask *task = [NETokenTask taskWithUid:[NSString stringWithFormat:@"%llu",uid] withAppkey:kAppKey];
        [task postWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (error == nil && data && [data isKindOfClass:[NSDictionary class]]) {
                NSNumber *code = data[@"code"];
                NSString *checksum = data[@"checksum"];
                if (code.intValue == 200 && checksum) {
                    complete(checksum,nil);
                    return;
                }
            }
            complete(nil,error);

        }];
    };
}

- (void)registerAPNS
{
    // 1.申请权限
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIApplication.sharedApplication.keyWindow makeToast:@"请到设置中开启推送功能"];
                });
                //[UIApplication.sharedApplication.keyWindow makeToast:@"请到设置中开启推送功能"];
            }
        }];
    } else {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    // 2.注册通知
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

// 3.APNS注册回调
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[NERtcCallKit sharedInstance] updateApnsToken:deviceToken];
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:deviceTokenKey];
//    [self.window makeToast:@"注册devicetoken成功"];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [self.window makeToast:[NSString stringWithFormat:@"注册devicetoken失败，Error%@",error]];
}

- (void)commonInit {
    [[LocalServerManager shareInstance] startServer];
}


// 4.接收通知
// iOS 10.0 在前台收到通知
//- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
//}

//在后收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler();
}
//低于iOS 10.0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

@end
