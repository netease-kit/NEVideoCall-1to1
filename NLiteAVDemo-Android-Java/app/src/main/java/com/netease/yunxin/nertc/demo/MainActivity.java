package com.netease.yunxin.nertc.demo;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.content.DialogInterface;
import android.os.Bundle;
import android.provider.CallLog;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.blankj.utilcode.util.AppUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.auth.AuthServiceObserver;
import com.netease.yunxin.nertc.baselib.BaseService;
import com.netease.yunxin.nertc.login.model.LoginServiceManager;
import com.netease.yunxin.nertc.login.model.ProfileManager;
import com.netease.yunxin.nertc.login.ui.LoginActivity;
import com.netease.yunxin.nertc.nertcvideocalldemo.ui.NERTCSelectCallUserActivity;

public class MainActivity extends AppCompatActivity {

    private ImageView ivAccountIcon;

    private RelativeLayout rlyVideoCall;

    private TextView tvVersion;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();
        checkLogin();
    }

    @Override
    protected void onResume() {
        super.onResume();
        CallService.start(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        CallService.stop(this);
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