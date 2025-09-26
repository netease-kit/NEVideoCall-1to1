// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import io.flutter.plugin.common.MethodCall;

public class MethodUtils {

  /** 通用方法，获得参数值，参数可以为null */
  public static <T> T getMethodParam(MethodCall methodCall, String param) {
    T parameter = methodCall.argument(param);
    return parameter;
  }
}
