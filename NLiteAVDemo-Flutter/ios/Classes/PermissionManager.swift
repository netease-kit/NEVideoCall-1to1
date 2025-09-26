// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFoundation
import CoreBluetooth
import Flutter
import Photos
import UIKit

// MARK: - Permission Manager

@objc public class PermissionManager: NSObject {
  static let shared = PermissionManager()

  override private init() {
    super.init()
  }

  // MARK: - Public Methods

  func checkAllPermissions(permissions: [String]) -> Bool {
    for permission in permissions {
      if !checkPermission(permission: permission) {
        return false
      }
    }
    return true
  }

  func requestPermissions(permissions: [String], title: String, description: String, settingsTip: String, completion: @escaping (PermissionResult) -> Void) {
    let group = DispatchGroup()
    var allGranted = true
    var hasDenied = false
    var deniedPermission: String?

    // 优先检测麦克风权限
    let sortedPermissions = permissions.sorted { permission1, permission2 in
      if permission1 == "microphone", permission2 == "camera" {
        return true // 麦克风优先
      } else if permission1 == "camera", permission2 == "microphone" {
        return false
      }
      return false
    }

    for permission in sortedPermissions {
      group.enter()
      requestPermission(permission: permission) { granted in
        if !granted {
          allGranted = false
          if self.checkPermissionStatus(permission: permission) == .denied {
            hasDenied = true
            // 只记录第一个被拒绝的权限（优先麦克风）
            if deniedPermission == nil {
              deniedPermission = permission
            }
          }
        }
        group.leave()
      }
    }

    group.notify(queue: .main) {
      if allGranted {
        completion(.granted)
      } else if hasDenied {
        // 权限被拒绝，显示提示框
        self.showPermissionDeniedAlert(deniedPermission: deniedPermission) { result in
          completion(result)
        }
      } else {
        completion(.requesting)
      }
    }
  }

  // MARK: - Private Methods

  private func checkPermission(permission: String) -> Bool {
    switch permission {
    case "camera":
      return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    case "microphone":
      return AVAudioSession.sharedInstance().recordPermission == .granted
    case "bluetooth":
      return true // 蓝牙权限直接返回 true
    default:
      return false
    }
  }

  private func requestPermission(permission: String, completion: @escaping (Bool) -> Void) {
    switch permission {
    case "camera":
      requestCameraPermission(completion: completion)
    case "microphone":
      requestMicrophonePermission(completion: completion)
    case "bluetooth":
      // 蓝牙权限直接返回 true
      completion(true)
    default:
      completion(false)
    }
  }

  private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
    case .authorized:
      completion(true)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    case .denied, .restricted:
      completion(false)
    @unknown default:
      completion(false)
    }
  }

  private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
    let status = AVAudioSession.sharedInstance().recordPermission
    switch status {
    case .granted:
      completion(true)
    case .undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    case .denied:
      completion(false)
    @unknown default:
      completion(false)
    }
  }

  private func checkPermissionStatus(permission: String) -> PermissionStatus {
    switch permission {
    case "camera":
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      switch status {
      case .authorized:
        return .granted
      case .denied, .restricted:
        return .denied
      case .notDetermined:
        return .notDetermined
      @unknown default:
        return .denied
      }
    case "microphone":
      let status = AVAudioSession.sharedInstance().recordPermission
      switch status {
      case .granted:
        return .granted
      case .denied:
        return .denied
      case .undetermined:
        return .notDetermined
      @unknown default:
        return .denied
      }
    case "bluetooth":
      return .granted // 蓝牙权限直接返回已授权
    default:
      return .denied
    }
  }

  // MARK: - Alert Methods

  private func showPermissionDeniedAlert(deniedPermission: String?, completion: @escaping (PermissionResult) -> Void) {
    DispatchQueue.main.async {
      // 根据被拒绝的权限类型生成相应的文案
      let (alertTitle, alertMessage) = self.generatePermissionAlertContent(deniedPermission: deniedPermission)

      let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

      // 取消按钮
      let cancelAction = UIAlertAction(title: "取消", style: .default) { _ in
        print("PermissionManager: User cancelled permission request")
        completion(.denied)
      }
      alert.addAction(cancelAction)

      // 前往设置按钮
      let settingsAction = UIAlertAction(title: "前往设置", style: .default) { _ in
        print("PermissionManager: User chose to go to settings")
        self.openAppSettings()
        completion(.denied)
      }
      alert.addAction(settingsAction)

      // 显示提示框
      if let rootViewController = self.getRootViewController() {
        rootViewController.present(alert, animated: true, completion: nil)
      } else {
        print("PermissionManager: Could not find root view controller to present alert")
        completion(.denied)
      }
    }
  }

  private func generatePermissionAlertContent(deniedPermission: String?) -> (title: String, message: String) {
    guard let permission = deniedPermission else {
      // 默认文案
      return ("权限申请", "需要访问您的麦克风和摄像头权限,开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。")
    }

    switch permission {
    case "microphone":
      // 没有麦克风权限
      return ("无法使用麦克风", "请在iPhone的\"设置—隐私—麦克风\"中允许应用访问您的麦克风。")
    case "camera":
      // 没有摄像头权限
      return ("无法使用相机", "请在iPhone的\"设置—隐私—相机\"中允许应用访问您的相机。")
    default:
      // 默认文案
      return ("权限申请", "需要访问您的麦克风和摄像头权限,开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。")
    }
  }

  private func openAppSettings() {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
      print("PermissionManager: Could not create settings URL")
      return
    }

    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl, options: [:]) { success in
        print("PermissionManager: Settings opened successfully: \(success)")
      }
    } else {
      print("PermissionManager: Cannot open settings URL")
    }
  }

  private func getRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {
      return nil
    }

    return window.rootViewController
  }
}

// MARK: - Enums

private enum PermissionStatus {
  case granted
  case denied
  case notDetermined
}

@objc public enum PermissionResult: Int {
  case granted = 0
  case denied = 1
  case requesting = 2
}
