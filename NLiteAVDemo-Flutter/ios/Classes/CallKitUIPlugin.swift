// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import NERtcCallKit
import UIKit

@objc public class SwiftCallKitUIPlugin: NSObject, FlutterPlugin, NEBackToFlutterWidgetDelegate {
  private var audioPlayer: AVAudioPlayer?
  private var registrar: FlutterPluginRegistrar?

  /// 是否处于 Incoming 状态（内存存储）
  private var lckIsInIncomingState: Bool = false

  /// 当前通话状态
  private var currentCallStatus: NECallStatus = .none

  @objc public static func register(with registrar: FlutterPluginRegistrar) {
    print("CallKitUIPlugin: register called")
    let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
    let instance = SwiftCallKitUIPlugin()
    instance.registrar = registrar
    registrar.addMethodCallDelegate(instance, channel: channel)

    // 设置 NEWindowManager 的 delegate
    NEWindowManager.instance.backToFlutterWidgetDelegate = instance

    // 开始监听 Live Communication Kit 状态变化
    instance.startListeningToIncomingState()

    // 开始监听通话状态变化
    instance.registerObserveCallStatus()

    print("CallKitUIPlugin: register completed")
  }

  @objc public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("CallKitUIPlugin: handle method called - \(call.method)")
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "startForegroundService":
      handleStartForegroundService(result: result)
    case "stopForegroundService":
      handleStopForegroundService(result: result)
    case "startRing":
      handleStartRing(call, result: result)
    case "stopRing":
      handleStopRing(result: result)
    case "startFloatWindow":
      handleStartFloatWindow(result: result)
    case "stopFloatWindow":
      handleStopFloatWindow(result: result)
    case "hasFloatPermission":
      handleHasFloatPermission(result: result)
    case "hasPermissions":
      handleHasPermissions(call, result: result)
    case "requestPermissions":
      handleRequestPermissions(call, result: result)
    case "enableWakeLock":
      handleEnableWakeLock(call, result: result)
    case "updateCallStateToNative":
      handleUpdateCallStateToNative(call, result: result)
    default:
      print("CallKitUIPlugin: method not implemented - \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Foreground Service Methods

  private func handleStartForegroundService(result: @escaping FlutterResult) {
    result(true)
  }

  private func handleStopForegroundService(result: @escaping FlutterResult) {
    result(true)
  }

  // MARK: - Permission Methods

  private func handleHasPermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let permissionNumbers = args["permission"] as? [NSNumber] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "permission parameter is required", details: nil))
      return
    }

    // 将 NSNumber 数组转换为字符串数组
    let permissions = permissionNumbers.compactMap { number -> String? in
      switch number.intValue {
      case 0:
        return "camera"
      case 1:
        return "microphone"
      case 2:
        return "bluetooth"
      default:
        return nil
      }
    }

    let hasAllPermissions = PermissionManager.shared.checkAllPermissions(permissions: permissions)
    result(hasAllPermissions)
  }

  private func handleRequestPermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let permissionNumbers = args["permission"] as? [NSNumber] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "permission parameter is required", details: nil))
      return
    }

    // 将 NSNumber 数组转换为字符串数组
    let permissions = permissionNumbers.compactMap { number -> String? in
      switch number.intValue {
      case 0:
        return "camera"
      case 1:
        return "microphone"
      case 2:
        return "bluetooth"
      default:
        return nil
      }
    }

    let title = args["title"] as? String ?? ""
    let description = args["description"] as? String ?? ""
    let settingsTip = args["settingsTip"] as? String ?? ""

    PermissionManager.shared.requestPermissions(permissions: permissions, title: title, description: description, settingsTip: settingsTip) { permissionResult in
      result(permissionResult.rawValue)
    }
  }

  // MARK: - Wake Lock Methods

  private func handleEnableWakeLock(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let enable = args["enable"] as? Bool else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "enable parameter is required", details: nil))
      return
    }

    if enable {
      UIApplication.shared.isIdleTimerDisabled = true
      print("CallKitUIPlugin: Wake lock enabled")
    } else {
      UIApplication.shared.isIdleTimerDisabled = false
      print("CallKitUIPlugin: Wake lock disabled")
    }

    result(true)
  }

  // MARK: - Float Window Methods

  private func handleStartFloatWindow(result: @escaping FlutterResult) {
    print("CallKitUIPlugin: startFloatWindow called")
    NEWindowManager.instance.showFloatWindow()
    result(true)
  }

  private func handleStopFloatWindow(result: @escaping FlutterResult) {
    print("CallKitUIPlugin: stopFloatWindow called")
    NEWindowManager.instance.closeFloatWindow()
    result(true)
  }

  private func handleHasFloatPermission(result: @escaping FlutterResult) {
    result(true)
  }

  // MARK: - Ring Methods

  private func handleStartRing(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let filePath = args["filePath"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "filePath is required", details: nil))
      return
    }

    // 如果处于 Incoming 状态，直接返回，此时使用lck自带铃声，不需要额外播放铃声
    if lckIsInIncomingState {
      print("CallKitUIPlugin: Skipping startRing because in incoming state")
      result(true)
      return
    }

    stopRing()

    if NECallState.instance.selfUser.value.callRole == NECallRole.called {
      CallingVibrator.startVibration()
    }

    do {
      // 配置音频会话
      try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
      try AVAudioSession.sharedInstance().setActive(true)

      // 创建音频播放器
      let url = URL(fileURLWithPath: filePath)
      audioPlayer = try AVAudioPlayer(contentsOf: url)
      audioPlayer?.numberOfLoops = -1 // 无限循环
      audioPlayer?.volume = 1.0
      audioPlayer?.play()

      print("CallKitUIPlugin: Started playing ring tone from \(filePath)")
      result(true)
    } catch {
      print("CallKitUIPlugin: Failed to start ring tone - \(error)")
      result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to start ring tone", details: error.localizedDescription))
    }
  }

  private func handleStopRing(result: @escaping FlutterResult) {
    print("CallKitUIPlugin: stopRing called")
    stopRing()
    result(true)
  }

  private func stopRing() {
    if NECallState.instance.selfUser.value.callRole == NECallRole.called {
      CallingVibrator.stopVirbration()
    }

    audioPlayer?.stop()
    audioPlayer = nil

    // 恢复音频会话
    do {
      try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
      print("CallKitUIPlugin: Failed to deactivate audio session - \(error)")
    }
  }

  // MARK: - Call State Methods

  private func handleUpdateCallStateToNative(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("CallKitUIPlugin: Updating call state to native")

    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    parseAndUpdateCallState(args)
    print("CallKitUIPlugin: Call state updated successfully")
    result(true)
  }

  private func parseAndUpdateCallState(_ args: [String: Any]) {
    // 解析 selfUser
    if let selfUserData = args["selfUser"] as? [String: Any] {
      let selfUser = NECallUser()
      selfUser.id = selfUserData["id"] as? String ?? ""
      selfUser.avatar = selfUserData["avatar"] as? String ?? ""
      selfUser.nickname = selfUserData["nickname"] as? String ?? ""
      selfUser.callRole = NECallRole(rawValue: selfUserData["callRole"] as? Int ?? 0) ?? .none
      selfUser.callStatus = NECallStatus(rawValue: selfUserData["callStatus"] as? Int ?? 0) ?? .none
      selfUser.audioAvailable = selfUserData["audioAvailable"] as? Bool ?? false
      selfUser.videoAvailable = selfUserData["videoAvailable"] as? Bool ?? false
      selfUser.playOutVolume = selfUserData["playOutVolume"] as? Int ?? 0
      selfUser.viewID = selfUserData["viewID"] as? Int ?? 0

      NECallState.instance.selfUser.value = selfUser
      print("CallKitUIPlugin: Self user updated - id: \(selfUser.id), status: \(selfUser.callStatus)")
    }

    // 解析 remoteUserList，如果存在且不为空，取第一个元素赋值给 remoteUser
    if let remoteUserList = args["remoteUserList"] as? [[String: Any]], !remoteUserList.isEmpty {
      let firstRemoteUserData = remoteUserList[0]
      let remoteUser = NECallUser()
      remoteUser.id = firstRemoteUserData["id"] as? String ?? ""
      remoteUser.avatar = firstRemoteUserData["avatar"] as? String ?? ""
      remoteUser.nickname = firstRemoteUserData["nickname"] as? String ?? ""
      remoteUser.callRole = NECallRole(rawValue: firstRemoteUserData["callRole"] as? Int ?? 0) ?? .none
      remoteUser.callStatus = NECallStatus(rawValue: firstRemoteUserData["callStatus"] as? Int ?? 0) ?? .none
      remoteUser.audioAvailable = firstRemoteUserData["audioAvailable"] as? Bool ?? false
      remoteUser.videoAvailable = firstRemoteUserData["videoAvailable"] as? Bool ?? false
      remoteUser.playOutVolume = firstRemoteUserData["playOutVolume"] as? Int ?? 0
      remoteUser.viewID = firstRemoteUserData["viewID"] as? Int ?? 0

      NECallState.instance.remoteUser.value = remoteUser
      print("CallKitUIPlugin: Remote user updated - id: \(remoteUser.id), status: \(remoteUser.callStatus)")
    }

    if let mediaTypeIndex = args["mediaType"] as? Int {
      let mediaType = NECallType(rawValue: UInt(mediaTypeIndex))
      NECallState.instance.mediaType.value = mediaType
    }

    if let startTimeValue = args["startTime"] as? Int {
      NECallState.instance.startTime = startTimeValue
    }

    if let isCameraOpenValue = args["isCameraOpen"] as? Bool {
      NECallState.instance.isCameraOpen.value = isCameraOpenValue
    }

    if let isMicrophoneMuteValue = args["isMicrophoneMute"] as? Bool {
      NECallState.instance.isMicrophoneMute.value = isMicrophoneMuteValue
    }

    print("CallKitUIPlugin: Call state updated - mediaType: \(NECallState.instance.mediaType.value), isCameraOpen: \(NECallState.instance.isCameraOpen.value), isMicrophoneMute: \(NECallState.instance.isMicrophoneMute.value)")
  }

  @objc public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    stopRing() // 停止铃声播放
    stopListeningToIncomingState() // 停止监听状态变化
    unregisterObserveCallStatus() // 取消注册通话状态监听
  }

  // MARK: - Live Communication Kit State Monitoring

  /// 开始监听 Live Communication Kit 的 Incoming 状态变化
  private func startListeningToIncomingState() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleIncomingStateChanged(_:)),
      name: NSNotification.Name("NELiveCommunicationKitIncomingStateChanged"),
      object: nil
    )
    print("CallKitUIPlugin: Started listening to Live Communication Kit state changes")
  }

  /// 停止监听 Live Communication Kit 的 Incoming 状态变化
  private func stopListeningToIncomingState() {
    NotificationCenter.default.removeObserver(self)
    print("CallKitUIPlugin: Stopped listening to Live Communication Kit state changes")
  }

  /// 处理 Incoming 状态变化
  @objc private func handleIncomingStateChanged(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let lckIsInIncomingState = userInfo["lckIsInIncomingState"] as? Bool else {
      return
    }

    print("CallKitUIPlugin: Live Communication Kit incoming state changed to \(lckIsInIncomingState)")

    // 更新本地状态
    self.lckIsInIncomingState = lckIsInIncomingState

    // 根据状态执行相应操作
    if lckIsInIncomingState {
      handleLckEnterIncomingState()
    } else {
      handleLckExitIncomingState()
    }
  }

  /// 处理进入 LCK Incoming 状态
  private func handleLckEnterIncomingState() {
    print("CallKitUIPlugin: Entered Live Communication Kit incoming state")
    // 停止铃声播放
    stopRing()
  }

  /// 处理退出 LCK Incoming 状态
  private func handleLckExitIncomingState() {
    print("CallKitUIPlugin: Exited Live Communication Kit incoming state")
  }

  // MARK: - Call Status Monitoring

  /// 注册监听通话状态变化
  private func registerObserveCallStatus() {
    // 监听 selfUser 的变化
    NECallState.instance.selfUser.addObserver(self, options: [.new]) { [weak self] newUser, _ in
      guard let self = self else { return }

      // 检查通话状态变化
      if self.currentCallStatus == newUser.callStatus { return }
      let oldStatus = self.currentCallStatus
      self.currentCallStatus = newUser.callStatus

      print("CallKitUIPlugin: Call status changed from \(oldStatus) to \(newUser.callStatus)")

      // 根据状态变化执行相应操作
      self.handleCallStatusChanged(from: oldStatus, to: newUser.callStatus)
    }
  }

  /// 取消注册通话状态监听
  private func unregisterObserveCallStatus() {
    NECallState.instance.selfUser.removeObserver(self)
  }

  /// 处理通话状态变化
  private func handleCallStatusChanged(from oldStatus: NECallStatus, to newStatus: NECallStatus) {
    // 只要不是 waiting 状态，就设置 lckIsInIncomingState 为 false
    if newStatus != .waiting {
      print("CallKitUIPlugin: Live Communication Kit incoming state changed to false")
      lckIsInIncomingState = false
    }
  }
}

extension SwiftCallKitUIPlugin {
  func backCallingPageFromFloatWindow() {
    print("CallKitUIPlugin: backCallingPageFromFloatWindow called")
    // 调用 Flutter 端的 backCallingPageFromFloatWindow 方法
    if let registrar = registrar {
      let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
      channel.invokeMethod("backCallingPageFromFloatWindow", arguments: nil)
    }
  }
}
