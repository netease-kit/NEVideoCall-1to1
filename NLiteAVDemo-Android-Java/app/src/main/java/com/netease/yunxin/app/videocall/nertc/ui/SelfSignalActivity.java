// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui;

import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.nimlib.sdk.v2.avsignalling.V2NIMSignallingListener;
import com.netease.nimlib.sdk.v2.avsignalling.config.V2NIMSignallingConfig;
import com.netease.nimlib.sdk.v2.avsignalling.config.V2NIMSignallingPushConfig;
import com.netease.nimlib.sdk.v2.avsignalling.enums.V2NIMSignallingChannelType;
import com.netease.nimlib.sdk.v2.avsignalling.model.V2NIMSignallingChannelInfo;
import com.netease.nimlib.sdk.v2.avsignalling.model.V2NIMSignallingEvent;
import com.netease.nimlib.sdk.v2.avsignalling.model.V2NIMSignallingRoomInfo;
import com.netease.nimlib.sdk.v2.avsignalling.params.V2NIMSignallingAcceptInviteParams;
import com.netease.nimlib.sdk.v2.avsignalling.params.V2NIMSignallingCallParams;
import com.netease.nimlib.sdk.v2.avsignalling.params.V2NIMSignallingCancelInviteParams;
import com.netease.nimlib.sdk.v2.avsignalling.params.V2NIMSignallingInviteParams;
import com.netease.nimlib.sdk.v2.avsignalling.params.V2NIMSignallingJoinParams;
import com.netease.nimlib.sdk.v2.avsignalling.params.V2NIMSignallingRejectInviteParams;
import com.netease.nimlib.sdk.v2.avsignalling.result.V2NIMSignallingCallResult;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.call.common.NimSignallingWrapper;
import com.netease.yunxin.kit.call.common.callback.Callback;
import java.util.Collections;
import java.util.List;

public class SelfSignalActivity extends AppCompatActivity {
  private static final String TAG = "SelfSignalActivity";
  private TextView logView;

  private void handleMessage(List<V2NIMSignallingEvent> events) {
    if (events != null) {
      for (V2NIMSignallingEvent event : events) {
        String requestId = "";
        requestId = event.getRequestId();
        inputLog(
            "receive:\n"
                + "channelId-"
                + event.getChannelInfo().getChannelId()
                + ",requestId-"
                + requestId
                + ",type-"
                + event.getEventType());
      }
    }
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_self_signal_layout);

    NimSignallingWrapper.addSignallingListener(
        new V2NIMSignallingListener() {
          @Override
          public void onOnlineEvent(V2NIMSignallingEvent event) {
            ALog.i(TAG, "onOnlineEvent " + event.getEventType());
            handleMessage(Collections.singletonList(event));
          }

          @Override
          public void onOfflineEvent(List<V2NIMSignallingEvent> events) {
            ALog.i(TAG, "onOfflineEvent " + events.size());
            handleMessage(events);
          }

          @Override
          public void onMultiClientEvent(V2NIMSignallingEvent event) {
            ALog.i(TAG, "onMultiClientEvent " + event.getEventType());
          }

          @Override
          public void onSyncRoomInfoList(List<V2NIMSignallingRoomInfo> channelRooms) {
            ALog.i(TAG, "onSyncRoomInfoList " + channelRooms.size());
          }
        });

    try {
      logView = findViewById(R.id.tv_log_print);

      EditText etChannelName = findViewById(R.id.channel_name);

      View btCreateChannel = findViewById(R.id.btn_create_channel);
      btCreateChannel.setOnClickListener(
          v ->
              NimSignallingWrapper.createRoom(
                  V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO,
                  etChannelName.getText().toString(),
                  null,
                  new Callback<V2NIMSignallingChannelInfo>() {
                    @Override
                    public void onResult(int code, String msg, V2NIMSignallingChannelInfo result) {
                      inputLog(
                          "create channel: code"
                              + ",channelId-"
                              + result.getChannelId()
                              + ",channelName-"
                              + result.getChannelName());
                    }
                  }));

      EditText etAccountId = findViewById(R.id.account_id);

      View btCall = findViewById(R.id.btn_call);
      btCall.setOnClickListener(
          v -> {
            V2NIMSignallingPushConfig pushConfig =
                new V2NIMSignallingPushConfig(
                    true, "signalTitle", "signalContent", "signalPayload");
            pushConfig.setPushEnabled(true);
            V2NIMSignallingCallParams callParams =
                new V2NIMSignallingCallParams.Builder(
                        etAccountId.getText().toString(),
                        String.valueOf(System.currentTimeMillis()),
                        V2NIMSignallingChannelType.V2NIM_SIGNALLING_CHANNEL_TYPE_VIDEO)
                    .pushConfig(pushConfig)
                    .build();
            NimSignallingWrapper.call(
                callParams,
                new Callback<V2NIMSignallingCallResult>() {
                  @Override
                  public void onResult(int code, String msg, V2NIMSignallingCallResult result) {
                    inputLog(
                        "call:"
                            + code
                            + ",channelId-"
                            + result.getRoomInfo().getChannelInfo().getChannelId()
                            + ",channelName-"
                            + result.getRoomInfo().getChannelInfo().getChannelName());
                  }
                });
          });

      EditText etChannelId = findViewById(R.id.channel_id);
      EditText etCustom = findViewById(R.id.edt_custom_room);

      View btJoin = findViewById(R.id.btn_join_channel);
      btJoin.setOnClickListener(
          v -> {
            V2NIMSignallingConfig config = new V2NIMSignallingConfig();
            config.setOfflineEnabled(true);
            config.setSelfUid(0L);
            V2NIMSignallingJoinParams params =
                new V2NIMSignallingJoinParams.Builder(etChannelId.getText().toString())
                    .serverExtension(etCustom.getText().toString())
                    .signallingConfig(config)
                    .build();
            NimSignallingWrapper.joinRoom(
                params,
                new Callback<V2NIMSignallingRoomInfo>() {
                  @Override
                  public void onResult(int code, String msg, V2NIMSignallingRoomInfo result) {
                    inputLog(
                        "join:"
                            + code
                            + ",channelId-"
                            + result.getChannelInfo().getChannelId()
                            + ",channelName-"
                            + result.getChannelInfo().getChannelName());
                  }
                });
          });

      View btLeave = findViewById(R.id.btn_leave_channel);
      btLeave.setOnClickListener(
          v -> {
            NimSignallingWrapper.leaveRoom(
                etChannelId.getText().toString(),
                true,
                etCustom.getText().toString(),
                new Callback<Void>() {
                  @Override
                  public void onResult(int code, String msg, Void unused) {
                    inputLog("leave:" + code);
                  }
                });
          });

      View btClose = findViewById(R.id.btn_close_channel);
      btClose.setOnClickListener(
          v -> {
            NimSignallingWrapper.closeRoom(
                etChannelId.getText().toString(),
                true,
                etCustom.getText().toString(),
                new Callback<Void>() {
                  @Override
                  public void onResult(int code, String msg, Void unused) {
                    inputLog("close:" + code);
                  }
                });
          });

      EditText etOtherAccountId = findViewById(R.id.edt_other_id);
      EditText etCustomInvite = findViewById(R.id.edt_custom_invite);
      EditText etRequestId = findViewById(R.id.edt_request_id);

      View btInvite = findViewById(R.id.btn_invite_other);
      btInvite.setOnClickListener(
          v -> {
            V2NIMSignallingInviteParams params =
                new V2NIMSignallingInviteParams.Builder(
                        etChannelId.getText().toString(),
                        etOtherAccountId.getText().toString(),
                        etRequestId.getText().toString())
                    .pushConfig(
                        new V2NIMSignallingPushConfig(
                            true, "signalTitle", "signalContent", "signalPayload"))
                    .serverExtension(etCustomInvite.getText().toString())
                    .build();

            NimSignallingWrapper.invite(
                params,
                new Callback<Void>() {
                  @Override
                  public void onResult(int code, String msg, Void unused) {
                    inputLog(
                        "invite:"
                            + code
                            + ",channelId-"
                            + etChannelId.getText().toString()
                            + ",requestId-"
                            + etRequestId.getText().toString()
                            + ",user-"
                            + etOtherAccountId.getText().toString());
                  }
                });
          });

      View btAccept = findViewById(R.id.btn_accept_invite);
      btAccept.setOnClickListener(
          v -> {
            V2NIMSignallingAcceptInviteParams params =
                new V2NIMSignallingAcceptInviteParams.Builder(
                        etChannelId.getText().toString(),
                        etOtherAccountId.getText().toString(),
                        etRequestId.getText().toString())
                    .serverExtension(etCustomInvite.getText().toString())
                    .build();

            NimSignallingWrapper.acceptInvite(
                params,
                new Callback<Void>() {
                  @Override
                  public void onResult(int code, String msg, Void unused) {
                    inputLog(
                        "accept:"
                            + code
                            + ",channelId-"
                            + etChannelId.getText().toString()
                            + ",requestId-"
                            + etRequestId.getText().toString()
                            + ",user-"
                            + etOtherAccountId.getText().toString());
                  }
                });
          });

      View btReject = findViewById(R.id.btn_reject_invite);
      btReject.setOnClickListener(
          v -> {
            V2NIMSignallingRejectInviteParams params =
                new V2NIMSignallingRejectInviteParams.Builder(
                        etChannelId.getText().toString(),
                        etOtherAccountId.getText().toString(),
                        etRequestId.getText().toString())
                    .serverExtension(etCustomInvite.getText().toString())
                    .offlineEnabled(true)
                    .build();

            NimSignallingWrapper.rejectInvite(
                params,
                new Callback<Void>() {
                  @Override
                  public void onResult(int code, String msg, Void unused) {
                    inputLog(
                        "accept:"
                            + code
                            + ",channelId-"
                            + etChannelId.getText().toString()
                            + ",requestId-"
                            + etRequestId.getText().toString()
                            + ",user-"
                            + etOtherAccountId.getText().toString());
                  }
                });
          });

      View btCancel = findViewById(R.id.btn_cancel_invite_other);
      btCancel.setOnClickListener(
          v -> {
            V2NIMSignallingCancelInviteParams params =
                new V2NIMSignallingCancelInviteParams.Builder(
                        etChannelId.getText().toString(),
                        etOtherAccountId.getText().toString(),
                        etRequestId.getText().toString())
                    .serverExtension(etCustomInvite.getText().toString())
                    .offlineEnabled(true)
                    .build();

            NimSignallingWrapper.cancelInvite(
                params,
                new Callback<Void>() {
                  @Override
                  public void onResult(int code, String msg, Void unused) {
                    inputLog(
                        "accept:"
                            + code
                            + ",channelId-"
                            + etChannelId.getText().toString()
                            + ",requestId-"
                            + etRequestId.getText().toString()
                            + ",user-"
                            + etOtherAccountId.getText().toString());
                  }
                });
          });

      View btControl = findViewById(R.id.btn_send_ctrl);
      btControl.setOnClickListener(
          v -> {
            NimSignallingWrapper.sendControl(
                etChannelId.getText().toString(),
                etOtherAccountId.getText().toString(),
                etCustomInvite.getText().toString(),
                new Callback<Void>() {
                  @Override
                  public void onResult(int code, String msg, Void unused) {
                    inputLog(
                        "accept:"
                            + code
                            + ",channelId-"
                            + etChannelId.getText().toString()
                            + ",user-"
                            + etOtherAccountId.getText().toString());
                  }
                });
          });

      View btClear = findViewById(R.id.btn_clear_log);
      btClear.setOnClickListener(
          v -> {
            builder = new StringBuilder();
            logView.setText(builder.toString());
          });
    } catch (Exception exception) {
      ALog.e("SelfSignalActivity", "exception " + exception);
    }
  }

  private StringBuilder builder = new StringBuilder();

  private void inputLog(String logStr) {
    builder.append(logStr).append("\n");
    logView.setText(builder.toString());
  }
}
