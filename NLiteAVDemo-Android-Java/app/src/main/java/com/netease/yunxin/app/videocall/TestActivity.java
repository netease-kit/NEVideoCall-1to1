// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import androidx.annotation.NonNull;
import com.netease.yunxin.app.videocall.nertc.ui.SettingActivity;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.alog.ParameterMap;
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig;
import com.netease.yunxin.nertc.ui.base.CallParam;
import com.netease.yunxin.nertc.ui.p2p.P2PCallFragmentActivity;
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig;

public class TestActivity extends P2PCallFragmentActivity {
  private static final String TAG = "TestActivity";

  @NonNull
  @Override
  protected P2PUIConfig provideUIConfig(CallParam param) {
    ALog.d(TAG, new ParameterMap("provideUIConfig").append("param", param).toValue());
    return new P2PUIConfig.Builder()
        .closeVideoType(SettingActivity.CLOSE_VIDEO_TYPE)
        .closeVideoLocalUrl(SettingActivity.CLOSE_VIDEO_LOCAL_URL)
        .closeVideoLocalTip(SettingActivity.CLOSE_VIDEO_LOCAL_TIP)
        .closeVideoRemoteUrl(SettingActivity.CLOSE_VIDEO_REMOTE_URL)
        .closeVideoRemoteTip(SettingActivity.CLOSE_VIDEO_REMOTE_TIP)
        .showVideo2AudioSwitchOnTheCall(SettingActivity.SUPPORT_VIDEO_TO_AUDIO)
        .showAudio2VideoSwitchOnTheCall(SettingActivity.SUPPORT_AUDIO_TO_VIDEO)
        .enableCanvasSwitch(SettingActivity.SUPPORT_CLICK_SWITCH_CANVAS)
        .enableForegroundService(SettingActivity.ENABLE_CALL_FOREGROUND_SERVICE)
        .foregroundNotificationConfig(new CallKitNotificationConfig(R.mipmap.ic_launcher))
        .enableFloatingWindow(SettingActivity.ENABLE_FLOATING_WINDOW)
        .enableAutoFloatingWindowWhenHome(SettingActivity.ENABLE_HOME_TO_FLOATING_WINDOW)
        .enableVideoCalleePreview(SettingActivity.ENABLE_VIDEO_CALLEE_PREVIEW)
        .enableVirtualBlur(SettingActivity.ENABLE_VIDEO_VIRTUAL_BLUR)
        .build();
  }
}
