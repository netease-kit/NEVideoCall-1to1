// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui;

import android.os.Bundle;
import android.widget.EditText;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.nertc.utils.SPUtils;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.model.NECallInitRtcMode;
import com.netease.yunxin.nertc.ui.base.Constants;

public class SettingActivity extends AppCompatActivity {
  /** rtc 默认30s */
  public static long RTC_TIME_OUT_SECOND = 30;
  /** 是否开启呼叫时加入rtc */
  public static boolean ENABLE_JOIN_RTC_WHEN_CALL =
      SPUtils.getInstance().getBoolean("enableJoinRtcWhenCall", false);
  /** 是否支持被叫时自动加入信令通道 */
  public static boolean ENABLE_AUTO_JOIN =
      SPUtils.getInstance().getBoolean("autoJoinChannelWhenCalled", false);
  /** 全局自定义抄送 */
  public static String GLOBAL_EXTRA_COPY = "";
  /** 自定义 channelName */
  public static String RTC_CHANNEL_NAME = "";
  /** 允许音频呼叫 */
  public static boolean ENABLE_AUDIO_CALL = false;
  /** 是否支持音频转视频 */
  public static boolean SUPPORT_AUDIO_TO_VIDEO = true;
  /** 是否支持视频转音频 */
  public static boolean SUPPORT_VIDEO_TO_AUDIO = true;
  /** 音频转是否是否需要确认 */
  public static boolean AUDIO_TO_VIDEO_CONFIRM = false;
  /** 视频转音频是否需要确认 */
  public static boolean VIDEO_TO_AUDIO_CONFIRM = false;
  /** 是否支持点击切换远近画布 */
  public static boolean SUPPORT_CLICK_SWITCH_CANVAS = true;
  /** 关闭摄像头模式 */
  public static int CLOSE_VIDEO_TYPE = Constants.CLOSE_TYPE_MUTE;
  /** 关闭摄像头本地展示url */
  public static String CLOSE_VIDEO_LOCAL_URL = "";
  /** 关闭摄像头远端展示url */
  public static String CLOSE_VIDEO_REMOTE_URL = "";
  /** 关闭摄像头本地展示文字提示 */
  public static String CLOSE_VIDEO_LOCAL_TIP = "";
  /** 关闭摄像头远端展示文字提示 */
  public static String CLOSE_VIDEO_REMOTE_TIP = "";
  /** rtc sdk 初始化模式 */
  public static int RTC_INIT_MODE =
      SPUtils.getInstance().getInt("rtcInitMode", NECallInitRtcMode.GLOBAL);
  /** 是否开启通话前台服务 */
  public static boolean ENABLE_CALL_FOREGROUND_SERVICE = true;
  /** 是否支持悬浮窗 */
  public static boolean ENABLE_FLOATING_WINDOW = true;
  /** 是否支持home自动展示悬浮窗 */
  public static boolean ENABLE_HOME_TO_FLOATING_WINDOW = false;
  /** 是否支持被叫展示视频预览 */
  public static boolean ENABLE_VIDEO_CALLEE_PREVIEW = false;
  /** 是否支持视频通话虚化功能 */
  public static boolean ENABLE_VIDEO_VIRTUAL_BLUR = false;

  public static boolean NEED_RESTART = false;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_setting_layout);

    findViewById(R.id.tv_cancel).setOnClickListener(v -> finish());
    EditText edtRtcTime = findViewById(R.id.edt_time);
    edtRtcTime.setText(String.valueOf(RTC_TIME_OUT_SECOND));
    SwitchCompat swEnableAudioCall = findViewById(R.id.sw_enable_audio_call);
    swEnableAudioCall.setChecked(ENABLE_AUDIO_CALL);

    findViewById(R.id.tv_done)
        .setOnClickListener(
            v -> {
              try {
                long rtcTime = Long.parseLong(edtRtcTime.getText().toString());
                rtcTime = Math.max(rtcTime, 0);
                RTC_TIME_OUT_SECOND = rtcTime;
                NECallEngine.sharedInstance().setTimeout(RTC_TIME_OUT_SECOND * 1000);

                ENABLE_AUDIO_CALL = swEnableAudioCall.isChecked();

                Toast.makeText(SettingActivity.this, "设置成功", Toast.LENGTH_SHORT).show();
                finish();
              } catch (Exception e) {
                Toast.makeText(SettingActivity.this, "设置失败", Toast.LENGTH_SHORT).show();
              }
            });

  }

  public static void toInit() {
    RTC_TIME_OUT_SECOND = 30;

    GLOBAL_EXTRA_COPY = "";

    ENABLE_CALL_FOREGROUND_SERVICE = true;

    RTC_CHANNEL_NAME = "";

    ENABLE_AUDIO_CALL = false;
  }
}
