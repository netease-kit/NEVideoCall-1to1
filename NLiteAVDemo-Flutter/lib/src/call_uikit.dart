// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/l10n/l10n.dart';
import 'package:netease_callkit_ui/l10n/call_ui_localization/call_ui_localizations.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/ui/call_navigator_observer.dart';

class NECallKitUI {
  static const String _tag = 'NECallKitUI';
  static final NECallKitUI _instance = NECallKitUI();

  static get delegate {
    return S.delegate;
  }

  static CallKitClientLocalizations get localizations {
    return S.of();
  }

  static NECallKitUI get instance => _instance;

  static NECallKitNavigatorObserver navigatorObserver =
      NECallKitNavigatorObserver.getInstance();

  /// init NECallKit
  ///
  /// @param appKey      appKey
  /// @param accountId      accountId
  Future<void> setupEngine(String appKey, String accountId,
      {NEExtraConfig? extraConfig}) async {
    return await CallManager.instance
        .setupEngine(appKey, accountId, extraConfig: extraConfig);
  }

  /// release NECallKit
  void releaseEngine() {
    CallManager.instance.releaseEngine();
  }

  /// login NECallKit
  ///
  /// @param appKey      appKey
  /// @param accountId   accountId
  /// @param token       token
  /// @param certificateConfig 证书配置参数
  /// @param extraConfig 额外配置参数，包含 lckConfig 等
  Future<NEResult> login(String appKey, String accountId, String token,
      {NECertificateConfig? certificateConfig,
      NEExtraConfig? extraConfig}) async {
    return await CallManager.instance.login(appKey, accountId, token,
        certificateConfig: certificateConfig, extraConfig: extraConfig);
  }

  /// logout NECallKit
  ///
  Future<void> logout() async {
    return await CallManager.instance.logout();
  }

  /// Set user profile
  ///
  /// @param nickname User name, which can contain up to 500 bytes
  /// @param avatar   User profile photo URL, which can contain up to 500 bytes
  ///                 For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
  /// @param callback Set the result callback
  Future<NEResult> setSelfInfo(String nickname, String avatar) async {
    return await CallManager.instance.setSelfInfo(nickname, avatar);
  }

  /// Make a call
  ///
  /// @param userId        callees
  /// @param callMediaType Call type
  Future<NEResult> call(String userId, NECallType callMediaType,
      [NECallParams? params]) async {
    return await CallManager.instance.call(userId, callMediaType, params);
  }

  /// Set the ringtone (preferably shorter than 30s)
  ///
  /// First introduce the ringtone resource into the project
  /// Then set the resource as a ringtone
  ///
  /// @param filePath Callee ringtone path
  Future<void> setCallingBell(String assetName) async {
    return await CallManager.instance.setCallingBell(assetName);
  }

  ///Enable the floating window
  Future<void> enableFloatWindow(bool enable) async {
    return await CallManager.instance.enableFloatWindow(enable);
  }

  Future<void> enableVirtualBackground(bool enable) async {
    return await CallManager.instance.enableVirtualBackground(enable);
  }

  void enableIncomingBanner(bool enable) {
    if (Platform.isAndroid) {
      CallManager.instance.enableIncomingBanner(enable);
    } else {
      CallKitUILog.e(_tag, 'CallManager enableIncomingBanner not support');
    }
  }
}
