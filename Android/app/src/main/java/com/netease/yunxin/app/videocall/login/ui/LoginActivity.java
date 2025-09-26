// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.login.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.base.BaseService;
import com.netease.yunxin.app.videocall.login.model.LoginServiceManager;
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils;

public class LoginActivity extends AppCompatActivity {

    private EditText mEdtPhoneNumber;
    private Button mBtnSendMessage;
    private static final int PHONE_NUMBER_MAX_LENGTH = 11;

    public static void startLogin(Context context) {
        Intent intent = new Intent();
        intent.setClass(context, LoginActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.login_activity);
        initView();
    }

    private void initView() {
        mEdtPhoneNumber = findViewById(R.id.edt_phone_number);
        mBtnSendMessage = findViewById(R.id.btn_send);
        mBtnSendMessage.setOnClickListener(v -> sendMsm());
    }

    private void sendMsm() {
        String phoneNumber = mEdtPhoneNumber.getText().toString().trim();
        if (!TextUtils.isEmpty(phoneNumber)) {
            if (phoneNumber.length() < PHONE_NUMBER_MAX_LENGTH) {
                Toast.makeText(
                        LoginActivity.this,
                        R.string.login_phone_number_cant_less_than_eleven,
                        Toast.LENGTH_SHORT)
                    .show();
                return;
            }
            if (!NetworkUtils.isConnected()) {
                Toast.makeText(
                        LoginActivity.this,
                        R.string.network_connect_error_please_try_again,
                        Toast.LENGTH_SHORT)
                    .show();
                return;
            }
            LoginServiceManager.getInstance()
                .sendMessage(
                    phoneNumber,
                    new BaseService.ResponseCallBack<Void>() {

                        @Override
                        public void onSuccess(Void response) {
                            VerifyCodeActivity.startVerifyCode(LoginActivity.this, phoneNumber);
                        }

                        @Override
                        public void onFail(int code) {
                            Log.e("LoginActivity", "login failed" + code);
                        }
                    });
            VerifyCodeActivity.startVerifyCode(LoginActivity.this, phoneNumber);
        } else {
            Toast.makeText(LoginActivity.this, R.string.login_phone_number_cant_null, Toast.LENGTH_SHORT)
                .show();
        }
    }
}
