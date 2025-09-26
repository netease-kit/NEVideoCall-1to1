// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_callkit/netease_callkit.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_method_channel.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';

abstract class NECallKitPlatform extends PlatformInterface {
  NECallKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static NECallKitPlatform _instance = MethodChannelNECallKit();

  static NECallKitPlatform get instance => _instance;

  static set instance(NECallKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> startForegroundService(NECallType type) async {
    await instance.startForegroundService(type);
  }

  Future<void> stopForegroundService() async {
    await instance.stopForegroundService();
  }

  Future<void> startRing(String filePath) async {
    await instance.startRing(filePath);
  }

  Future<void> stopRing() async {
    await instance.stopRing();
  }

  Future<void> updateCallStateToNative() async {
    await instance.updateCallStateToNative();
  }

  Future<void> startFloatWindow() async {
    await instance.startFloatWindow();
  }

  Future<void> stopFloatWindow() async {
    await instance.stopFloatWindow();
  }

  Future<bool> hasFloatPermission() async {
    return await instance.hasFloatPermission();
  }

  Future<void> requestFloatPermission() async {
    await instance.requestFloatPermission();
  }

  Future<bool> isAppInForeground() async {
    return await instance.isAppInForeground();
  }

  Future<bool> showIncomingBanner() async {
    return await instance.showIncomingBanner();
  }

  Future<void> openMicrophone() async {
    await instance.openMicrophone();
  }

  Future<void> closeMicrophone() async {
    await instance.openMicrophone();
  }

  Future<bool> hasPermissions(
      {required List<PermissionType> permissions}) async {
    return await instance.hasPermissions(permissions: permissions);
  }

  Future<PermissionResult> requestPermissions(
      {required List<PermissionType> permissions,
      String title = "",
      String description = "",
      String settingsTip = ""}) async {
    return await instance.requestPermissions(
        permissions: permissions,
        title: title,
        description: description,
        settingsTip: settingsTip);
  }

  Future<void> pullBackgroundApp() async {
    await instance.pullBackgroundApp();
  }

  Future<void> openLockScreenApp() async {
    await instance.openLockScreenApp();
  }

  Future<void> enableWakeLock(bool enable) async {
    await instance.enableWakeLock(enable);
  }

  Future<bool> isScreenLocked() async {
    return await instance.isScreenLocked();
  }

  Future<bool> isSamsungDevice() async {
    return await instance.isSamsungDevice();
  }
}
