// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:yunxin_alog/yunxin_alog.dart';

const moduleName = 'CallKit_UI_Flutter';

class CallKitUILog {
  static void i(String tag, String content) {
    Alog.i(tag: tag, moduleName: moduleName, content: content);
  }

  static void d(String tag, String content) {
    Alog.d(tag: tag, moduleName: moduleName, content: content);
  }

  static void e(String tag, String content) {
    Alog.e(tag: tag, moduleName: moduleName, content: content);
  }
}
