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

  @objc public static func register(with registrar: FlutterPluginRegistrar) {
    print("CallKitUIPlugin: register called")
    let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
    let instance = SwiftCallKitUIPlugin()
    instance.registrar = registrar
    registrar.addMethodCallDelegate(instance, channel: channel)

    // 设置 NEWindowManager 的 delegate
    NEWindowManager.instance.backToFlutterWidgetDelegate = instance

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
    result(true)
  }

  private func handleRequestPermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(true)
  }

  private func handleStartRing(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let filePath = args["filePath"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "filePath is required", details: nil))
      return
    }

    do {
      // 停止当前播放的铃声
      stopRing()

      // 配置音频会话
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
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
    stopRing()
    print("CallKitUIPlugin: Stopped ring tone")
    result(true)
  }

  private func stopRing() {
    audioPlayer?.stop()
    audioPlayer = nil

    // 恢复音频会话
    do {
      try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    } catch {
      print("CallKitUIPlugin: Failed to deactivate audio session - \(error)")
    }
  }

  // MARK: - FloatWindow Methods

  private func handleStartFloatWindow(result: @escaping FlutterResult) {
    print("CallKitUIPlugin: Starting float window")

    NEWindowManager.instance.showFloatWindow()
    print("CallKitUIPlugin: Float window started")
    result(true)
  }

  private func handleStopFloatWindow(result: @escaping FlutterResult) {
    print("CallKitUIPlugin: Stopping float window")

    NEWindowManager.instance.closeFloatWindow()
    print("CallKitUIPlugin: Float window stopped")
    result(true)
  }

  private func handleHasFloatPermission(result: @escaping FlutterResult) {
    print("CallKitUIPlugin: Checking float permission")

    let hasPermission = true

    print("CallKitUIPlugin: Float permission check result: \(hasPermission)")
    result(hasPermission)
  }

  // MARK: - WakeLock Methods

  private func handleEnableWakeLock(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("CallKitUIPlugin: handleEnableWakeLock called")

    guard let args = call.arguments as? [String: Any],
          let enable = args["enable"] as? Bool else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "enable parameter is required", details: nil))
      return
    }

    if enable {
      enableWakeLock()
    } else {
      disableWakeLock()
    }

    print("CallKitUIPlugin: WakeLock \(enable ? "enabled" : "disabled")")
    result(true)
  }

  private func enableWakeLock() {
    UIApplication.shared.isIdleTimerDisabled = true
  }

  private func disableWakeLock() {
    UIApplication.shared.isIdleTimerDisabled = false
  }

  // MARK: - UpdateCallStateToNative Methods

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

  func launchCallingPageFromIncomingBanner() {
    print("CallKitUIPlugin: launchCallingPageFromIncomingBanner called")
    // 调用 Flutter 端的 launchCallingPageFromIncomingBanner 方法
    if let registrar = registrar {
      let channel = FlutterMethodChannel(name: "call_kit_ui", binaryMessenger: registrar.messenger())
      channel.invokeMethod("launchCallingPageFromIncomingBanner", arguments: nil)
    }
  }
}
