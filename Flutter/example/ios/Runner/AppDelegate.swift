// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import Flutter
import NIMSDK
import NERtcCallKit
import PushKit
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerAPNS()
//      if #available(iOS 17.4, *) {
//          registerPushKit()
//      }
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
    
  func registerPushKit() {
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.global(qos: .default))
    pushRegistry.delegate = self
    pushRegistry.desiredPushTypes = [.voIP]
  }

  // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        if pushCredentials.token.isEmpty {
            print("voip token isEmpty")
            return
        }
        
        NIMSDK.shared().updatePushKitToken(pushCredentials.token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // 判断是否是云信发的payload
        if payload.dictionaryPayload["nim"] == nil {
            print("not found nim payload")
            return
        }
        
        let param = NECallSystemIncomingCallParam()
        param.payload = payload.dictionaryPayload
        
        if #available(iOS 17.4, *) {
            NECallEngine.sharedInstance().reportIncomingCall(with: param) { error, callInfo in
                if let err = error {
                    print("lck accept failed \(err.localizedDescription)")
                }
            } hangupCompletion: { error in
                if let err = error {
                    print("lck hangup error \(err.localizedDescription)")
                }
            } muteCompletion: { error, mute in
                if let err = error {
                    print("lck mute error \(err.localizedDescription)")
                }
            }
        }

        completion();
    }
}



