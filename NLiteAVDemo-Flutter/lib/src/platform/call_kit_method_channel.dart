// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/src/call_define.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/impl/call_manager.dart';
import 'package:netease_callkit_ui/src/impl/call_state.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';

class MethodChannelNECallKit extends NECallKitPlatform {
  MethodChannelNECallKit() {
    methodChannel.setMethodCallHandler((call) async {
      _handleNativeCall(call);
    });
  }

  @visibleForTesting
  final methodChannel = const MethodChannel('call_kit_ui');

  @override
  Future<void> startForegroundService(NECallType type) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel
          .invokeMethod('startForegroundService', {"mediaType": type.index});
    }
  }

  @override
  Future<void> stopForegroundService() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopForegroundService', {});
    }
  }

  @override
  Future<void> startRing(String filePath) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('startRing', {"filePath": filePath});
    }
  }

  @override
  Future<void> stopRing() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopRing', {});
    }
  }

  @override
  Future<void> updateCallStateToNative() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      List remoteUserList = [];
      for (var i = 0; i < CallState.instance.remoteUserList.length; ++i) {
        remoteUserList.add(CallState.instance.remoteUserList[i].toJson());
      }

      methodChannel.invokeMethod('updateCallStateToNative', {
        'selfUser': CallState.instance.selfUser.toJson(),
        'remoteUserList': remoteUserList.isNotEmpty ? remoteUserList : [],
        'scene': CallState.instance.scene.index,
        'mediaType': CallState.instance.mediaType.index,
        'startTime': CallState.instance.startTime,
        'camera': CallState.instance.camera.index,
        'isCameraOpen': CallState.instance.isCameraOpen,
        'isMicrophoneMute': CallState.instance.isMicrophoneMute,
      });
    }
  }

  @override
  Future<void> startFloatWindow() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('startFloatWindow', {});
    }
  }

  @override
  Future<void> stopFloatWindow() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopFloatWindow', {});
    }
  }

  @override
  Future<bool> hasFloatPermission() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return await methodChannel.invokeMethod('hasFloatPermission', {});
    } else {
      return false;
    }
  }

  @override
  Future<void> requestFloatPermission() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('requestFloatPermission', {});
    }
  }

  @override
  Future<bool> isAppInForeground() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return await methodChannel.invokeMethod('isAppInForeground', {});
    } else {
      return false;
    }
  }

  @override
  Future<bool> showIncomingBanner() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod('showIncomingBanner', {});
      } else {
        return false;
      }
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  Future<bool> initResources(Map resources) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel
            .invokeMethod('initResources', {"resources": resources});
      } else {
        return false;
      }
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  @override
  Future<void> openMicrophone() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('openMicrophone', {});
    }
  }

  @override
  Future<void> closeMicrophone() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('closeMicrophone', {});
    }
  }

  @override
  Future<bool> hasPermissions(
      {required List<PermissionType> permissions}) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      List<int> permissionsList = [];
      for (var element in permissions) {
        permissionsList.add(element.index);
      }
      return await methodChannel
          .invokeMethod('hasPermissions', {'permission': permissionsList});
    } else {
      return false;
    }
  }

  @override
  Future<PermissionResult> requestPermissions(
      {required List<PermissionType> permissions,
      String title = "",
      String description = "",
      String settingsTip = ""}) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        List<int> permissionsList = [];
        for (var element in permissions) {
          permissionsList.add(element.index);
        }
        int result = await methodChannel.invokeMethod('requestPermissions', {
          'permission': permissionsList,
          'title': title,
          'description': description,
          'settingsTip': settingsTip
        });
        if (result == PermissionResult.granted.index) {
          return PermissionResult.granted;
        } else if (result == PermissionResult.denied.index) {
          return PermissionResult.denied;
        } else {
          return PermissionResult.requesting;
        }
      } else {
        return PermissionResult.denied;
      }
    } on PlatformException catch (_) {
      return PermissionResult.denied;
    } on Exception catch (_) {
      return PermissionResult.denied;
    }
  }

  @override
  Future<void> pullBackgroundApp() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('pullBackgroundApp', {});
    }
  }

  @override
  Future<void> openLockScreenApp() async {
    if (!kIsWeb && Platform.isAndroid) {
      await methodChannel.invokeMethod('openLockScreenApp', {});
    }
  }

  @override
  Future<void> enableWakeLock(bool enable) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('enableWakeLock', {'enable': enable});
    }
  }

  @override
  Future<bool> isScreenLocked() async {
    if (!kIsWeb && (Platform.isAndroid)) {
      return await methodChannel.invokeMethod('isScreenLocked', {});
    }
    return false;
  }

  @override
  Future<bool> isSamsungDevice() async {
    if (!kIsWeb && Platform.isAndroid) {
      return await methodChannel.invokeMethod('isSamsungDevice', {});
    }
    return false;
  }

  void _handleNativeCall(MethodCall call) {
    debugPrint(
        "CallHandler method:${call.method}, arguments:${call.arguments}");
    switch (call.method) {
      case "backCallingPageFromFloatWindow":
        _backCallingPageFromFloatWindow();
        break;
      case "launchCallingPageFromIncomingBanner":
        _launchCallingPageFromIncomingBanner();
        break;
      case "appEnterForeground":
        _appEnterForeground();
        break;
      case "voipChangeMute":
        _handleVoipChangeMute(call);
        break;
      case "voipChangeAudioPlaybackDevice":
        _handleVoipChangeAudioPlaybackDevice(call);
        break;
      case "voipChangeHangup":
        _handleVoipHangup();
        break;
      case "voipChangeAccept":
        _handleVoipAccept();
        break;
      default:
        debugPrint("flutter: MethodNotImplemented ${call.method}");
        break;
    }
  }

  void _backCallingPageFromFloatWindow() {
    CallManager.instance.backCallingPageFormFloatWindow();
  }

  void _launchCallingPageFromIncomingBanner() {
    CallState.instance.isInNativeIncomingBanner = false;
    if (CallState.instance.selfUser.callStatus != NECallStatus.none) {
      CallManager.instance.launchCallingPage();
    }
  }

  void _appEnterForeground() {
    CallManager.instance.handleAppEnterForeground();
  }

  void _handleVoipChangeMute(MethodCall call) {
    if (CallState.instance.selfUser.callStatus != NECallStatus.none) {
      bool mute = call.arguments['mute'];
      CallState.instance.isMicrophoneMute = mute;
      mute
          ? CallManager.instance.closeMicrophone(false)
          : CallManager.instance.openMicrophone(false);
      NEEventNotify().notify(setStateEvent);
    }
  }

  void _handleVoipChangeAudioPlaybackDevice(MethodCall call) {
    // if (CallState.instance.selfUser.callStatus != NECallStatus.none) {
    //   CallState.instance.audioDevice = call.arguments['audioPlaybackDevice'];
    //   CallManager.instance
    //       .setSpeakerphoneOn(CallState.instance.audioDevice);
    //   INENotification().notify(setStateEvent);
    // }
  }

  void _handleVoipHangup() {
    if (CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      CallManager.instance.reject();
    } else if (CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      CallManager.instance.hangup();
    }
  }

  void _handleVoipAccept() {
    if (CallState.instance.selfUser.callStatus == NECallStatus.waiting) {
      CallManager.instance.accept();
    }
  }
}
