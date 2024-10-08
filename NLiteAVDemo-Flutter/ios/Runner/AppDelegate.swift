import UIKit
import Flutter
import NIMSDK
import NERtcCallKit
import NERtcCallUIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      NECallKitPlugin.register(with: registrar(forPlugin: "callkit")!)
      let appkey = "your appkey"
      let option = NIMSDKOption(appKey: appkey)
      NIMSDK.shared().register(with: option)
      
      let config = NESetupConfig()
      config.appkey = appkey
      let uiConfig = NECallUIKitConfig()
      uiConfig.config = config;
      NERtcCallKit.sharedInstance().timeOutSeconds = 30
      NERtcCallUIKit.sharedInstance().customControllerClass = NECallViewController.self
      NERtcCallUIKit.sharedInstance().setup(with: uiConfig)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  
}
