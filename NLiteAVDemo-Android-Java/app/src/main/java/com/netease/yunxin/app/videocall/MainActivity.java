package com.netease.yunxin.app.videocall;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcEx;
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

    private static final String TAG = MainActivity.class.getSimpleName();

    private TextView tvVersion;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();
        checkLogin();
        initG2();
        dumpTest();
    }

    private void dumpTest() {
        if (BuildConfig.DEBUG) {
            findViewById(R.id.btn).setOnClickListener(v -> {
                ToastUtils.showLong("开始dump音频");
                NERtcEx.getInstance().startAudioDump();
            });
            findViewById(R.id.btn2).setOnClickListener(v -> {
                ToastUtils.showLong("dump已结束，请到/sdcard/Android/data/com.netease.videocall.demo/files/dump目录查看dump文件");
                NERtcEx.getInstance().stopAudioDump();
            });
        } else {
            findViewById(R.id.btn).setVisibility(View.GONE);
            findViewById(R.id.btn2).setVisibility(View.GONE);
        }
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

        NIMClient.getService(AuthServiceObserver.class).observeOnlineStatus(new Observer<StatusCode>() {
            @Override
            public void onEvent(StatusCode statusCode) {
                if (statusCode == StatusCode.LOGINED) {
                    NIMClient.getService(AuthServiceObserver.class).observeOnlineStatus(this, false);

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
                            // 请求 rtc token 服务，若非安全模式不需设置，安全模式按照官网实现 token 服务通过如下接口设置回组件
//                            .rtcTokenService(new TokenService() {
//                                @Override
//                                public void getToken(long uid, RequestCallback<String> callback) {
//                                    Result result = network.requestToken(uid);
//                                    if (result.success) {
//                                        callback.onSuccess(result.token);
//                                    } else if (result.exception != null) {
//                                        callback.onException(result.exception);
//                                    } else {
//                                        callback.onFailed(result.code);
//                                    }
//                                }
//                            })
                            // 设置初始化 rtc sdk 相关配置，按照所需进行配置
                            .rtcSdkOption(new NERtcOption())
                            // 设置用户信息
                            .userInfoHelper(new SelfUserInfoHelper())
                            .build();
                    // 若重复初始化会销毁之前的初始化实例，重新初始化
                    CallKitUI.init(getApplicationContext(), options);
                }
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
                    ToastUtils.showLong("已经退出登录");
                });
        confirmDialog.setNegativeButton("否",
                (dialog, which) -> {

                });
        confirmDialog.show();
    }
}