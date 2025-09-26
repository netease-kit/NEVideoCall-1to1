// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.flutter.plugins.callkit.ui.view.incomingfloatwindow;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import com.netease.yunxin.flutter.plugins.callkit.ui.CallKitUIPlugin;
import com.netease.yunxin.flutter.plugins.callkit.ui.event.EventManager;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.CallUILog;
import com.netease.yunxin.flutter.plugins.callkit.ui.utils.Constants;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam;
import java.util.Objects;

public class IncomingCallReceiver extends BroadcastReceiver {
  @Override
  public void onReceive(Context context, Intent intent) {
    if (intent == null) {
      CallUILog.w(CallKitUIPlugin.TAG, "intent is invalid,ignore");
      return;
    }

    CallUILog.i(CallKitUIPlugin.TAG, "onReceive: action: " + intent.getAction());

    if (Objects.equals(intent.getAction(), Constants.SUB_KEY_HANDLE_CALL_RECEIVED)) {
      IncomingNotificationView.getInstance(context).cancelNotification();
      EventManager.getInstance()
          .notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
    } else if (Objects.equals(intent.getAction(), Constants.ACCEPT_CALL_ACTION)) {
      NECallEngine.sharedInstance().accept(null);
      IncomingNotificationView.getInstance(context).cancelNotification();
      EventManager.getInstance()
          .notifyEvent(Constants.KEY_CALLKIT_PLUGIN, Constants.SUB_KEY_HANDLE_CALL_RECEIVED, null);
    } else if (Objects.equals(intent.getAction(), Constants.REJECT_CALL_ACTION)) {
      NECallEngine.sharedInstance().hangup(new NEHangupParam(), null);
      IncomingNotificationView.getInstance(context).cancelNotification();
    } else {
      CallUILog.w(CallKitUIPlugin.TAG, "intent.action is invalid,ignore");
    }
  }
}
