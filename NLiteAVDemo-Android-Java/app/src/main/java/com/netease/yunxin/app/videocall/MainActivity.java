// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.netease.lava.nertc.foreground.ForegroundKit;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.v2.V2NIMError;
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginListener;
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginService;
import com.netease.nimlib.sdk.v2.auth.enums.V2NIMLoginClientChange;
import com.netease.nimlib.sdk.v2.auth.enums.V2NIMLoginStatus;
import com.netease.nimlib.sdk.v2.auth.model.V2NIMKickedOfflineDetail;
import com.netease.nimlib.sdk.v2.auth.model.V2NIMLoginClient;
import com.netease.yunxin.app.videocall.login.model.AuthManager;
import com.netease.yunxin.app.videocall.login.ui.LoginActivity;
import com.netease.yunxin.app.videocall.nertc.biz.CallOrderManager;
import com.netease.yunxin.app.videocall.nertc.ui.CallModeType;
import com.netease.yunxin.app.videocall.nertc.ui.NERTCSelectCallUserActivity;
import com.netease.yunxin.app.videocall.nertc.ui.SettingActivity;
import com.netease.yunxin.nertc.ui.CallKitUI;

import java.util.Collections;
import java.util.List;

public class MainActivity extends AppCompatActivity {
  private static final int NOTIFICATION_PERMISSION_REQUEST_CODE = 1001;
  private TextView tvVersion;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    checkAndRequestNotificationPermission(this);
    initView();
    checkLogin();
    initG2();
  }

  @Override
  protected void onResume() {
    super.onResume();
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
  }

  private void initG2() {

  }

  private void checkLogin() {
    if (AuthManager.getInstance().isLogin()) {
      return;
    }

    //此处注册之后会立刻回调一次
    NIMClient.getService(V2NIMLoginService.class)
        .addLoginListener(
            new V2NIMLoginListener() {
              @Override
              public void onLoginStatus(V2NIMLoginStatus status) {
                if (status == V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINED) {
                  AuthManager.getInstance().setLogin(true);
                  CallOrderManager.getInstance().init();
                  SettingActivity.toInit();
                }
              }

              @Override
              public void onLoginFailed(V2NIMError error) {}

              @Override
              public void onKickedOffline(V2NIMKickedOfflineDetail detail) {}

              @Override
              public void onLoginClientChanged(
                  V2NIMLoginClientChange change, List<V2NIMLoginClient> clients) {}
            });
    if (NIMClient.getService(V2NIMLoginService.class).getLoginStatus()
        != V2NIMLoginStatus.V2NIM_LOGIN_STATUS_LOGINED) {
      if (AuthManager.getInstance().getUserModel() != null
          && !TextUtils.isEmpty(AuthManager.getInstance().getUserModel().imAccid)
          && !TextUtils.isEmpty(AuthManager.getInstance().getUserModel().imToken)) {
        NIMClient.getService(V2NIMLoginService.class)
            .login(
                AuthManager.getInstance().getUserModel().imAccid,
                AuthManager.getInstance().getUserModel().imToken,
                null,
                null,
                null);
      }
    }
  }

  private void initView() {
    ImageView ivAccountIcon = findViewById(R.id.iv_account);
    RelativeLayout rlyVideoCall = findViewById(R.id.rly_video_call);
    RelativeLayout rlyGroupCall = findViewById(R.id.rly_group_call);

    tvVersion = findViewById(R.id.tv_version);

    ivAccountIcon.setOnClickListener(
        view -> {
          if (AuthManager.getInstance().isLogin()) {
            showLogoutDialog();
          } else {
            LoginActivity.startLogin(this);
          }
        });

    rlyVideoCall.setOnClickListener(
        view -> {
          if (!AuthManager.getInstance().isLogin()) {
            LoginActivity.startLogin(this);
          } else {
            NERTCSelectCallUserActivity.startSelectUser(this, CallModeType.PSTN_1V1_AUDIO_CALL);
          }
        });

    rlyGroupCall.setOnClickListener(
        v -> {
          if (!AuthManager.getInstance().isLogin()) {
            LoginActivity.startLogin(this);
          } else {
            NERTCSelectCallUserActivity.startSelectUser(
                this,
                CallModeType.RTC_GROUP_CALL,
                Collections.singletonList(AuthManager.getInstance().getUserModel().imAccid));
          }
        });
    rlyGroupCall.setVisibility(View.VISIBLE);

    initVersionInfo();
  }

  private void initVersionInfo() {
    String versionInfo =
        "NIM sdk version:"
            + NIMClient.getSDKVersion()
            + "\nnertc sdk version:"
            + NERtc.version().versionName
            + "\ncallKit version:"
            + CallKitUI.INSTANCE.currentVersion();
    tvVersion.setText(versionInfo);
  }

  private void showLogoutDialog() {
    final AlertDialog.Builder confirmDialog = new AlertDialog.Builder(MainActivity.this);
    confirmDialog.setTitle("注销账户:" + AuthManager.getInstance().getUserModel().mobile);
    confirmDialog.setMessage("确认注销当前登录账号？");
    confirmDialog.setPositiveButton(
        "是",
        (dialog, which) -> {
          AuthManager.getInstance().logout();
          Toast.makeText(MainActivity.this, "已经退出登录", Toast.LENGTH_LONG).show();
        });
    confirmDialog.setNegativeButton("否", (dialog, which) -> {});

    confirmDialog.show();
  }

  private void checkAndRequestNotificationPermission(Context context) {
    // 检查是否需要请求通知权限
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.POST_NOTIFICATIONS)
          != PackageManager.PERMISSION_GRANTED) {
        // 请求权限
        ActivityCompat.requestPermissions(
            this,
            new String[] {Manifest.permission.POST_NOTIFICATIONS},
            NOTIFICATION_PERMISSION_REQUEST_CODE);
      }
    }
  }
}
