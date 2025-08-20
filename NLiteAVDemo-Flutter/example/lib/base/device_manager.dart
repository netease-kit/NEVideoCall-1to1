// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

class DeviceManager {
  factory DeviceManager() {
    _instance ??= DeviceManager._internal();
    return _instance!;
  }

  static DeviceManager? _instance;
  static late String _deviceId;
  static int _clientType = 0;

  DeviceManager._internal();

  Future<void> init() async {
    // 简化版本，直接生成设备ID
    _deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';

    if (Platform.isAndroid) {
      _clientType = 1; // aos
    } else if (Platform.isIOS) {
      _clientType = 2; // ios
    } else if (Platform.isWindows || Platform.isMacOS) {
      _clientType = 3; // pc
    }
  }

  String get deviceId {
    return _deviceId;
  }

  int get clientType {
    return _clientType;
  }
}
