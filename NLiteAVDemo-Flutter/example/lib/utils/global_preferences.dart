// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

class GlobalPreferences {
  static const String _keyLoginInfo = 'login_info';

  static GlobalPreferences? _instance;
  SharedPreferences? _prefs;

  factory GlobalPreferences() => _instance ??= GlobalPreferences._internal();

  GlobalPreferences._internal();

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  Future<String?> get loginInfo async {
    await _ensureInitialized();
    return _prefs?.getString(_keyLoginInfo);
  }

  Future<void> setLoginInfo(String loginInfo) async {
    await _ensureInitialized();
    await _prefs?.setString(_keyLoginInfo, loginInfo);
  }
}
