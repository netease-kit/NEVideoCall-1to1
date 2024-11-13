// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.nertc.utils.SPUtils;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.model.NECallConfig;
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
  /** 自定义rtcUid */
  public static long RTC_CHANNEL_UID = SPUtils.getInstance().getLong("currentUserRtcUid", 0L);
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
  public static boolean ENABLE_CALL_FOREGROUND_SERVICE = false;
  /** 是否支持悬浮窗 */
  public static boolean ENABLE_FLOATING_WINDOW = true;
  /** 是否支持home自动展示悬浮窗 */
  public static boolean ENABLE_HOME_TO_FLOATING_WINDOW = false;
  /** 是否支持被叫展示视频预览 */
  public static boolean ENABLE_VIDEO_CALLEE_PREVIEW = false;
  /** 是否支持视频通话虚化功能 */
  public static boolean ENABLE_VIDEO_VIRTUAL_BLUR = false;

  private TextView restartTip;
  public static boolean NEED_RESTART = false;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_setting_layout);

    findViewById(R.id.tv_cancel).setOnClickListener(v -> finish());

    restartTip = findViewById(R.id.restart_tip);
    updateTip();

    EditText edtRtcTime = findViewById(R.id.edt_time);
    edtRtcTime.setText(String.valueOf(RTC_TIME_OUT_SECOND));

    SwitchCompat swEnableJoinRtcWhenCall = findViewById(R.id.swEnableJoinRtcWhenCall);
    swEnableJoinRtcWhenCall.setChecked(ENABLE_JOIN_RTC_WHEN_CALL);
    swEnableJoinRtcWhenCall.setOnCheckedChangeListener(
        (buttonView, isChecked) -> {
          SPUtils.getInstance().put("enableJoinRtcWhenCall", isChecked);
          ENABLE_JOIN_RTC_WHEN_CALL = isChecked;
          NEED_RESTART = true;
          updateTip();
        });

    SwitchCompat swEnableAutoJoin = findViewById(R.id.swEnableAutoJoin);
    swEnableAutoJoin.setChecked(ENABLE_AUTO_JOIN);
    swEnableAutoJoin.setOnCheckedChangeListener(
        (buttonView, isChecked) -> {
          SPUtils.getInstance().put("autoJoinChannelWhenCalled", isChecked);
          ENABLE_AUTO_JOIN = isChecked;
          NEED_RESTART = true;
          updateTip();
        });

    EditText editGlobalExtraCopy = findViewById(R.id.et_input_global_extra);
    editGlobalExtraCopy.setText(String.valueOf(GLOBAL_EXTRA_COPY));

    SwitchCompat swEnableCallForegroundService =
        findViewById(R.id.sw_for_support_foreground_service);
    swEnableCallForegroundService.setChecked(ENABLE_CALL_FOREGROUND_SERVICE);

    EditText edtRtcChannelName = findViewById(R.id.et_input_custom_channel_name);
    edtRtcChannelName.setText(RTC_CHANNEL_NAME);

    RTC_CHANNEL_UID = SPUtils.getInstance().getLong("currentUserRtcUid", 0L);
    EditText edtRtcChannelUId = findViewById(R.id.et_input_rtc_uid);
    edtRtcChannelUId.setText(String.valueOf(RTC_CHANNEL_UID));

    EditText edtRtcInitMode = findViewById(R.id.et_input_rtc_init_mode);
    edtRtcInitMode.setText(String.valueOf(RTC_INIT_MODE));

    SwitchCompat swEnableAudioCall = findViewById(R.id.sw_enable_audio_call);
    swEnableAudioCall.setChecked(ENABLE_AUDIO_CALL);

    SwitchCompat swSupportAudioToVideo = findViewById(R.id.sw_support_audio_to_video);
    swSupportAudioToVideo.setChecked(SUPPORT_AUDIO_TO_VIDEO);

    SwitchCompat swSupportVideoToAudio = findViewById(R.id.sw_support_video_to_audio);
    swSupportVideoToAudio.setChecked(SUPPORT_VIDEO_TO_AUDIO);

    SwitchCompat swSupportSwitchCanvas = findViewById(R.id.sw_enable_switch_canvas);
    swSupportSwitchCanvas.setChecked(SUPPORT_CLICK_SWITCH_CANVAS);

    EditText edtCloseVideoType = findViewById(R.id.et_close_video_type);
    edtCloseVideoType.setText(String.valueOf(CLOSE_VIDEO_TYPE));

    EditText edtCloseVideoLocalUrl = findViewById(R.id.et_close_video_local_url);
    edtCloseVideoLocalUrl.setText(CLOSE_VIDEO_LOCAL_URL);

    EditText edtCloseVideoRemoteUrl = findViewById(R.id.et_close_video_remote_url);
    edtCloseVideoRemoteUrl.setText(CLOSE_VIDEO_REMOTE_URL);

    EditText edtCloseVideoLocalTip = findViewById(R.id.et_close_video_local_tip);
    edtCloseVideoLocalTip.setText(CLOSE_VIDEO_LOCAL_TIP);

    EditText edtCloseVideoRemoteTip = findViewById(R.id.et_close_video_remote_tip);
    edtCloseVideoRemoteTip.setText(CLOSE_VIDEO_REMOTE_TIP);

    SwitchCompat swAudio2Video = findViewById(R.id.sw_audio_to_video_confirm);
    swAudio2Video.setChecked(AUDIO_TO_VIDEO_CONFIRM);

    SwitchCompat swFloatingWindow = findViewById(R.id.sw_enable_floating_window);
    swFloatingWindow.setChecked(ENABLE_FLOATING_WINDOW);

    SwitchCompat swHomeToFloatingWindow = findViewById(R.id.sw_enable_home_floating_window);
    swHomeToFloatingWindow.setChecked(ENABLE_HOME_TO_FLOATING_WINDOW);

    SwitchCompat swCalleeVideoPreview = findViewById(R.id.sw_enable_callee_video_preview);
    swCalleeVideoPreview.setChecked(ENABLE_VIDEO_CALLEE_PREVIEW);

    SwitchCompat swVirtualBlur = findViewById(R.id.sw_enable_virtual_blur);
    swVirtualBlur.setChecked(ENABLE_VIDEO_VIRTUAL_BLUR);

    SwitchCompat swVideo2Audio = findViewById(R.id.sw_video_to_audio_confirm);
    swVideo2Audio.setChecked(VIDEO_TO_AUDIO_CONFIRM);

    findViewById(R.id.bt_upload_rtc_log)
        .setOnClickListener(
            v -> {
              NERtcEx.getInstance().uploadSdkInfo();
              Toast.makeText(SettingActivity.this, "上传成功", Toast.LENGTH_SHORT).show();
            });

    findViewById(R.id.tv_done)
        .setOnClickListener(
            v -> {
              try {
                long rtcTime = Long.parseLong(edtRtcTime.getText().toString());
                rtcTime = Math.max(rtcTime, 0);
                RTC_TIME_OUT_SECOND = rtcTime;
                NECallEngine.sharedInstance().setTimeout(RTC_TIME_OUT_SECOND * 1000);

                ENABLE_AUTO_JOIN = swEnableAutoJoin.isChecked();

                ENABLE_AUDIO_CALL = swEnableAudioCall.isChecked();
                ENABLE_CALL_FOREGROUND_SERVICE = swEnableCallForegroundService.isChecked();
                GLOBAL_EXTRA_COPY = editGlobalExtraCopy.getText().toString();
                RTC_CHANNEL_NAME = edtRtcChannelName.getText().toString();
                SUPPORT_AUDIO_TO_VIDEO = swSupportAudioToVideo.isChecked();
                AUDIO_TO_VIDEO_CONFIRM = swAudio2Video.isChecked();
                VIDEO_TO_AUDIO_CONFIRM = swVideo2Audio.isChecked();
                ENABLE_FLOATING_WINDOW = swFloatingWindow.isChecked();
                ENABLE_HOME_TO_FLOATING_WINDOW = swHomeToFloatingWindow.isChecked();
                ENABLE_VIDEO_CALLEE_PREVIEW = swCalleeVideoPreview.isChecked();
                ENABLE_VIDEO_VIRTUAL_BLUR = swVirtualBlur.isChecked();

                NECallEngine.sharedInstance()
                    .setCallConfig(
                        new NECallConfig.Builder()
                            .enableSwitchAudioConfirm(VIDEO_TO_AUDIO_CONFIRM)
                            .enableSwitchVideoConfirm(AUDIO_TO_VIDEO_CONFIRM)
                            .build());

                RTC_CHANNEL_UID = Long.parseLong(edtRtcChannelUId.getText().toString());
                SPUtils.getInstance().put("currentUserRtcUid", RTC_CHANNEL_UID);

                RTC_INIT_MODE = Integer.parseInt(edtRtcInitMode.getText().toString());
                SPUtils.getInstance().put("rtcInitMode", RTC_INIT_MODE);

                SUPPORT_VIDEO_TO_AUDIO = swSupportVideoToAudio.isChecked();
                SUPPORT_CLICK_SWITCH_CANVAS = swSupportSwitchCanvas.isChecked();
                CLOSE_VIDEO_TYPE = Integer.parseInt(edtCloseVideoType.getText().toString());
                CLOSE_VIDEO_LOCAL_URL = edtCloseVideoLocalUrl.getText().toString();
                CLOSE_VIDEO_REMOTE_URL = edtCloseVideoRemoteUrl.getText().toString();
                CLOSE_VIDEO_LOCAL_TIP = edtCloseVideoLocalTip.getText().toString();
                CLOSE_VIDEO_REMOTE_TIP = edtCloseVideoRemoteTip.getText().toString();

                Toast.makeText(SettingActivity.this, "设置成功", Toast.LENGTH_SHORT).show();
                finish();
              } catch (Exception e) {
                Toast.makeText(SettingActivity.this, "设置失败", Toast.LENGTH_SHORT).show();
              }
            });

    findViewById(R.id.bt_self_signal)
        .setOnClickListener(
            v -> startActivity(new Intent(SettingActivity.this, SelfSignalActivity.class)));
  }

  private void updateTip() {
    restartTip.setVisibility(NEED_RESTART ? View.VISIBLE : View.GONE);
  }

  public static void toInit() {
    RTC_TIME_OUT_SECOND = 30;

    GLOBAL_EXTRA_COPY = "";

    ENABLE_CALL_FOREGROUND_SERVICE = false;

    RTC_CHANNEL_NAME = "";

    ENABLE_AUDIO_CALL = false;
  }
}
