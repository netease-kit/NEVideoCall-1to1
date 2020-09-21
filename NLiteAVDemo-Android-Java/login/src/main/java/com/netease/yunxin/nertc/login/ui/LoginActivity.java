package com.netease.yunxin.nertc.login.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.netease.yunxin.nertc.baselib.BaseService;
import com.netease.yunxin.nertc.login.R;
import com.netease.yunxin.nertc.login.model.LoginServiceManager;

public class LoginActivity extends AppCompatActivity {

    private EditText mEdtPhoneNumber;
    private Button mBtnSendMessage;

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
        mBtnSendMessage.setOnClickListener(v -> {
            sendMsm();
        });

    }

    private void sendMsm() {
        String phoneNumber = mEdtPhoneNumber.getText().toString().trim();
        if (!TextUtils.isEmpty(phoneNumber)) {
            LoginServiceManager.getInstance().sendMessage(phoneNumber, new BaseService.ResponseCallBack<Void>() {

                @Override
                public void onSuccess(Void response) {
                    VerifyCodeActivity.startVerifyCode(LoginActivity.this, phoneNumber);
                }

                @Override
                public void onFail(int code) {

                }
            });
        }
    }
}
