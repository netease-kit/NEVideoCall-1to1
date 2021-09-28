package com.netease.yunxin.app.videocall;

import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
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
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.yunxin.app.videocall.base.BaseService;
import com.netease.yunxin.app.videocall.login.model.LoginServiceManager;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.app.videocall.login.ui.LoginActivity;
import com.netease.yunxin.app.videocall.nertc.biz.CallOrderManager;
import com.netease.yunxin.app.videocall.nertc.ui.NERTCSelectCallUserActivity;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig;
import com.netease.yunxin.nertc.ui.CallKitUI;
import com.netease.yunxin.nertc.ui.CallKitUIOptions;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = MainActivity.class.getSimpleName();

    private ImageView ivAccountIcon;

    private RelativeLayout rlyVideoCall;

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
                            .notificationConfigFetcher(invitedInfo -> new CallKitNotificationConfig(R.mipmap.ic_launcher))
                            // 收到被叫时若 app 在后台，在恢复到前台时是否自动唤起被叫页面，默认为 true
                            .resumeBGInvitation(true)
                            // 请求 rtc token 服务，若非安全模式则不需设置
                            .rtcTokenService((uid, callback) -> requestRtcToken(BuildConfig.APP_KEY, uid, callback))
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

    /**
     * 请求 rtc token 服务
     *
     * @param appKey   rtc 对应的 AppKey
     * @param uid      用户加入 rtc 时的 id
     * @param callback 请求回调通知
     */
    private void requestRtcToken(String appKey, long uid, RequestCallback<String> callback) {
        //注册获取token的服务
        //在线上环境中，token的获取需要放到您的应用服务端完成，然后由服务器通过安全通道把token传递给客户端
        //Demo中使用的URL仅仅是demoserver，不要在您的应用中使用
        //详细请参考: http://dev.netease.im/docs?doc=server
        String demoServer = "https://nrtc.netease.im/demo/getChecksum.action";
        new Thread(() -> {
            try {
                String queryString = demoServer + "?uid=" +
                        uid + "&appkey=" + appKey;
                URL requestedUrl = new URL(queryString);
                HttpURLConnection connection = (HttpURLConnection) requestedUrl.openConnection();
                connection.setRequestMethod("POST");
                connection.setConnectTimeout(6000);
                connection.setReadTimeout(6000);
                if (connection.getResponseCode() != 200) {
                    callback.onFailed(connection.getResponseCode());
                    return;
                }
                String result = readFully(connection.getInputStream());
                ALog.d("Demo", result);
                if (TextUtils.isEmpty(result)) {
                    callback.onFailed(-1);
                    return;
                }
                org.json.JSONObject object = new org.json.JSONObject(result);
                int code = object.getInt("code");
                if (code != 200) {
                    callback.onFailed(code);
                }
                String token = object.getString("checksum");
                if (TextUtils.isEmpty(token)) {
                    callback.onFailed(-1);
                    return;
                }
                new Handler(getMainLooper()).post(() -> {
                    callback.onSuccess(token);
                });
            } catch (Exception e) {
                e.printStackTrace();
                callback.onException(e);
            }

        }).start();
    }

    private String readFully(InputStream inputStream) throws IOException {

        if (inputStream == null) {
            return "";
        }

        ByteArrayOutputStream byteArrayOutputStream;

        BufferedInputStream bufferedInputStream = new BufferedInputStream(inputStream);
        try {
            byteArrayOutputStream = new ByteArrayOutputStream();

            final byte[] buffer = new byte[1024];
            int available;

            while ((available = bufferedInputStream.read(buffer)) >= 0) {
                byteArrayOutputStream.write(buffer, 0, available);
            }

            return byteArrayOutputStream.toString();

        } finally {
            bufferedInputStream.close();
        }
    }

    private void checkLogin() {
        if (ProfileManager.getInstance().isLogin()) {
            return;
        }
        //此处注册之后会立刻回调一次
        NIMClient.getService(AuthServiceObserver.class).observeOnlineStatus(new Observer<StatusCode>() {
            @Override
            public void onEvent(StatusCode statusCode) {
                if (statusCode == StatusCode.LOGINED) {
                    ProfileManager.getInstance().setLogin(true);
                    CallOrderManager.getInstance().init();
                }
            }
        }, true);


    }

    private void initView() {
        ivAccountIcon = findViewById(R.id.iv_account);
        rlyVideoCall = findViewById(R.id.rly_video_call);
        tvVersion = findViewById(R.id.tv_version);

        ivAccountIcon.setOnClickListener(view -> {
            if (ProfileManager.getInstance().isLogin() && ProfileManager.getInstance().getUserModel() != null) {
                showLogoutDialog();
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
                    LoginServiceManager.getInstance().logout(new BaseService.ResponseCallBack<Void>() {
                        @Override
                        public void onSuccess(Void response) {
                            ToastUtils.showLong("已经退出登录");
                        }

                        @Override
                        public void onFail(int code) {

                        }
                    });
                });
        confirmDialog.setNegativeButton("否",
                (dialog, which) -> {

                });
        confirmDialog.show();
    }
}