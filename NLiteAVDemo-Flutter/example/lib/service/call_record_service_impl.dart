// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/auth/auth_manager.dart';
import 'call_record_service.dart';

/// CallRecordService的具体实现类
class CallRecordServiceImpl extends CallRecordService {
  static final CallRecordServiceImpl _instance =
      CallRecordServiceImpl._internal();
  factory CallRecordServiceImpl() => _instance;
  CallRecordServiceImpl._internal();

  final AuthManager _authManager = AuthManager();

  @override
  Future<String?> getCurrentAccountId() async {
    try {
      return _authManager.accountId;
    } catch (e) {
      print('Failed to get current account ID: $e');
      return null;
    }
  }

  /// 获取当前登录状态
  bool get isLoggedIn => _authManager.isLogined();

  /// 监听登录状态变化
  Stream<String?> get authInfoStream =>
      _authManager.authInfoStream().map((info) => info?.accountId);
}
