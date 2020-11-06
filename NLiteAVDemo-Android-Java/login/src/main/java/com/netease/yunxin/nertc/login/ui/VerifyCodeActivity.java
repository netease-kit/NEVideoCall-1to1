package com.netease.yunxin.nertc.login.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.videocall.demo.login.R;
import com.netease.yunxin.nertc.baselib.BaseService;
import com.netease.yunxin.nertc.login.model.LoginServiceManager;
import com.netease.yunxin.nertc.login.ui.view.VerifyCodeView;

public class VerifyCodeActivity extends AppCompatActivity {

    public static final String PHONE_NUMBER = "phone_number";

    private VerifyCodeView verifyCodeView;//验证码输入框

    private TextView tvMsmComment;

    private Button btnNext;

    private TextView tvTimeCountDown;

    private String phoneNumber;

    private CountDownTimer countDownTimer;

    private TextView tvResendMsm;

    public static void startVerifyCode(Context context, String phoneNumber) {
        Intent intent = new Intent();
        intent.setClass(context, VerifyCodeActivity.class);
        intent.putExtra(PHONE_NUMBER, phoneNumber);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.verify_code_layout);
        initView();
        initData();
    }

    private void initView() {
        verifyCodeView = findViewById(R.id.vcv_sms);
        tvMsmComment = findViewById(R.id.tv_msm_comment);
        btnNext = findViewById(R.id.btn_next);
        tvTimeCountDown = findViewById(R.id.tv_time_discount);
        tvResendMsm = findViewById(R.id.tv_resend_msm);
    }

    private void initData() {
        phoneNumber = getIntent().getStringExtra(PHONE_NUMBER);
        tvMsmComment.setText("验证码已经发送至 +86-" + phoneNumber + "，请在下方输入验证码");
        btnNext.setOnClickListener(v -> {
            String smsCode = verifyCodeView.getResult();
            if (!TextUtils.isEmpty(smsCode)) {
                login(smsCode);
            }
        });
        tvTimeCountDown.setOnClickListener(v -> {
            reSendMsm();
        });

        initCountDown();
    }

    private void initCountDown() {
        tvTimeCountDown.setText("60s");
        tvResendMsm.setVisibility(View.VISIBLE);
        tvTimeCountDown.setEnabled(false);

        countDownTimer = new CountDownTimer(60000, 1000) {
            @Override
            public void onTick(long l) {
                tvTimeCountDown.setText((l / 1000) + "s");
            }

            @Override
            public void onFinish() {
                tvTimeCountDown.setText("重新发送");
                tvTimeCountDown.setEnabled(true);
                tvResendMsm.setVisibility(View.GONE);
            }
        };

        countDownTimer.start();
    }

    private void reSendMsm() {
        if (!TextUtils.isEmpty(phoneNumber)) {
            LoginServiceManager.getInstance().sendMessage(phoneNumber, new BaseService.ResponseCallBack<Void>() {

                @Override
                public void onSuccess(Void response) {
                    ToastUtils.showLong("验证码重新发送成功");
                    initCountDown();
                }

                @Override
                public void onFail(int code) {
                    ToastUtils.showLong("验证码重新发送失败");
                }
            });
        }
    }

    private void login(String msmCode) {
        if (!TextUtils.isEmpty(phoneNumber) && !TextUtils.isEmpty(msmCode)) {
            LoginServiceManager.getInstance().loginWithSms(phoneNumber, msmCode, new BaseService.ResponseCallBack<Void>() {
                @Override
                public void onSuccess(Void response) {
                    ToastUtils.showLong("登录成功");
                    startMainActivity();
                }

                @Override
                public void onFail(int code) {
                    ToastUtils.showLong("登录失败");
                }
            });
        }
    }

    private void startMainActivity() {
        Intent intent = new Intent();
        intent.addCategory("android.intent.category.DEFAULT");
        intent.setAction("com.nertc.g2.action.main");
        startActivity(intent);
        finish();
    }

}
