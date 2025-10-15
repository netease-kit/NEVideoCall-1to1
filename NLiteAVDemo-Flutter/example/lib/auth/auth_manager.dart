// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'package:callkit_example/auth/login_page.dart';
import 'package:callkit_example/config/app_config.dart';
import 'package:callkit_example/settings/settings_config.dart';
import 'package:flutter/material.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:nim_core_v2/nim_core.dart';
import '../utils/global_preferences.dart';
import '../auth/auth_state.dart';
import 'login_info.dart';
import 'package:netease_callkit/netease_callkit.dart';

class AuthManager {
  static const String _tag = 'AuthManager';

  factory AuthManager() => _instance ??= AuthManager._internal();

  static AuthManager? _instance;
  LoginInfo? _loginInfo;

  final StreamController<LoginInfo?> _authInfoChanged =
      StreamController.broadcast();

  AuthManager._internal();

  Future<void> init() async {
    var loginInfo = await GlobalPreferences().loginInfo;
    if (loginInfo == null || loginInfo.isEmpty) return;

    try {
      final cachedLoginInfo =
          LoginInfo.fromJson(jsonDecode(loginInfo) as Map<String, dynamic>);
      _authInfoChanged.add(cachedLoginInfo);
      _loginInfo = cachedLoginInfo;

      AuthStateManager().updateState(state: AuthState.init);
    } catch (e) {
      print('LoginInfo.fromJson exception = $e');
    }
  }

  String? get accountId => _loginInfo?.accountId;
  String? get nickName => _loginInfo?.nickname;
  String? get accountToken => _loginInfo?.accountToken;
  String? get avatar => _loginInfo?.avatar;

  Future<bool> autoLogin() async {
    if (_loginInfo == null || _loginInfo!.accountId.isEmpty) {
      return Future.value(false);
    }

    if (isLogined()) {
      print('autoLogin but isLogined, using cached login info');
      return Future.value(true);
    }

    AuthStateManager().updateState(state: AuthState.init);
    var result = await loginCallKitWithToken(_loginInfo!);
    return Future.value(result.code == 0);
  }

  Future<NEResult> loginCallKitWithToken(LoginInfo loginInfo) async {
    var completer = Completer<NEResult>();

    // 创建证书配置
    final certificateConfig = NECertificateConfig(
      apnsCername: AppConfig().pushCerName,
      pkCername: AppConfig().voipCerName,
    );

    final extraConfig = NEExtraConfig(
      lckConfig: NELCKConfig(
        enableLiveCommunicationKit: true,
        ringtoneName: 'avchat_ring.mp3',
      ),
    );

    NimCore.instance.loginService.onKickedOffline.listen((event) {
      // 被踢下线处理
      print('$_tag: 用户被踢下线');
      kickedOffline('账号在其他设备登录');
    });

    NECallKitUI.instance.enableFloatWindow(SettingsConfig.enableFloatWindow);
    NECallKitUI.instance
        .enableIncomingBanner(SettingsConfig.showIncomingBanner);
    NECallKitUI.instance
        .login(AppConfig().appKey, loginInfo.accountId, loginInfo.accountToken,
            certificateConfig: certificateConfig, extraConfig: extraConfig)
        .then((value) {
      if (value.code == 0) {
        AuthStateManager().updateState(state: AuthState.authed);
        _syncAuthInfo(loginInfo);
      }
      return completer
          .complete(NEResult(code: value.code, message: value.message ?? ''));
    });
    return completer.future;
  }

  void _syncAuthInfo(LoginInfo loginInfo) {
    _loginInfo = loginInfo;
    GlobalPreferences().setLoginInfo(jsonEncode(loginInfo.toJson()));
    _authInfoChanged.add(loginInfo);
  }

  void logout() {
    NECallKitUI.instance.logout();
    _loginInfo = null;
    GlobalPreferences().setLoginInfo('{}');
    _authInfoChanged.add(_loginInfo);
    AuthStateManager().updateState(state: AuthState.init);
  }

  Stream<LoginInfo?> authInfoStream() {
    return _authInfoChanged.stream;
  }

  void tokenIllegal(String errorTip) {
    logout();
    AuthStateManager()
        .updateState(state: AuthState.tokenIllegal, errorTip: errorTip);
  }

  void kickedOffline(String reason) {
    print('$_tag: 处理被踢下线，原因: $reason');
    // 清理登录信息
    logout();
    // 更新状态为被踢下线
    AuthStateManager().updateState(state: AuthState.kicked, errorTip: reason);
    NECallKitUI.navigatorObserver.navigator?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (widget) {
      return const LoginRoute();
    }), (route) => false);
  }

  bool isLogined() {
    return AuthStateManager().state == AuthState.authed;
  }
}
