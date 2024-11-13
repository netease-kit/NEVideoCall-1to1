// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.call.group.GroupCallHangupEvent;
import com.netease.yunxin.kit.call.group.GroupCallMember;
import com.netease.yunxin.kit.call.group.NEGroupCall;
import com.netease.yunxin.kit.call.group.NEGroupCallActionObserver;
import com.netease.yunxin.kit.call.group.NEGroupConstants;
import com.netease.yunxin.kit.call.group.NEGroupIncomingCallReceiver;
import com.netease.yunxin.kit.call.group.param.GroupAcceptParam;
import com.netease.yunxin.kit.call.group.param.GroupCallParam;
import com.netease.yunxin.kit.call.group.param.GroupHangupParam;
import com.netease.yunxin.kit.call.group.param.GroupInviteParam;
import com.netease.yunxin.kit.call.group.param.GroupJoinParam;
import com.netease.yunxin.kit.call.group.param.GroupPushParam;
import com.netease.yunxin.kit.call.group.param.GroupQueryCallInfoParam;
import com.netease.yunxin.kit.call.group.param.GroupQueryMembersParam;
import com.netease.yunxin.nertc.ui.CallKitUI;
import java.util.Arrays;
import java.util.List;

public class GroupSettingActivity extends AppCompatActivity {

  private TextView logView;

  private final NEGroupIncomingCallReceiver callReceiver =
      info -> inputLog("receive:onReceiveGroupInvitation:\n" + info);
  private final NEGroupCallActionObserver actionObserver =
      new NEGroupCallActionObserver() {
        @Override
        public void onMemberChanged(String callId, List<GroupCallMember> userList) {
          inputLog("receive:onMemberChanged:\n" + callId + "\n" + userList);
        }

        @Override
        public void onGroupCallHangup(GroupCallHangupEvent hangupEvent) {
          inputLog("receive:onGroupCallHangup:\n" + hangupEvent);
        }
      };

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_group_setting_layout);

    NEGroupCall.instance().configGroupIncomingReceiver(callReceiver, true);

    NEGroupCall.instance().configGroupActionObserver(actionObserver, true);

    try {
      logView = findViewById(R.id.tv_log_print);

      SwitchCompat swPush = findViewById(R.id.switch_group_push_on);
      EditText etPushContent = findViewById(R.id.edt_group_push);
      findViewById(R.id.btn_group_push_save)
          .setOnClickListener(
              v -> {
                NEGroupCall.instance()
                    .setPushConfigProviderForGroup(
                        info ->
                            new GroupPushParam(
                                swPush.isChecked()
                                    ? NEGroupConstants.PushMode.ON
                                    : NEGroupConstants.PushMode.OFF,
                                etPushContent.getText().toString(),
                                null,
                                null));
                Toast.makeText(GroupSettingActivity.this, "设置成功", Toast.LENGTH_SHORT).show();
                finish();
              });

      EditText etCallId = findViewById(R.id.edt_call_id);

      EditText etCalledAccIdList = findViewById(R.id.edt_called_id_list);

      EditText etCallHangupReason = findViewById(R.id.edt_call_reason);

      View btGroupCall = findViewById(R.id.btn_group_call);
      btGroupCall.setOnClickListener(
          v -> {
            String accIdListStr = etCalledAccIdList.getText().toString().trim();
            if (TextUtils.isEmpty(accIdListStr)) {
              return;
            }
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }

            GroupCallParam param =
                new GroupCallParam.Builder()
                    .callId(callId)
                    .callees(accIdListStr.split(","))
                    .build();

            NEGroupCall.instance().groupCall(param, result -> inputLog("groupCall:" + result));
          });

      View btGroupAccept = findViewById(R.id.btn_group_accept);
      btGroupAccept.setOnClickListener(
          v -> {
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }
            GroupAcceptParam param = new GroupAcceptParam(callId);
            NEGroupCall.instance().groupAccept(param, result -> inputLog("groupAccept:" + result));
          });

      View btGroupHangup = findViewById(R.id.btn_group_hangup);
      btGroupHangup.setOnClickListener(
          v -> {
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }
            GroupHangupParam param =
                new GroupHangupParam(callId, etCallHangupReason.getText().toString());
            NEGroupCall.instance().groupHangup(param, result -> inputLog("groupHangup:" + result));
          });

      View btGroupQueryMember = findViewById(R.id.btn_group_query_member);
      btGroupQueryMember.setOnClickListener(
          v -> {
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }
            GroupQueryMembersParam param = new GroupQueryMembersParam(callId);
            NEGroupCall.instance()
                .groupQueryMembers(param, result -> inputLog("groupQueryMembers:" + result));
          });

      View btGroupQueryInfo = findViewById(R.id.btn_group_query_info);
      btGroupQueryInfo.setOnClickListener(
          v -> {
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }
            GroupQueryCallInfoParam param = new GroupQueryCallInfoParam(callId);
            NEGroupCall.instance()
                .groupQueryCallInfo(param, result -> inputLog("groupQueryCallInfo:" + result));
          });

      View btGroupJoin = findViewById(R.id.btn_group_join);
      btGroupJoin.setOnClickListener(
          v -> {
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }
            GroupJoinParam param = new GroupJoinParam(callId);
            NEGroupCall.instance().groupJoin(param, result -> inputLog("groupJoin:" + result));
          });

      View btGroupInvite = findViewById(R.id.btn_group_invite);
      btGroupInvite.setOnClickListener(
          v -> {
            String accIdListStr = etCalledAccIdList.getText().toString().trim();
            if (TextUtils.isEmpty(accIdListStr)) {
              return;
            }
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }

            GroupInviteParam param =
                new GroupInviteParam(callId, Arrays.asList(accIdListStr.split(",")));

            NEGroupCall.instance().groupInvite(param, result -> inputLog("groupInvite:" + result));
          });

      View btGroupJoinWithUI = findViewById(R.id.btn_group_join_with_ui);
      btGroupJoinWithUI.setOnClickListener(
          v -> {
            String callId = etCallId.getText().toString();
            if (TextUtils.isEmpty(callId)) {
              callId = null;
            }
            GroupJoinParam param = new GroupJoinParam(callId);
            CallKitUI.joinGroupCall(GroupSettingActivity.this, param);
          });

      View btGroupCurrentCallInfo = findViewById(R.id.btn_group_current_call_info);
      btGroupCurrentCallInfo.setOnClickListener(
          v -> inputLog("currentGroupCallInfo:" + NEGroupCall.instance().currentGroupCallInfo()));

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

  @Override
  protected void onPause() {
    super.onPause();
    if (isFinishing()) {
      NEGroupCall.instance().configGroupIncomingReceiver(callReceiver, false);
      NEGroupCall.instance().configGroupActionObserver(actionObserver, false);
    }
  }

  private StringBuilder builder = new StringBuilder();

  private void inputLog(String logStr) {
    builder.append(logStr).append("\n");
    logView.setText(builder.toString());
  }
}
