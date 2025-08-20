// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:dio/dio.dart';
import '../client/app_http_client.dart';
import '../client/http_code.dart';
import '../proto/base_proto.dart';

const String _tag = 'HTTP';

abstract class AppHttpProto<T> extends BaseProto {
  AppHttpClient client = AppHttpClient();

  /// custom options
  Options? get options {
    var headers = header();
    if (headers != null) {
      return Options(headers: headers);
    }
    return null;
  }

  @override
  Future<Result<T>> execute() async {
    var url = path();
    var response;
    if (url.startsWith('http')) {
      response = await client.postUri(Uri.parse(url), data(), options: options);
    } else {
      response = await client.post(url, data(), options: options);
    }
    if (response == null) {
      print('HTTP: resp path=$url result is null');
      return Result(code: HttpCode.netWorkError, msg: 'Network error');
    } else {
      if (response.statusCode == HttpCode.success) {
        print('HTTP: resp path=$url code = 200 , result ${response.data}');
        if (response.data == null || response.data is! Map) {
          return Result(code: HttpCode.success, msg: 'Success');
        } else {
          final map = response.data as Map;
          final code = (map['code'] ?? HttpCode.serverError) as int;
          try {
            if (code == HttpCode.success) {
              var ret = map['ret'] ?? map['data']; // protect may be ret is null
              return Result(
                  code: HttpCode.success,
                  msg: 'Success',
                  data: (ret is! Map ? result({'data': ret}) : result(ret))
                      as T?);
            }
          } catch (e, s) {
            print(
                'HTTP: parse response error: path=$url, exception=$e, stacktrace=\n$s');
          }
          return Result(
              code: code, msg: map['msg'] as String? ?? 'Unknown error');
        }
      } else {
        print('HTTP: resp path=$path code${response.statusCode}');
        return Result(code: response.statusCode as int, msg: 'HTTP error');
      }
    }
  }

  String path();
  Map<String, dynamic>? header();
  Map<String, dynamic> data();
  T result(Map map);
}
