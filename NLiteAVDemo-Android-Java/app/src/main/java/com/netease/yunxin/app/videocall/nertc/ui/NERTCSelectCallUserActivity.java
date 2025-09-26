// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.nertc.ui;

import static com.netease.yunxin.app.videocall.nertc.ui.adapter.ItemStateListener.ADD;
import static com.netease.yunxin.app.videocall.nertc.ui.adapter.ItemStateListener.CONNECTION;
import static com.netease.yunxin.app.videocall.nertc.ui.adapter.ItemStateListener.REMOVE;

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
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.yunxin.app.videocall.R;
import com.netease.yunxin.app.videocall.base.BaseService;
import com.netease.yunxin.app.videocall.login.model.AuthManager;
import com.netease.yunxin.app.videocall.login.model.LoginModel;
import com.netease.yunxin.app.videocall.nertc.biz.CallOrderManager;
import com.netease.yunxin.app.videocall.nertc.biz.CallServiceManager;
import com.netease.yunxin.app.videocall.nertc.biz.UserCacheManager;
import com.netease.yunxin.app.videocall.nertc.model.CallOrder;
import com.netease.yunxin.app.videocall.nertc.ui.adapter.CallOrderAdapter;
import com.netease.yunxin.app.videocall.nertc.ui.adapter.RecentUserAdapter;
import com.netease.yunxin.app.videocall.nertc.ui.adapter.ToBeCallUserAdapter;
import com.netease.yunxin.kit.call.group.GroupCallEndEvent;
import com.netease.yunxin.kit.call.group.GroupCallHangupEvent;
import com.netease.yunxin.kit.call.group.GroupCallMember;
import com.netease.yunxin.kit.call.group.NEGroupCall;
import com.netease.yunxin.kit.call.group.NEGroupCallDelegate;
import com.netease.yunxin.kit.call.group.NEGroupCallInfo;
import com.netease.yunxin.kit.call.group.param.GroupCallParam;
import com.netease.yunxin.kit.call.p2p.NECallEngine;
import com.netease.yunxin.kit.call.p2p.model.NECallType;
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState;
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils;
import com.netease.yunxin.nertc.ui.CallKitUI;
import com.netease.yunxin.nertc.ui.base.CallParam;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class NERTCSelectCallUserActivity extends AppCompatActivity {
  private static final String KEY_CALL_MODE_TYPE = "key_call_mode_type";
  public static final String KEY_CALL_USER_LIST = "key_call_user_list";
  private static final int LIMIT_COUNT = 15;

  private final List<String> alreadyConnectionUserList = new ArrayList<>();

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
  TextView tvGroupCall;

  private ToBeCallUserAdapter toBeCallUserAdapter;

  private int callModeType;

  private final NEGroupCallDelegate observer =
      new NEGroupCallDelegate() {
        @Override
        public void onReceiveGroupInvitation(NEGroupCallInfo neGroupCallInfo) {

        }

        @Override
        public void onGroupMemberListChanged(String s, List<GroupCallMember> list) {

        }

        @Override
        public void onGroupCallHangup(GroupCallHangupEvent hangupEvent) {
          if (callModeType == CallModeType.RTC_GROUP_INVITE) {
            finish();
          }
        }

        @Override
        public void onGroupCallEnd(GroupCallEndEvent groupCallEndEvent) {
          if (callModeType == CallModeType.RTC_GROUP_INVITE) {
            finish();
          }
        }
      };

  public static void startSelectUser(
      Activity activity, int requestCode, int type, List<String> userList) {
    Intent intent = new Intent();
    intent.setClass(activity, NERTCSelectCallUserActivity.class);
    intent.putExtra(KEY_CALL_MODE_TYPE, type);
    if (userList != null) {
      intent.putStringArrayListExtra(KEY_CALL_USER_LIST, new ArrayList<>(userList));
    }
    activity.startActivityForResult(intent, requestCode);
  }

  public static void startSelectUser(Context context, int type, List<String> userList) {
    Intent intent = new Intent();
    intent.setClass(context, NERTCSelectCallUserActivity.class);
    intent.putExtra(KEY_CALL_MODE_TYPE, type);
    if (userList != null) {
      intent.putStringArrayListExtra(KEY_CALL_USER_LIST, new ArrayList<>(userList));
    }
    context.startActivity(intent);
  }

  public static void startSelectUser(Context context, int type) {
    startSelectUser(context, type, null);
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    NEGroupCall.instance().addGroupCallDelegate(observer);
    callModeType = getIntent().getIntExtra(KEY_CALL_MODE_TYPE, CallModeType.RTC_1V1_VIDEO_CALL);
    List<String> connectionUserList = getIntent().getStringArrayListExtra(KEY_CALL_USER_LIST);
    if (connectionUserList != null) {
      alreadyConnectionUserList.addAll(connectionUserList);
    }
    setContentView(R.layout.video_call_select_layout);
    initView(callModeType);
    initData();
  }

  private void initView(int callModeType) {
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
    edtPhoneNumber.addTextChangedListener(
        new TextWatcher() {
          @Override
          public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {}

          @Override
          public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {}

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
    rvRecentUser.setLayoutManager(
        new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, true));

    rvSearchResult = findViewById(R.id.rv_search_result);
    rvSearchResult.setLayoutManager(new LinearLayoutManager(this));
    searchAdapter = new RecentUserAdapter(this);
    rvSearchResult.setAdapter(searchAdapter);
    searchAdapter.setItemClickListener(this::handleForClick);
    searchAdapter.setItemStateListener(this::getItemState);
    tvGroupCall = findViewById(R.id.tv_to_group_call);
    View settingBtn = findViewById(R.id.iv_setting);

    TextView title = findViewById(R.id.tv_title);
    if (callModeType == CallModeType.PSTN_1V1_AUDIO_CALL
        || callModeType == CallModeType.RTC_1V1_VIDEO_CALL) {
      title.setText(R.string.video_call);
      settingBtn.setOnClickListener(
          v -> startActivity(new Intent(NERTCSelectCallUserActivity.this, SettingActivity.class)));
    } else if (callModeType == CallModeType.RTC_GROUP_CALL) {
      title.setText(R.string.group_call);
    }
    if (callModeType == CallModeType.PSTN_1V1_AUDIO_CALL
        || callModeType == CallModeType.RTC_1V1_VIDEO_CALL) {
      callOrderAdapter = new CallOrderAdapter(this);
      LinearLayoutManager callOrderLayoutManager =
          new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, true);
      rvCallOrder.setLayoutManager(callOrderLayoutManager);
      rvCallOrder.setAdapter(callOrderAdapter);
      List<CallOrder> orderRecord = CallOrderManager.getInstance().getOrders();
      callOrderAdapter.updateItem(orderRecord);
      if (!orderRecord.isEmpty()) {
        tvCallRecord.setVisibility(View.VISIBLE);
      }
      tvGroupCall.setVisibility(View.GONE);
    } else {
      toBeCallUserAdapter = new ToBeCallUserAdapter(this);
      toBeCallUserAdapter.setClickItemListener(this::handleForClick);
      tvCallRecord.setVisibility(View.VISIBLE);
      tvCallRecord.setText(R.string.user_to_be_called);
      rvCallOrder.setLayoutManager(new GridLayoutManager(this, 7));
      rvCallOrder.setAdapter(toBeCallUserAdapter);
      tvGroupCall.setVisibility(View.VISIBLE);
      int count = toBeCallUserAdapter.getItemCount() + alreadyConnectionUserList.size() - 1;
      if (count <= LIMIT_COUNT) {
        tvGroupCall.setText(
            getString(R.string.user_to_group_call_with_user_count, count, LIMIT_COUNT));
      }
      tvGroupCall.setOnClickListener(
          v -> {
            if (!NetworkUtils.isConnected()) {
              Toast.makeText(
                      NERTCSelectCallUserActivity.this,
                      R.string.network_connect_error_please_try_again,
                      Toast.LENGTH_SHORT)
                  .show();
              return;
            }
            List<String> userList = toBeCallUserAdapter.getTotalAccIds();
            if (userList != null && !userList.isEmpty()) {
              Toast.makeText(getApplicationContext(), "发起群组呼叫邀请", Toast.LENGTH_SHORT).show();
              if (callModeType == CallModeType.RTC_GROUP_CALL) {
                String[] userArray = new String[userList.size()];
                userList.toArray(userArray);

                JSONObject extraInfo = new JSONObject();
                LoginModel currentUser = AuthManager.getInstance().getUserModel();
                try {
                  extraInfo.putOpt("key", "call");
                  extraInfo.putOpt("value", "testValue");
                  extraInfo.putOpt("userName", currentUser.mobile);
                } catch (Throwable e) {
                  e.printStackTrace();
                }
                GroupCallParam param =
                    new GroupCallParam.Builder()
                        .callId(UUID.randomUUID().toString())
                        .callees(userArray)
                        .extraInfo(extraInfo.toString())
                        .build();
                CallKitUI.startGroupCall(this, param);
              } else if (callModeType == CallModeType.RTC_GROUP_INVITE) {
                Intent intent = new Intent();
                intent.putStringArrayListExtra(KEY_CALL_USER_LIST, new ArrayList<>(userList));
                setResult(RESULT_OK, intent);
                finish();
              }
            } else {
              Toast.makeText(getApplicationContext(), "请选择待呼叫用户", Toast.LENGTH_SHORT).show();
            }
          });
    }
  }

  private void initData() {
    LoginModel currentUser = AuthManager.getInstance().getUserModel();
    tvSelfNumber.setText(
        String.format(getString(R.string.your_phone_number_is), currentUser.mobile));
    if (callModeType == CallModeType.RTC_1V1_VIDEO_CALL
        || callModeType == CallModeType.PSTN_1V1_AUDIO_CALL) {
      CallOrderManager.getInstance()
          .getOrdersLiveData()
          .observe(
              this,
              orders -> {
                callOrderAdapter.updateItem(orders);
                if (!orders.isEmpty()) {
                  tvCallRecord.setVisibility(View.VISIBLE);
                }
              });
    }

    UserCacheManager.getInstance()
        .getLastSearchUser(
            users ->
                runOnUiThread(
                    () -> {
                      if (userAdapter == null) {
                        userAdapter = new RecentUserAdapter(NERTCSelectCallUserActivity.this);
                      }
                      rvRecentUser.setAdapter(userAdapter);
                      userAdapter.updateUsers(users);
                      if (users != null && !users.isEmpty()) {
                        tvRecentSearch.setVisibility(View.VISIBLE);
                      }
                      userAdapter.setItemStateListener(this::getItemState);
                      userAdapter.setItemClickListener(this::handleForClick);
                    }));

    btnSearch.setOnClickListener(
        v -> {
          if (!NetworkUtils.isConnected()) {
            Toast.makeText(
                    NERTCSelectCallUserActivity.this, R.string.nertc_no_network, Toast.LENGTH_SHORT)
                .show();
            return;
          }
          String phoneNumber = edtPhoneNumber.getText().toString().trim();
          if (!TextUtils.isEmpty(phoneNumber)) {
            CallServiceManager.getInstance()
                .searchUserWithPhoneNumber(
                    phoneNumber,
                    new BaseService.ResponseCallBack<LoginModel>() {

                      @Override
                      public void onSuccess(LoginModel response) {
                        hideKeyBoard();
                        if (response != null) {
                          tvEmpty.setVisibility(View.GONE);
                          rvSearchResult.setVisibility(View.VISIBLE);
                          if (searchAdapter != null) {
                            searchAdapter.updateItem(response);
                          }
                          UserCacheManager.getInstance().addUser(response);
                        } else {
                          Toast.makeText(
                                  NERTCSelectCallUserActivity.this,
                                  R.string.nertc_cant_find_this_user,
                                  Toast.LENGTH_SHORT)
                              .show();
                        }
                      }

                      @Override
                      public void onFail(int code) {}
                    });
          }
        });
  }

  private void hideKeyBoard() {
    View view = getCurrentFocus();
    if (view != null) {
      InputMethodManager inputMethodManager =
          (InputMethodManager) getSystemService(Activity.INPUT_METHOD_SERVICE);
      inputMethodManager.hideSoftInputFromWindow(
          view.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
    }
  }

  private int getItemState(LoginModel data) {
    if (callModeType != CallModeType.RTC_GROUP_CALL
        && callModeType != CallModeType.RTC_GROUP_INVITE) {
      return -1;
    }
    LoginModel currentUser = AuthManager.getInstance().getUserModel();
    if (toBeCallUserAdapter.contains(data.imAccid)) {
      return REMOVE;
    } else if (alreadyConnectionUserList.contains(data.imAccid)
        && !(currentUser.imAccid.equals(data.imAccid) || currentUser.mobile.equals(data.mobile))) {
      return CONNECTION;
    } else {
      return ADD;
    }
  }

  private void handleForClick(LoginModel data) {

    LoginModel currentUser = AuthManager.getInstance().getUserModel();
    if (currentUser == null || TextUtils.isEmpty(currentUser.imAccid)) {
      Toast.makeText(getApplicationContext(), "当前用户登录存在问题，请注销后重新登录", Toast.LENGTH_SHORT).show();
      return;
    }

    if (currentUser.imAccid.equals(data.imAccid) || currentUser.mobile.equals(data.mobile)) {
      Toast.makeText(getApplicationContext(), "不能呼叫自己！", Toast.LENGTH_SHORT).show();
      return;
    }
    if (NetworkUtils.isConnected()) {
      if (NECallEngine.sharedInstance().getCallInfo().callStatus != CallState.STATE_IDLE) {
        Toast.makeText(getApplicationContext(), "正在通话中", Toast.LENGTH_SHORT).show();
        return;
      }
      int state = getItemState(data);
      if (state == ADD) {
        int count = toBeCallUserAdapter.getItemCount() + alreadyConnectionUserList.size();
        if (count > LIMIT_COUNT) {
          Toast.makeText(this, R.string.user_count_is_to_limit, Toast.LENGTH_SHORT).show();
          return;
        }
        tvGroupCall.setText(
            getString(R.string.user_to_group_call_with_user_count, count, LIMIT_COUNT));
        toBeCallUserAdapter.add(data);
        userAdapter.notifyDataSetChanged();
        searchAdapter.notifyDataSetChanged();
      } else if (state == REMOVE) {
        toBeCallUserAdapter.remove(data);
        int count = toBeCallUserAdapter.getItemCount() + alreadyConnectionUserList.size() - 1;
        tvGroupCall.setText(
            getString(R.string.user_to_group_call_with_user_count, count, LIMIT_COUNT));
        userAdapter.notifyDataSetChanged();
        searchAdapter.notifyDataSetChanged();
      } else if (state == CONNECTION) {
        Toast.makeText(getApplicationContext(), "已经在连线中", Toast.LENGTH_SHORT).show();
      } else {
        // 自定义透传字段，被叫用户在收到呼叫邀请时通过参数进行解析
        JSONObject extraInfo = new JSONObject();

        try {
          extraInfo.putOpt("key", "call");
          extraInfo.putOpt("value", "testValue");
          extraInfo.putOpt("userName", currentUser.mobile);
        } catch (JSONException e) {
          e.printStackTrace();
        }

        CallParam param =
            new CallParam.Builder()
                .callType(SettingActivity.ENABLE_AUDIO_CALL ? NECallType.AUDIO : NECallType.VIDEO)
                .calledAccId(data.imAccid)
                .callExtraInfo(extraInfo.toString())
                .build();
        CallKitUI.startSingleCall(getApplicationContext(), param);
      }
    } else {
      Toast.makeText(
              NERTCSelectCallUserActivity.this,
              R.string.network_connect_error_please_try_again,
              Toast.LENGTH_SHORT)
          .show();
    }
  }

  @Override
  protected void onPause() {
    super.onPause();
    if (isFinishing()) {
      NEGroupCall.instance().removeGroupCallDelegate(observer);
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    NEGroupCall.instance().removeGroupCallDelegate(observer);
  }
}
