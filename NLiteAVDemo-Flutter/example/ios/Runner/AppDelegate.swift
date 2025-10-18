// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import Flutter
import NIMSDK
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerAPNS()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  /// 远端推送
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("app delegate register apns: \(deviceToken)")
    NIMSDK.shared().updateApnsToken(deviceToken)
  }
    
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("app delegate register apns failed : \(error.localizedDescription)")
  }

  func registerAPNS() {
    if #available(iOS 10.0, *) {
      let center = UNUserNotificationCenter.current()
      center.delegate = self
      
      center.requestAuthorization(options: [.badge, .sound, .alert]) { grant, error in
        // 处理授权结果
      }
    } else {
      let setting = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(setting)
    }
    UIApplication.shared.registerForRemoteNotifications()
    UIApplication.shared.applicationIconBadgeNumber = 0
  }
}



