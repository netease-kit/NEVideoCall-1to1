// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui;

import androidx.annotation.NonNull;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.WakeLock;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import java.util.Map;

public class CallKitUIPlugin implements FlutterPlugin, ActivityAware, EventManager.INotifyEvent {
  public static final String TAG = "CallKitUIPlugin";

  private CallKitUIHandler mCallKitManager;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    CallUILog.i(TAG, "onAttachedToEngine");
    mCallKitManager = new CallKitUIHandler(flutterPluginBinding);
    registerObserver();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    CallUILog.i(TAG, "onDetachedFromEngine");
    mCallKitManager.removeMethodChannelHandler();
    unRegisterObserver();
  }

  private void registerObserver() {
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GOTO_CALLING_PAGE, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_ENABLE_FLOAT_WINDOW, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_CALL, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_GROUP_CALL, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_LOGIN_SUCCESS, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_LOGOUT_SUCCESS, this);
    EventManager.getInstance()
        .registerEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_ENTER_FOREGROUND, this);
  }

  private void unRegisterObserver() {
    EventManager.getInstance().unRegisterEvent(this);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    WakeLock.getInstance().setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    WakeLock.getInstance().setActivity(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    WakeLock.getInstance().setActivity(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    WakeLock.getInstance().setActivity(null);
  }

  @Override
  public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
    CallUILog.i(TAG, "onNotifyEvent : key : " + key + ", subKey : " + subKey);
    if (!Constants.KEY_CALLKIT_PLUGIN.equals(key)) {
      return;
    }

    if (Constants.SUB_KEY_GOTO_CALLING_PAGE.equals(subKey)) {
      mCallKitManager.backCallingPageFromFloatWindow();
      return;
    }

    if (Constants.SUB_KEY_HANDLE_CALL_RECEIVED.equals(subKey)) {
      mCallKitManager.launchCallingPageFromIncomingBanner();
      return;
    }

    if (Constants.SUB_KEY_ENTER_FOREGROUND.equals(subKey)) {
      mCallKitManager.appEnterForeground();
    }
  }
}
