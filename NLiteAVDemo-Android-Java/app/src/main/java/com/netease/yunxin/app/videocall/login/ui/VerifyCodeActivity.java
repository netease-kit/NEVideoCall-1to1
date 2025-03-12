// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.login.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.base.BaseService;
import com.netease.yunxin.app.videocall.login.model.LoginServiceManager;
import com.netease.yunxin.app.videocall.login.ui.view.VerifyCodeView;
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils;

public class VerifyCodeActivity extends AppCompatActivity {

    public static final String PHONE_NUMBER = "phone_number";

    private VerifyCodeView verifyCodeView; //验证码输入框

    private TextView tvMsmComment;

    private Button btnNext;

    private TextView tvTimeCountDown;

    private String phoneNumber;

    private CountDownTimer countDownTimer;

    private TextView tvResendMsm;

    private static final int SMS_CODE_LENGTH = 4;
    private static final int THOUSAND_MS = 1000;
    private static final int SIXTY_THOUSAND_MS = 60000;

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
        tvMsmComment.setText(
            getString(R.string.login_sms_code_has_been_sent)
                + phoneNumber
                + getString(R.string.login_please_input_sms_code));
        btnNext.setOnClickListener(
            v -> {
                if (!NetworkUtils.isConnected()) {
                    Toast.makeText(
                            VerifyCodeActivity.this,
                            R.string.network_connect_error_please_try_again,
                            Toast.LENGTH_SHORT)
                        .show();
                    return;
                }
                String smsCode = verifyCodeView.getResult();
                if (!TextUtils.isEmpty(smsCode) && smsCode.length() == SMS_CODE_LENGTH) {
                    login(smsCode);
                } else {
                    Toast.makeText(
                            VerifyCodeActivity.this,
                            R.string.login_please_input_correct_sms_code,
                            Toast.LENGTH_SHORT)
                        .show();
                }
            });
        tvTimeCountDown.setOnClickListener(
            v -> {
                reSendMsm();
            });

        initCountDown();
    }

    private void initCountDown() {
        tvTimeCountDown.setText(R.string.sixty_second);
        tvResendMsm.setVisibility(View.VISIBLE);
        tvTimeCountDown.setEnabled(false);

        countDownTimer =
            new CountDownTimer(SIXTY_THOUSAND_MS, THOUSAND_MS) {
                @Override
                public void onTick(long l) {
                    tvTimeCountDown.setText((l / THOUSAND_MS) + getString(R.string.login_second));
                }

                @Override
                public void onFinish() {
                    tvTimeCountDown.setText(R.string.login_resend);
                    tvTimeCountDown.setEnabled(true);
                    tvResendMsm.setVisibility(View.GONE);
                }
            };

        countDownTimer.start();
    }

    private void reSendMsm() {
        if (!NetworkUtils.isConnected()) {
            Toast.makeText(
                    VerifyCodeActivity.this,
                    R.string.network_connect_error_please_try_again,
                    Toast.LENGTH_SHORT)
                .show();
            return;
        }
        if (!TextUtils.isEmpty(phoneNumber)) {
            LoginServiceManager.getInstance()
                .sendMessage(
                    phoneNumber,
                    new BaseService.ResponseCallBack<Void>() {

                        @Override
                        public void onSuccess(Void response) {
                            Toast.makeText(
                                    VerifyCodeActivity.this,
                                    R.string.login_sms_code_send_success,
                                    Toast.LENGTH_SHORT)
                                .show();
                            initCountDown();
                        }

                        @Override
                        public void onFail(int code) {
                            Toast.makeText(
                                    VerifyCodeActivity.this,
                                    R.string.login_sms_code_send_fail,
                                    Toast.LENGTH_SHORT)
                                .show();
                        }
                    });
        }
    }

    private void login(String msmCode) {
        if (!TextUtils.isEmpty(phoneNumber) && !TextUtils.isEmpty(msmCode)) {
            LoginServiceManager.getInstance()
                .loginWithSms(
                    phoneNumber,
                    msmCode,
                    new BaseService.ResponseCallBack<Void>() {
                        @Override
                        public void onSuccess(Void response) {
                            Toast.makeText(
                                    VerifyCodeActivity.this, R.string.login_success, Toast.LENGTH_SHORT)
                                .show();
                            startMainActivity();
                        }

                        @Override
                        public void onFail(int code) {
                            Toast.makeText(VerifyCodeActivity.this, R.string.login_fail, Toast.LENGTH_SHORT)
                                .show();
                        }
                    });
        }
    }

    private void startMainActivity() {
        Intent intent = new Intent();
        intent.setPackage(VerifyCodeActivity.this.getPackageName());
        intent.addCategory("android.intent.category.DEFAULT");
        intent.setAction("com.nertc.g2.action.main");
        startActivity(intent);
        finish();
    }
}
