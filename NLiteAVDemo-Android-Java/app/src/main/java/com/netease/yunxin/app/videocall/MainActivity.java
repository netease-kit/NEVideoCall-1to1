package com.netease.yunxin.app.videocall;

import android.os.Bundle;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.app.videocall.login.ui.LoginActivity;
import com.netease.yunxin.app.videocall.nertc.biz.CallOrderManager;
import com.netease.yunxin.app.videocall.nertc.ui.NERTCSelectCallUserActivity;
import com.netease.yunxin.nertc.ui.CallKitUI;
import com.netease.yunxin.nertc.ui.CallKitUIOptions;

public class MainActivity extends AppCompatActivity {

  private TextView tvVersion;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
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

    NIMClient.getService(AuthServiceObserver.class).observeOnlineStatus((Observer<StatusCode>) statusCode -> {
      if (statusCode == StatusCode.LOGINED) {

        CallKitUIOptions options = new CallKitUIOptions.Builder()
            // 音视频通话 sdk appKey，用于通话中使用
            .rtcAppKey(BuildConfig.APP_KEY)
            // 当前用户 accId
            .currentUserAccId(ProfileManager.getInstance().getUserModel().imAccid)
            // 通话接听成功的超时时间单位 毫秒，默认30s
            .timeOutMillisecond(30 * 1000L)
            // 当系统版本为 Android Q及以上时，若应用在后台系统限制不直接展示页面
            // 而是展示 notification，通过点击 notification 跳转呼叫页面
            // 此处为 notification 相关配置，如图标，提示语等。
            .notificationConfigFetcher(new SelfNotificationConfigFetcher())
            // 收到被叫时若 app 在后台，在恢复到前台时是否自动唤起被叫页面，默认为 true
            .resumeBGInvitation(true)
            // 设置初始化 rtc sdk 相关配置，按照所需进行配置
            .rtcSdkOption(new NERtcOption())
            // 设置用户信息
            .userInfoHelper(new SelfUserInfoHelper())
            // 自定义通话页面
            .p2pAudioActivity(TestActivity.class)
            .p2pVideoActivity(TestActivity.class)
            .build();
        // 若重复初始化会销毁之前的初始化实例，重新初始化
        CallKitUI.init(getApplicationContext(), options);
      }
    }, true);
  }

  private void checkLogin() {
    if (ProfileManager.getInstance().isLogin()) {
      return;
    }
    //此处注册之后会立刻回调一次
    NIMClient.getService(AuthServiceObserver.class).observeOnlineStatus((Observer<StatusCode>) statusCode -> {
      if (statusCode == StatusCode.LOGINED) {
        ProfileManager.getInstance().setLogin(true);
        CallOrderManager.getInstance().init();
      }
    }, true);


  }

  private void initView() {
    ImageView ivAccountIcon = findViewById(R.id.iv_account);
    RelativeLayout rlyVideoCall = findViewById(R.id.rly_video_call);
    tvVersion = findViewById(R.id.tv_version);

    ivAccountIcon.setOnClickListener(view -> {
      if (ProfileManager.getInstance().isLogin()) {
        showLogoutDialog();
      } else {
        LoginActivity.startLogin(this);
      }
    });

    rlyVideoCall.setOnClickListener(view -> {
      if (!ProfileManager.getInstance().isLogin()) {
        LoginActivity.startLogin(this);
      } else {
        NERTCSelectCallUserActivity.startSelectUser(this);
      }
    });

    initVersionInfo();
  }

  private void initVersionInfo() {
    String versionInfo = "NIM sdk version:" + NIMClient.getSDKVersion() + "\nnertc sdk version:" +
        NERtc.version().versionName + "\ncallKit version:" + CallKitUI.INSTANCE.currentVersion();
    tvVersion.setText(versionInfo);
  }

  private void showLogoutDialog() {
    final AlertDialog.Builder confirmDialog =
        new AlertDialog.Builder(MainActivity.this);
    confirmDialog.setTitle("注销账户:" + ProfileManager.getInstance().getUserModel().mobile);
    confirmDialog.setMessage("确认注销当前登录账号？");
    confirmDialog.setPositiveButton("是",
        (dialog, which) -> {
          ProfileManager.getInstance().logout();
          Toast.makeText(MainActivity.this, "已经退出登录", Toast.LENGTH_SHORT).show();
        });
    confirmDialog.setNegativeButton("否",
        (dialog, which) -> {

        });
    confirmDialog.show();
  }
}