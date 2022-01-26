package com.netease.yunxin.app.videocall.login.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.Button;
import android.widget.EditText;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.blankj.utilcode.util.NetworkUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.login.model.LoginServiceManager;
import com.netease.yunxin.app.videocall.base.BaseService;

public class LoginActivity extends AppCompatActivity {

    private EditText mEdtPhoneNumber;
    private Button mBtnSendMessage;
    private static final int PHONE_NUMBER_MAX_LENGTH=11;

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
        //置灰效果
//        mEdtPhoneNumber.addTextChangedListener(new TextWatcher() {
//            @Override
//            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//
//            }
//
//            @Override
//            public void onTextChanged(CharSequence s, int start, int before, int count) {
//                if (!TextUtils.isEmpty(s) && s.length() == PHONE_NUMBER_MAX_LENGTH) {
//                    mBtnSendMessage.setEnabled(true);
//                } else {
//                    mBtnSendMessage.setEnabled(false);
//                }
//            }
//
//            @Override
//            public void afterTextChanged(Editable s) {
//
//            }
//        });
        mBtnSendMessage.setOnClickListener(v -> {
            sendMsm();
        });

    }

    private void sendMsm() {
        String phoneNumber = mEdtPhoneNumber.getText().toString().trim();
        if (!TextUtils.isEmpty(phoneNumber)) {
            if (phoneNumber.length() < PHONE_NUMBER_MAX_LENGTH) {
                ToastUtils.showShort(R.string.login_phone_number_cant_less_than_eleven);
                return;
            }
            if (!NetworkUtils.isConnected()){
                ToastUtils.showShort(R.string.network_connect_error_please_try_again);
                return;
            }
            LoginServiceManager.getInstance().sendMessage(phoneNumber, new BaseService.ResponseCallBack<Void>() {

                @Override
                public void onSuccess(Void response) {
                    VerifyCodeActivity.startVerifyCode(LoginActivity.this, phoneNumber);
                }

                @Override
                public void onFail(int code) {

                }
            });
        } else {
            ToastUtils.showShort(R.string.login_phone_number_cant_null);
        }
    }
}
