package com.netease.yunxin.app.videocall.nertc.ui;

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
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.Observer;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.NetworkUtils;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.base.BaseService;
import com.netease.yunxin.app.videocall.login.model.ProfileManager;
import com.netease.yunxin.app.videocall.nertc.biz.CallOrderManager;
import com.netease.yunxin.app.videocall.nertc.biz.CallServiceManager;
import com.netease.yunxin.app.videocall.nertc.ui.adapter.CallOrderAdapter;
import com.netease.yunxin.app.videocall.login.model.UserModel;
import com.netease.yunxin.app.videocall.nertc.biz.UserCacheManager;
import com.netease.yunxin.app.videocall.nertc.model.CallOrder;
import com.netease.yunxin.app.videocall.nertc.ui.adapter.RecentUserAdapter;

import java.util.List;

public class NERTCSelectCallUserActivity extends AppCompatActivity {

    private TextView tvSelfNumber;

    private RecyclerView rvRecentUser;
    private RecentUserAdapter userAdapter;

    private Button btnSearch;
    private EditText edtPhoneNumber;
    private ImageView ivClear;

    private TextView tvRecentSearch;
    private TextView tvEmpty;
    private RecyclerView rvSearchResult;
    private RecentUserAdapter searchAdapter;

    private CallOrderAdapter callOrderAdapter;
    private TextView tvCallRecord;


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
        rvRecentUser = findViewById(R.id.rv_recent_user);
        RecyclerView rvCallOrder = findViewById(R.id.rv_call_order);
        tvEmpty = findViewById(R.id.tv_empty);
        tvSelfNumber = findViewById(R.id.tv_self_number);
        tvCallRecord = findViewById(R.id.tv_call_order);
        tvRecentSearch = findViewById(R.id.tv_recently_search);
        TextView tvCancel = findViewById(R.id.tv_cancel);
        tvCancel.setOnClickListener(v -> onBackPressed());
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
        rvRecentUser.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, true));

        rvSearchResult = findViewById(R.id.rv_search_result);
        rvSearchResult.setLayoutManager(new LinearLayoutManager(this));
        searchAdapter = new RecentUserAdapter(this);
        rvSearchResult.setAdapter(searchAdapter);

        callOrderAdapter = new CallOrderAdapter(this);
        LinearLayoutManager callOrderLayoutManager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, true);
        rvCallOrder.setLayoutManager(callOrderLayoutManager);
        rvCallOrder.setAdapter(callOrderAdapter);
        List<CallOrder> orderRecord = CallOrderManager.getInstance().getOrders();
        callOrderAdapter.updateItem(orderRecord);
        if (!orderRecord.isEmpty()) {
            tvCallRecord.setVisibility(View.VISIBLE);
        }

    }

    private void initData() {
        UserModel currentUser = ProfileManager.getInstance().getUserModel();
        tvSelfNumber.setText(String.format(getString(R.string.your_phone_number_is), currentUser.mobile));

        CallOrderManager.getInstance().getOrdersLiveData().observe(this, new Observer<List<CallOrder>>() {
            @Override
            public void onChanged(List<CallOrder> orders) {
                callOrderAdapter.updateItem(orders);
                if (!orders.isEmpty()) {
                    tvCallRecord.setVisibility(View.VISIBLE);
                }
            }
        });

        UserCacheManager.getInstance().getLastSearchUser(users -> runOnUiThread(() -> {
            if (userAdapter == null) {
                userAdapter = new RecentUserAdapter(NERTCSelectCallUserActivity.this);
            }
            rvRecentUser.setAdapter(userAdapter);
            userAdapter.updateUsers(users);
            if (users != null && !users.isEmpty()) {
                tvRecentSearch.setVisibility(View.VISIBLE);
            }
        }));

        btnSearch.setOnClickListener(v -> {
            if (!NetworkUtils.isConnected()) {
                Toast.makeText(NERTCSelectCallUserActivity.this, R.string.nertc_no_network, Toast.LENGTH_SHORT).show();
                return;
            }
            String phoneNumber = edtPhoneNumber.getText().toString().trim();
            if (!TextUtils.isEmpty(phoneNumber)) {
                CallServiceManager.getInstance().searchUserWithPhoneNumber(phoneNumber, new BaseService.ResponseCallBack<UserModel>() {

                    @Override
                    public void onSuccess(UserModel response) {
                        hideKeyBoard();
                        if (response != null) {
                            tvEmpty.setVisibility(View.GONE);
                            rvSearchResult.setVisibility(View.VISIBLE);
                            if (searchAdapter != null) {
                                searchAdapter.updateItem(response);
                            }
                            UserCacheManager.getInstance().addUser(response);
                        } else {
                            ToastUtils.showLong(R.string.nertc_cant_find_this_user);
                        }
                    }

                    @Override
                    public void onFail(int code) {

                    }
                });
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
