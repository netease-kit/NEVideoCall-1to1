package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import com.netease.yunxin.kit.alog.ALog;

public class CallUILog {
  public static final String MODULE_NAME = "CallKitUIPlugin";

  public static void i(String tag, String msg) {
    ALog.i(tag, MODULE_NAME, msg);
  }

  public static void e(String tag, String msg) {
    ALog.e(tag, MODULE_NAME, msg);
  }

  public static void w(String tag, String msg) {
    ALog.w(tag, MODULE_NAME, msg);
  }
}
