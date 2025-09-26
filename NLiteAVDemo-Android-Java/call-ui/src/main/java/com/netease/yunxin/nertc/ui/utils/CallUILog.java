// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.nertc.ui.utils;

import com.netease.yunxin.kit.alog.ParameterMap;
import com.netease.yunxin.kit.corekit.XKitLog;

public class CallUILog {
  private static final String MODULE = "CallKit_UI";

  public static void iApi(String tag, String msg) {
    XKitLog.INSTANCE.api(tag, msg, MODULE);
  }

  public static void iApi(String tag, ParameterMap msg) {
    XKitLog.INSTANCE.api(tag, msg.toValue(), MODULE);
  }

  public static void dApi(String tag, ParameterMap msg) {
    XKitLog.INSTANCE.d(tag, msg.toValue(), MODULE);
  }

  public static void i(String tag, String msg) {
    XKitLog.INSTANCE.i(tag, msg, MODULE);
  }

  public static void d(String tag, String msg) {
    XKitLog.INSTANCE.d(tag, msg, MODULE);
  }

  public static void w(String tag, String msg) {
    XKitLog.INSTANCE.w(tag, msg, MODULE);
  }

  public static void e(String tag, String msg) {
    XKitLog.INSTANCE.e(tag, msg, MODULE);
  }

  public static void e(String tag, String msg, Throwable throwable) {
    XKitLog.INSTANCE.e(tag, msg + ":" + throwable.getMessage(), MODULE);
  }

  public static void flush(boolean isSync) {
    XKitLog.INSTANCE.flush(isSync);
  }
}
