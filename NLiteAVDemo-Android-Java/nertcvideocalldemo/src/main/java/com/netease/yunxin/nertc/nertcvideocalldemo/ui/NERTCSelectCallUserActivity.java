package com.netease.yunxin.nertc.nertcvideocalldemo.ui;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.ToastUtils;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.RoundedCorners;
import com.bumptech.glide.request.RequestOptions;
import com.netease.videocall.demo.videocall.R;
import com.netease.yunxin.nertc.baselib.BaseService;
import com.netease.yunxin.nertc.login.model.UserModel;
import com.netease.yunxin.nertc.nertcvideocalldemo.biz.CallServiceManager;
import com.netease.yunxin.nertc.nertcvideocalldemo.biz.UserCacheManager;
import com.netease.yunxin.nertc.nertcvideocalldemo.ui.adapter.RecentUserAdapter;

public class NERTCSelectCallUserActivity extends AppCompatActivity {

    private RecyclerView rvRecentUser;

    private Button btnSearch;

    private EditText edtPhoneNumber;

    private ImageView ivClear;

    private ImageView ivSearchedUser;

    private TextView tvSearchedUserName;

    private LinearLayout llySearchResult;

    private TextView tvCancel;

    private UserModel searchedUser;//选中的User

    public static void startSelectUser(Context context) {
        Intent intent = new Intent();
        intent.setClass(context, NERTCSelectCallUserActivity.class);
        context.startActivity(intent);
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.video_call_select_layout);
        initView();
        initData();
    }


    private void initView() {
        btnSearch = findViewById(R.id.btn_search);
        edtPhoneNumber = findViewById(R.id.edt_phone_number);
        ivClear = findViewById(R.id.iv_clear);
        ivSearchedUser = findViewById(R.id.iv_search_result);
        tvSearchedUserName = findViewById(R.id.tv_search_result);
        rvRecentUser = findViewById(R.id.rv_recent_user);
        llySearchResult = findViewById(R.id.lly_search_result);
        tvCancel = findViewById(R.id.tv_cancel);
        tvCancel.setOnClickListener(v -> {
            onBackPressed();
        });
        edtPhoneNumber.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                if (!TextUtils.isEmpty(editable)) {
                    ivClear.setVisibility(View.VISIBLE);
                } else {
                    ivClear.setVisibility(View.GONE);
                }
            }
        });
        ivClear.setOnClickListener(view -> edtPhoneNumber.setText(""));
        GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 5);
        rvRecentUser.setLayoutManager(gridLayoutManager);
    }

    private void initData() {
        UserCacheManager.getInstance().getLastSearchUser(users -> runOnUiThread(new Runnable() {
            @Override
            public void run() {
                RecentUserAdapter userAdapter = new RecentUserAdapter(users, NERTCSelectCallUserActivity.this);
                rvRecentUser.setAdapter(userAdapter);
            }
        }));

        btnSearch.setOnClickListener(v -> {
            String phoneNumber = edtPhoneNumber.getText().toString().trim();
            if (!TextUtils.isEmpty(phoneNumber)) {
                CallServiceManager.getInstance().searchUserWithPhoneNumber(phoneNumber, new BaseService.ResponseCallBack<UserModel>() {

                    @Override
                    public void onSuccess(UserModel response) {
                        hideKeyBoard();
                        if (response != null) {
                            searchedUser = response;
                            tvSearchedUserName.setText(response.mobile);
                            Glide.with(NERTCSelectCallUserActivity.this).load(response.avatar).apply(RequestOptions.bitmapTransform(new RoundedCorners(5))).into(ivSearchedUser);
                            UserCacheManager.getInstance().addUser(response);
                        } else {
                            ToastUtils.showLong("搜索不到该用户信息");
                        }
                    }

                    @Override
                    public void onFail(int code) {

                    }
                });
            }
        });

        llySearchResult.setOnClickListener(view -> {
            if (searchedUser != null) {
                NERTCVideoCallActivity.startCallOther(this, searchedUser);
            }
        });
    }

    private void hideKeyBoard() {
        View view = getCurrentFocus();
        if (view != null) {
            InputMethodManager inputMethodManager = (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
            inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }
}
