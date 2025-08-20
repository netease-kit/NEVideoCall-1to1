// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

abstract class BaseProto {
  Future<Result> execute();

  bool checkLoginState() {
    return false;
  }
}

class Result<T> {
  final int code;
  final String msg;
  final T? data;

  Result({
    required this.code,
    required this.msg,
    this.data,
  });

  bool get isSuccess => code == 0;

  factory Result.success({T? data, String msg = 'success'}) {
    return Result(code: 0, msg: msg, data: data);
  }

  factory Result.failure({int code = -1, String msg = 'failure', T? data}) {
    return Result(code: code, msg: msg, data: data);
  }
}
