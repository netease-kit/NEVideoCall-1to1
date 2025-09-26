// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui;

import static com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants.KEY_NESTATE_CHANGE;
import static com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants.SUBKEY_REFRESH_VIEW;

import android.Manifest;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.permission.PermissionCallback;
import com.netease.yunxin.flutter.plugins.callkit.ui.permission.PermissionRequester;
import com.netease.yunxin.flutter.plugins.callkit.ui.service.AudioCallForegroundService;
import com.netease.yunxin.flutter.plugins.callkit.ui.service.ServiceInitializer;
import com.netease.yunxin.flutter.plugins.callkit.ui.service.VideoCallForegroundService;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.CallState;
import com.netease.yunxin.flutter.plugins.callkit.ui.state.User;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallingBellPlayer;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallingVibrator;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.DeviceUtils;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.FloatWindowsPermission;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.MethodCallUtils;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.MethodUtils;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.ObjectParse;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.WakeLock;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.WindowManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow.IncomingNotificationView;
import com.netease.yunxin.kit.call.p2p.model.NECallType;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CallKitUIHandler {
  public static final String TAG = "CallKitUIHandler";
  public static String CHANNEL_NAME = "call_kit_ui";
  private final MethodChannel mChannel;
  private final Context mApplicationContext;
  private final CallingBellPlayer mCallingBellPlayer;
  private final CallingVibrator mCallingVibrator;

  public CallKitUIHandler(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
    CallUILog.i(TAG, "CallKitUIPlugin init");

    this.mChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    mApplicationContext = flutterPluginBinding.getApplicationContext();

    // 设置 Permission 类的应用上下文
    FloatWindowsPermission.setApplicationContext(mApplicationContext);

    mCallingBellPlayer = new CallingBellPlayer(mApplicationContext);
    mCallingVibrator = new CallingVibrator(mApplicationContext);

    this.mChannel.setMethodCallHandler(
        (call, result) -> {
          try {
            Method method =
                CallKitUIHandler.class.getDeclaredMethod(
                    call.method, MethodCall.class, MethodChannel.Result.class);
            method.invoke(this, call, result);
          } catch (Exception e) {
            CallUILog.e(
                CallKitUIPlugin.TAG,
                "onMethodCall |method="
                    + call.method
                    + "|arguments="
                    + call.arguments
                    + "|error="
                    + e);
          }
        });
  }

  public void removeMethodChannelHandler() {
    mChannel.setMethodCallHandler(null);
  }

  public void startForegroundService(MethodCall call, MethodChannel.Result result) {
    int mediaTypeIndex = MethodCallUtils.getMethodParams(call, "mediaType");
    int mediaType = ObjectParse.getMediaType(mediaTypeIndex);
    CallUILog.i(TAG, "startForegroundService");
    if (mediaType == NECallType.AUDIO) {
      AudioCallForegroundService.start(mApplicationContext);
    } else {
      VideoCallForegroundService.start(mApplicationContext);
    }
    result.success(0);
  }

  public void stopForegroundService(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "stopForegroundService");
    AudioCallForegroundService.stop(mApplicationContext);
    VideoCallForegroundService.stop(mApplicationContext);
    result.success(0);
  }

  public void startRing(MethodCall call, MethodChannel.Result result) {
    String filePath = MethodCallUtils.getMethodRequiredParams(call, "filePath", result);
    CallUILog.i(TAG, "startRing filePath=" + filePath);
    mCallingBellPlayer.startRing(filePath);
    result.success(0);
  }

  public void stopRing(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "stopRing");
    mCallingBellPlayer.stopRing();
    IncomingNotificationView.getInstance(mApplicationContext).cancelNotification();
    if (CallState.getInstance().mIncomingFloatView != null) {
      CallState.getInstance().mIncomingFloatView.cancelIncomingView();
    }
    result.success(0);
  }

  public void updateCallStateToNative(MethodCall call, MethodChannel.Result result) {
    boolean needRefreshView = false;
    Map selfUserMap = MethodCallUtils.getMethodParams(call, "selfUser");
    CallUILog.i(TAG, "updateCallStateToNative selfUser=" + selfUserMap);
    User selfUser = ObjectParse.getUserByMap(selfUserMap);
    if (!CallState.getInstance().mSelfUser.isSameUser(selfUser)) {
      if (selfUser.callStatus != CallState.getInstance().mSelfUser.callStatus) {
        needRefreshView = true;
      }
      CallState.getInstance().mSelfUser = selfUser;
    }

    List<Map> remoteUserMapList = MethodCallUtils.getMethodParams(call, "remoteUserList");
    CallState.getInstance().mRemoteUserList.clear();
    for (Map remoteUserMap : remoteUserMapList) {
      User remoteUser = ObjectParse.getUserByMap(remoteUserMap);
      CallState.getInstance().mRemoteUserList.add(remoteUser);
      needRefreshView = true;
    }

    int sceneIndex = MethodCallUtils.getMethodParams(call, "scene");
    //        NECallState.getInstance().mScene = ObjectParse.getSceneType(sceneIndex);

    int mediaTypeIndex = MethodCallUtils.getMethodParams(call, "mediaType");
    if (CallState.getInstance().mMediaType != ObjectParse.getMediaType(mediaTypeIndex)) {
      needRefreshView = true;
      CallState.getInstance().mMediaType = ObjectParse.getMediaType(mediaTypeIndex);
    }
    CallState.getInstance().mStartTime = MethodCallUtils.getMethodParams(call, "startTime");
    //
    //    int cameraIndex = MethodCallUtils.getMethodParams(call, "camera");
    //    NECallState.getInstance().mCamera = ObjectParse.getCameraType(cameraIndex);
    //
    //    NECallState.getInstance().mIsCameraOpen = MethodCallUtils.getMethodParams(call, "isCameraOpen");
    //
    //    NECallState.getInstance().mIsMicrophoneMute = MethodCallUtils.getMethodParams(call, "isMicrophoneMute");
    //
    if (needRefreshView) {
      EventManager.getInstance()
          .notifyEvent(KEY_NESTATE_CHANGE, SUBKEY_REFRESH_VIEW, new HashMap<>());
    }
    result.success(0);
  }

  public void startFloatWindow(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "startFloatWindow");
    if (WindowManager.showFloatWindow(mApplicationContext)) {
      result.success(0);
    } else {
      result.error("-1", "No Permission", null);
    }
  }

  public void stopFloatWindow(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "stopFloatWindow");
    WindowManager.showIncomingBanner(mApplicationContext);
    result.success(0);
  }

  public void hasFloatPermission(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "hasFloatPermission");
    if (FloatWindowsPermission.hasPermission(FloatWindowsPermission.FLOAT_PERMISSION)) {
      result.success(true);
    } else {
      result.success(false);
    }
  }

  public void requestFloatPermission(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "requestFloatPermission");
    FloatWindowsPermission.requestFloatPermission();
    result.success(true);
  }

  public void isAppInForeground(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "isAppInForeground");
    if (ServiceInitializer.isAppInForeground(mApplicationContext)) {
      result.success(true);
    } else {
      result.success(false);
    }
  }

  public void showIncomingBanner(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "showIncomingBanner");
    WindowManager.showIncomingBanner(mApplicationContext);
    result.success(0);
  }

  public void apiLog(MethodCall call, MethodChannel.Result result) {
    result.success(0);
  }

  public void hasPermissions(MethodCall call, MethodChannel.Result result) {
    List<Integer> permissionsList = MethodUtils.getMethodParam(call, "permission");
    String[] strings = new String[permissionsList.size()];
    for (int i = 0; i < permissionsList.size(); i++) {
      strings[i] = getPermissionsByIndex(permissionsList.get(i));
    }
    boolean isGranted = PermissionRequester.isGranted(strings);
    result.success(isGranted);
  }

  public void requestPermissions(MethodCall call, MethodChannel.Result result) {
    List<Integer> permissionsList = MethodUtils.getMethodParam(call, "permission");
    String[] permissions = new String[permissionsList.size()];
    for (int i = 0; i < permissionsList.size(); i++) {
      permissions[i] = getPermissionsByIndex(permissionsList.get(i));
    }
    String title = MethodUtils.getMethodParam(call, "title");
    String description = MethodUtils.getMethodParam(call, "description");
    String settingsTip = MethodUtils.getMethodParam(call, "settingsTip");
    PermissionCallback callback =
        new PermissionCallback() {
          @Override
          public void onGranted() {
            result.success(PermissionRequester.Result.Granted.ordinal());
          }

          @Override
          public void onDenied() {
            result.success(PermissionRequester.Result.Denied.ordinal());
          }

          @Override
          public void onRequesting() {
            result.success(PermissionRequester.Result.Requesting.ordinal());
          }
        };

    PermissionRequester.newInstance(permissions)
        .title(title)
        .description(description)
        .settingsTip(settingsTip)
        .callback(callback)
        .request();
  }

  private String getPermissionsByIndex(int index) {
    switch (index) {
      case 0:
        return Manifest.permission.CAMERA;
      case 1:
        return Manifest.permission.RECORD_AUDIO;
      case 2:
        return Manifest.permission.BLUETOOTH_CONNECT;
      default:
        return "";
    }
  }

  public void pullBackgroundApp(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "pullBackgroundApp");
    WindowManager.pullBackgroundApp(mApplicationContext);
    result.success(0);
  }

  public void openLockScreenApp(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "openLockScreenApp");
    WindowManager.openLockScreenApp(mApplicationContext);
    result.success(0);
  }

  public void isScreenLocked(MethodCall call, MethodChannel.Result result) {
    if (DeviceUtils.isScreenLocked(mApplicationContext)) {
      result.success(true);
    } else {
      result.success(false);
    }
  }

  public void enableWakeLock(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "enableWakeLock");
    boolean enable = MethodCallUtils.getMethodParams(call, "enable");
    if (enable) {
      WakeLock.getInstance().enable();
    } else {
      WakeLock.getInstance().disable();
    }
    result.success(0);
  }

  public void isSamsungDevice(MethodCall call, MethodChannel.Result result) {
    CallUILog.i(TAG, "isSamsungDevice");
    if (DeviceUtils.isSamsungDevice()) {
      result.success(true);
    } else {
      result.success(false);
    }
  }

  public void backCallingPageFromFloatWindow() {
    CallUILog.i(TAG, "backCallingPageFromFloatWindow");
    mChannel.invokeMethod(
        "backCallingPageFromFloatWindow",
        new HashMap(),
        new MethodChannel.Result() {
          @Override
          public void success(@Nullable Object result) {}

          @Override
          public void error(
              @NonNull String code, @Nullable String message, @Nullable Object details) {
            CallUILog.e(
                CallKitUIPlugin.TAG,
                "backCallingPageFromFloatWindow error code: "
                    + code
                    + " message:"
                    + message
                    + "details:"
                    + details);
          }

          @Override
          public void notImplemented() {
            CallUILog.e(CallKitUIPlugin.TAG, "backCallingPageFromFloatWindow notImplemented");
          }
        });
  }

  public void launchCallingPageFromIncomingBanner() {
    CallUILog.i(TAG, "launchCallingPageFromIncomingBanner");
    mChannel.invokeMethod(
        "launchCallingPageFromIncomingBanner",
        new HashMap<>(),
        new MethodChannel.Result() {
          @Override
          public void success(@Nullable Object result) {}

          @Override
          public void error(
              @NonNull String code, @Nullable String message, @Nullable Object details) {}

          @Override
          public void notImplemented() {
            CallUILog.e(CallKitUIPlugin.TAG, "launchCallingPageFromIncomingBanner notImplemented");
          }
        });
  }

  public void appEnterForeground() {
    CallUILog.i(TAG, "appEnterForeground");
    mChannel.invokeMethod(
        "appEnterForeground",
        new HashMap<>(),
        new MethodChannel.Result() {
          @Override
          public void success(@Nullable Object result) {
            CallUILog.e(CallKitUIPlugin.TAG, "appEnterForeground success");
          }

          @Override
          public void error(
              @NonNull String code, @Nullable String message, @Nullable Object details) {
            CallUILog.e(
                CallKitUIPlugin.TAG,
                "appEnterForeground error code: "
                    + code
                    + " message:"
                    + message
                    + "details:"
                    + details);
          }

          @Override
          public void notImplemented() {
            CallUILog.e(CallKitUIPlugin.TAG, "appEnterForeground notImplemented");
          }
        });
  }
}
