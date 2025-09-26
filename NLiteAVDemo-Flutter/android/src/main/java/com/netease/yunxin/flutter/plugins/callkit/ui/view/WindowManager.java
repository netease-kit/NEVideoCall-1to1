// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.view;

import android.content.Context;
import android.content.Intent;
import android.os.PowerManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.CallKitUIPlugin;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.service.ServiceInitializer;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.CallState;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.User;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.DeviceUtils;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.FloatWindowsPermission;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.floatwindow.FloatWindowService;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow.IncomingFloatView;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow.IncomingNotificationView;

public class WindowManager {

  public static boolean showFloatWindow(Context context) {
    if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.FLOAT_PERMISSION)) {
      Intent mStartIntent = new Intent(context, FloatWindowService.class);
      context.startService(mStartIntent);
      return true;
    } else {
      FloatWindowsPermission.requestFloatPermission();
      return false;
    }
  }

  public static void closeFloatWindow(Context context) {
    Intent mStartIntent = new Intent(context, FloatWindowService.class);
    context.stopService(mStartIntent);
  }

  public static void backCallingPageFromFloatWindow(Context context) {
    if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.BG_START_PERMISSION)) {
      launchMainActivity(context);
    }
    EventManager.getInstance()
        .notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, null);
  }

  public static void showIncomingBanner(Context context) {
    CallUILog.i(CallKitUIPlugin.TAG, "Android Native: showIncomingBanner");
    User caller = CallState.getInstance().mRemoteUserList.get(0);
    if (caller == null) {
      return;
    }

    if (ServiceInitializer.isAppInForeground(context)) {
      incomingBannerInForeground(context, caller);
    } else {
      incomingBannerInBackground(context, caller);
    }
  }

  public static void openLockScreenApp(Context context) {
    CallUILog.i(CallKitUIPlugin.TAG, "Android Native: openLockScreenApp ");
    User caller = CallState.getInstance().mRemoteUserList.get(0);
    if (caller == null) {
      return;
    }
    turnOnScreen(context);

    if (DeviceUtils.isSamsungDevice()
        && FloatWindowsPermission.hasPermission(FloatWindowsPermission.BG_START_PERMISSION)) {
      CallUILog.i(
          CallKitUIPlugin.TAG, "Android Native: openLockScreenApp, try to launch MainActivity");
      launchMainActivity(context);
      return;
    }

    if (!ServiceInitializer.isAppInForeground(context)
        && FloatWindowsPermission.isNotificationEnabled()) {
      CallUILog.i(
          CallKitUIPlugin.TAG,
          "Android Native: openLockScreenApp, will open IncomingNotificationView");
      IncomingNotificationView.getInstance(context)
          .showNotification(caller, CallState.getInstance().mMediaType);
      return;
    }

    CallUILog.i(
        CallKitUIPlugin.TAG, "Android Native: openLockScreenApp, try to launch MainActivity");
    launchMainActivity(context);
  }

  public static void pullBackgroundApp(Context context) {
    CallUILog.i(CallKitUIPlugin.TAG, "Android Native: pullBackgroundApp ");
    User caller = CallState.getInstance().mRemoteUserList.get(0);
    if (caller == null) {
      return;
    }

    turnOnScreen(context);

    if (DeviceUtils.isSamsungDevice()
        && FloatWindowsPermission.hasPermission(FloatWindowsPermission.BG_START_PERMISSION)) {
      CallUILog.i(
          CallKitUIPlugin.TAG, "Android Native: pullBackgroundApp, try to launch MainActivity");
      launchMainActivity(context);
      return;
    }

    if (!ServiceInitializer.isAppInForeground(context)) {
      if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.FLOAT_PERMISSION)) {
        CallUILog.i(
            CallKitUIPlugin.TAG, "Android Native: pullBackgroundApp, will open IncomingFloatView");
        startIncomingFloatWindow(context, caller);
        return;
      } else if (FloatWindowsPermission.isNotificationEnabled()) {
        CallUILog.i(
            CallKitUIPlugin.TAG,
            "Android Native: pullBackgroundApp, will open IncomingNotificationView");
        IncomingNotificationView.getInstance(context)
            .showNotification(caller, CallState.getInstance().mMediaType);
        return;
      }
    }

    CallUILog.i(
        CallKitUIPlugin.TAG, "Android Native: pullBackgroundApp, try to launch MainActivity");
    launchMainActivity(context);
  }

  private static void incomingBannerInForeground(Context context, User caller) {
    if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.FLOAT_PERMISSION)) {
      startIncomingFloatWindow(context, caller);
    } else {
      EventManager.getInstance()
          .notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
    }
  }

  private static void incomingBannerInBackground(Context context, User caller) {
    if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.FLOAT_PERMISSION)) {
      CallUILog.i(CallKitUIPlugin.TAG, "App in background, will open IncomingFloatView");
      startIncomingFloatWindow(context, caller);
    } else if (FloatWindowsPermission.isNotificationEnabled()) {
      CallUILog.i(CallKitUIPlugin.TAG, "App in background, will open IncomingNotificationView");
      IncomingNotificationView.getInstance(context)
          .showNotification(caller, CallState.getInstance().mMediaType);
    } else {
      CallUILog.i(CallKitUIPlugin.TAG, "App in background, try to launch intent");
      launchMainActivity(context);
    }
  }

  public static void launchMainActivity(Context context) {
    CallUILog.i(CallKitUIPlugin.TAG, "Try to launch main activity");
    Intent intentLaunchMain =
        context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
    if (intentLaunchMain != null) {
      intentLaunchMain.putExtra("show_in_foreground", true);
      intentLaunchMain.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(intentLaunchMain);
    } else {
      CallUILog.e(
          CallKitUIPlugin.TAG,
          "Failed to get launch intent for package: " + context.getPackageName());
    }
  }

  private static void startIncomingFloatWindow(Context context, User caller) {
    IncomingFloatView floatView = new IncomingFloatView(context);
    CallState.getInstance().mIncomingFloatView = floatView;
    floatView.showIncomingView(caller, CallState.getInstance().mMediaType);
  }

  private static boolean isFCMDataNotification() {
    return false;
  }

  private static void turnOnScreen(Context context) {
    PowerManager powerManager = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
    PowerManager.WakeLock wakeLock =
        powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK
                | PowerManager.ACQUIRE_CAUSES_WAKEUP
                | PowerManager.ON_AFTER_RELEASE,
            "MyApp:MyWakeLockTag");
    wakeLock.acquire();
    wakeLock.release();
  }
}
