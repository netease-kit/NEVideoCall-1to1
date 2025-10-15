// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class AppConfig {
  factory AppConfig() => _instance ??= AppConfig._internal();

  static AppConfig? _instance;

  AppConfig._internal();
  // 请填写应用对应的 AppKey，可在云信控制台的”AppKey管理“页面获取
  static const String _appKey = 'your appKey';

  late String versionName = '1.0.0';

  late String versionCode = '1';

  String get appKey {
    return _appKey;
  }

  Future init() async {
    await loadPackageInfo();
    return Future.value();
  }

  Future<void> loadPackageInfo() async {
    // 简化版本，直接设置版本信息
    versionCode = '1';
    versionName = '1.0.0';
  }

  String get pushCerName {
    return "your push cer name";
  }

  String get voipCerName {
    return "your voip cer name";
  }
}
