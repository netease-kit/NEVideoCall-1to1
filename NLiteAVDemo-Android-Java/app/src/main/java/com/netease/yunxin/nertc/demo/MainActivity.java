package com.netease.yunxin.nertc.demo;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.util.AppUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.videocall.demo.R;
import com.netease.yunxin.nertc.baselib.BaseService;
import com.netease.yunxin.nertc.baselib.NativeConfig;
import com.netease.yunxin.nertc.login.model.LoginServiceManager;
import com.netease.yunxin.nertc.login.model.ProfileManager;
import com.netease.yunxin.nertc.login.model.UserModel;
import com.netease.yunxin.nertc.login.ui.LoginActivity;
import com.netease.yunxin.nertc.nertcvideocall.model.NERTCVideoCall;
import com.netease.yunxin.nertc.nertcvideocall.model.UIService;
import com.netease.yunxin.nertc.nertcvideocall.model.VideoCallOptions;
import com.netease.yunxin.nertc.nertcvideocall.model.impl.UIServiceManager;
import com.netease.yunxin.nertc.nertcvideocall.utils.CallParams;
import com.netease.yunxin.nertc.nertcvideocalldemo.ui.NERTCSelectCallUserActivity;
import com.netease.yunxin.nertc.nertcvideocalldemo.ui.NERTCVideoCallActivity;

import org.json.JSONArray;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;

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

                    try {

                        String appKey = NativeConfig.getAppKey();
                        UserModel userModel = ProfileManager.getInstance().getUserModel();
                        String imAccount = userModel.imAccid;
                        String imToken = userModel.imToken;

                        NERTCVideoCall.sharedInstance().setupAppKey(getApplicationContext(), appKey, new VideoCallOptions(null, new UIService() {
                            @Override
                            public Class getOneToOneAudioChat() {
                                return NERTCVideoCallActivity.class;
                            }

                            @Override
                            public Class getOneToOneVideoChat() {
                                return NERTCVideoCallActivity.class;
                            }

                            @Override
                            public Class getGroupVideoChat() {
                                return null;
                            }

                            @Override
                            public int getNotificationIcon() {
                                return R.drawable.video_call_icon;
                            }

                            @Override
                            public int getNotificationSmallIcon() {
                                return R.drawable.video_call_icon;
                            }
                        }, ProfileManager.getInstance()));

                        NERTCVideoCall.sharedInstance().login(imAccount, imToken, new RequestCallback<LoginInfo>() {
                            @Override
                            public void onSuccess(LoginInfo param) {

                            }

                            @Override
                            public void onFailed(int code) {

                            }

                            @Override
                            public void onException(Throwable exception) {

                            }
                        });

                        //注册获取token的服务
                        //在线上环境中，token的获取需要放到您的应用服务端完成，然后由服务器通过安全通道把token传递给客户端
                        //Demo中使用的URL仅仅是demoserver，不要在您的应用中使用
                        //详细请参考: http://dev.netease.im/docs?doc=server
                        NERTCVideoCall.sharedInstance().setTokenService((uid, callback) -> {
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
                                    if (connection.getResponseCode() == 200) {
                                        String result = readFully(connection.getInputStream());
                                        Log.d("Demo", result);
                                        if (!TextUtils.isEmpty(result)) {
                                            org.json.JSONObject object = new org.json.JSONObject(result);
                                            int code = object.getInt("code");
                                            if (code == 200) {
                                                String token = object.getString("checksum");
                                                if (!TextUtils.isEmpty(token)) {
                                                    new Handler(getMainLooper()).post(() -> {
                                                        callback.onSuccess(token);
                                                    });
                                                    return;
                                                }
                                            }
                                        }
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }

                                new Handler(getMainLooper()).post(() -> {
                                    //fixme 此处因为demo可以走非安全模式所以返回null，线上环境请在此处走 onFailed 逻辑
                                    callback.onSuccess(null);
//                                    callback.onFailed(-1);
                                });
                            }).start();
                        });

                        Intent intent = getIntent();
                        Log.d(TAG, String.format("onNotificationClicked INVENT_NOTIFICATION_FLAG:%s", intent.hasExtra(CallParams.INVENT_NOTIFICATION_FLAG)));
                        if (intent.hasExtra(CallParams.INVENT_NOTIFICATION_FLAG) && intent.getBooleanExtra(CallParams.INVENT_NOTIFICATION_FLAG, false)) {
                            Bundle extraIntent = intent.getBundleExtra(CallParams.INVENT_NOTIFICATION_EXTRA);
                            intent.removeExtra(CallParams.INVENT_NOTIFICATION_FLAG);
                            intent.removeExtra(CallParams.INVENT_NOTIFICATION_EXTRA);

                            Intent avChatIntent = new Intent();
                            for (String key : CallParams.CallParamKeys) {
                                avChatIntent.putExtra(key, extraIntent.getString(key));
                            }

                            String callType = extraIntent.getString(CallParams.INVENT_CALL_TYPE);
                            String channelType = extraIntent.getString(CallParams.INVENT_CHANNEL_TYPE);
                            Log.d(TAG, String.format("onNotificationClicked callType:%s channelType:%s", callType, channelType));

                            if (TextUtils.equals(String.valueOf(CallParams.CallType.TEAM), callType)) {
                                avChatIntent.setClass(MainActivity.this, UIServiceManager.getInstance().getUiService().getGroupVideoChat());

                                try {
                                    String userIdsBase64 = extraIntent.getString(CallParams.INVENT_USER_IDS);
                                    String userIdsJson = new String(Base64.decode(userIdsBase64, Base64.DEFAULT));
                                    JSONArray jsonArray = new JSONArray(userIdsJson);

                                    ArrayList<String> userIds = new ArrayList<>();
                                    for (int i = 0; i < jsonArray.length(); i++) {
                                        String userId = jsonArray.getString(i);
                                        userIds.add(userId);
                                    }

                                    String fromAccountId = extraIntent.getString(CallParams.INVENT_FROM_ACCOUNT_ID);
                                    userIds.add(fromAccountId);

                                    avChatIntent.putExtra(CallParams.INVENT_USER_IDS, userIds);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    Log.e(TAG, "onNotificationClicked Exception:" + e);
                                }
                            } else {
                                if (TextUtils.equals(String.valueOf(ChannelType.AUDIO.getValue()), channelType)) {
                                    avChatIntent.setClass(MainActivity.this, UIServiceManager.getInstance().getUiService().getOneToOneAudioChat());
                                } else {
                                    avChatIntent.setClass(MainActivity.this, UIServiceManager.getInstance().getUiService().getOneToOneVideoChat());
                                }
                            }

                            avChatIntent.putExtra(CallParams.INVENT_CALL_RECEIVED, true);
                            startActivity(avChatIntent);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }, true);
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
                } else if (statusCode == StatusCode.UNLOGIN) {
                    ProfileManager.getInstance().setLogin(false);
                    //NIM 初始化的时候如果有用户信息会自动登录，此处无需根据token再手动登录
//                    LoginServiceManager.getInstance().loginWithToken(new BaseService.ResponseCallBack<Void>() {
//                        @Override
//                        public void onSuccess(Void response) {
//                            ProfileManager.getInstance().setLogin(true);
//                            ToastUtils.showLong("登录成功");
//                        }
//
//                        @Override
//                        public void onFail(int code) {
//                            ToastUtils.showLong("登录失败");
//                        }
//                    });
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
        String versionInfo = "demo version:" + AppUtils.getAppVersionName() + "\nnertc sdk version:" +
                NERtc.version().versionName;
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