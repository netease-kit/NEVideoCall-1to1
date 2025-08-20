// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:callkit_example/auth/proto/base_proto.dart';
import '../nemo_account.dart';
import 'base_service.dart';
import '../proto/login_by_nemo_proto.dart';

/// http service
class AppService extends BaseService {
  AppService._internal();

  static final AppService _singleton = AppService._internal();

  factory AppService() => _singleton;

  Future<Result<NemoAccount>> loginByNemo(String accountId) {
    return execute(LoginByNemoProto(accountId));
  }
}
