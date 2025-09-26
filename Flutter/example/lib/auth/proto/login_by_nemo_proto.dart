// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/auth/proto/app_http_proto.dart';

import '../../config/app_config.dart';
import '../nemo_account.dart';

class LoginByNemoProto extends AppHttpProto<NemoAccount> {
  final String accountId;

  LoginByNemoProto(this.accountId);

  @override
  String path() {
    return '${AppConfig().baseUrl}/nemo/app/initAppAndUser';
  }

  @override
  Map<String, dynamic>? header() {
    return {
      'deviceId': 'test_device_id',
      'clientType': 'aos',
      'appkey': AppConfig().appKey,
      'AppSecret': AppConfig().appSecret,
    };
  }

  @override
  NemoAccount result(Map map) {
    return NemoAccount.fromJson(Map<String, dynamic>.from(map));
  }

  @override
  Map<String, dynamic> data() {
    return {
      'sceneType': 2,
      'userUuid': accountId,
    };
  }

  @override
  bool checkLoginState() {
    return false;
  }
}
