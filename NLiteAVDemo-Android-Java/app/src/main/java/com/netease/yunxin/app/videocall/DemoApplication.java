// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.app.Application;
import android.text.TextUtils;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.util.NIMUtil;
import com.netease.yunxin.app.videocall.login.model.AuthManager;
import com.netease.yunxin.app.videocall.login.model.LoginModel;
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils;
import com.netease.yunxin.nertc.ui.CallKitUI;

public class DemoApplication extends Application {
  public static DemoApplication app;

  @Override
  public void onCreate() {
    super.onCreate();
    if (NIMUtil.isMainProcess(this)) {
      app = this;
    }
    NIMClient.initV2(this, options());
    if (NIMUtil.isMainProcess(this)) {
      NetworkUtils.init(this);
      // 预收到离线消息时需在 IM 初始化后立即注册群组
      CallKitUI.preGroupConfig();
    }
  }

  // 如果返回值为 null，则全部使用默认参数。
  private SDKOptions options() {
    SDKOptions options = new SDKOptions();
    //此处仅设置appkey，其他设置请自行参看信令文档设置 ：https://dev.yunxin.163.com/docs/product/信令/SDK开发集成/Android开发集成/初始化
    options.appKey = BuildConfig.APP_KEY;
    return options;
  }

  // 如果已经存在用户登录信息，返回LoginInfo，否则返回null即可
  private LoginInfo loginInfo() {
    LoginModel userModel = AuthManager.getInstance().getUserModel();
    if (userModel != null
        && !TextUtils.isEmpty(userModel.imToken)
        && !TextUtils.isEmpty(userModel.imAccid)) {
      return new LoginInfo(String.valueOf(userModel.imAccid), userModel.imToken);
    }
    return null;
  }
}
