// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.utils;

import android.app.AppOpsManager;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class FloatWindowsPermission {

  // 权限常量定义
  public static final String FLOAT_PERMISSION = "android.permission.SYSTEM_ALERT_WINDOW";
  public static final String BG_START_PERMISSION = "android.permission.SYSTEM_ALERT_WINDOW";
  public static final String CAMERA_PERMISSION = "android.permission.CAMERA";
  public static final String RECORD_AUDIO_PERMISSION = "android.permission.RECORD_AUDIO";

  // 静态 Context 引用，需要在插件初始化时设置
  private static Context sApplicationContext;

  /** 设置应用上下文 */
  public static void setApplicationContext(Context context) {
    sApplicationContext = context.getApplicationContext();
  }

  /** 获取应用上下文 */
  private static Context getAppContext() {
    if (sApplicationContext == null) {
      throw new IllegalStateException(
          "Application context not set. Call Permission.setApplicationContext() first.");
    }
    return sApplicationContext;
  }

  /** 检查是否有指定权限 */
  public static boolean hasPermission(String permission) {
    if (FLOAT_PERMISSION.equals(permission)) {
      return hasOverlayPermission();
    } else if (BG_START_PERMISSION.equals(permission)) {
      return hasBackgroundStartPermission();
    }
    return false;
  }

  /** 请求悬浮窗权限 */
  public static void requestFloatPermission() {
    if (hasOverlayPermission()) {
      return;
    }

    Context context = getAppContext();
    Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
    intent.setData(Uri.parse("package:" + context.getPackageName()));
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    context.startActivity(intent);
  }

  /** 检查是否有悬浮窗权限 */
  private static boolean hasOverlayPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return Settings.canDrawOverlays(getAppContext());
    }
    return true;
  }

  /** 检查是否有后台启动权限 */
  private static boolean hasBackgroundStartPermission() {
    // 对于大多数设备，后台启动权限与悬浮窗权限相同
    // 对于特定厂商设备，可能需要额外的检查
    return hasOverlayPermission();
  }

  /** 检查通知权限是否开启 */
  public static boolean isNotificationEnabled() {
    Context context = getAppContext();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      // For Android Oreo and above
      NotificationManager manager =
          (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
      return manager.areNotificationsEnabled();
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      // For versions prior to Android Oreo
      AppOpsManager appOps = null;
      appOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
      ApplicationInfo appInfo = context.getApplicationInfo();
      String packageName = context.getApplicationContext().getPackageName();
      int uid = appInfo.uid;
      try {
        Class<?> appOpsClass = null;
        appOpsClass = Class.forName(AppOpsManager.class.getName());
        Method checkOpNoThrowMethod =
            appOpsClass.getMethod("checkOpNoThrow", Integer.TYPE, Integer.TYPE, String.class);
        Field opPostNotificationValue = appOpsClass.getDeclaredField("OP_POST_NOTIFICATION");
        int value = (int) opPostNotificationValue.get(Integer.class);
        return (int) checkOpNoThrowMethod.invoke(appOps, value, uid, packageName)
            == AppOpsManager.MODE_ALLOWED;
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    return false;
  }
}
