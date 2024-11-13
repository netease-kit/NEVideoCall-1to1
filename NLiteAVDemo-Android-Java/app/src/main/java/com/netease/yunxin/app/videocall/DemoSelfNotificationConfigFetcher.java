// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.text.TextUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.call.group.NEGroupCallInfo;
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo;
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig;
import kotlin.jvm.functions.Function1;
import org.json.JSONObject;

class DemoSelfNotificationConfigFetcher<T> implements Function1<T, CallKitNotificationConfig> {
  public final String TAG = "DemoSelfNotificationConfigFetcher";

  @Override
  public CallKitNotificationConfig invoke(T info) {
    String name = null;
    if (info instanceof NEInviteInfo) {
      NEInviteInfo invitedInfo = (NEInviteInfo) info;
      name = getUserName(invitedInfo.callerAccId, invitedInfo.extraInfo);
    } else if (info instanceof NEGroupCallInfo) {
      NEGroupCallInfo groupCallInfo = (NEGroupCallInfo) info;
      name = getUserName(groupCallInfo.callerAccId, groupCallInfo.extraInfo);
    }
    return new CallKitNotificationConfig(
        R.mipmap.ic_launcher, null, "您有新的来电", name + "邀请您进行【网络通话】");
  }

  /**
   * 这里可以自定义信息展示
   *
   * @param accId
   * @param inviteExtraInfo
   * @return
   */
  private String getUserName(String accId, String inviteExtraInfo) {
    String name;
    try {
      JSONObject object = new JSONObject(inviteExtraInfo);
      name = object.optString("userName");
    } catch (Exception exception) {
      ALog.e(TAG, "parse inviteInfo extra error.", exception);
      name = "";
    }
    if (TextUtils.isEmpty(name)) {
      name = accId;
    }
    return name;
  }
}
