// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.user;

import com.netease.nimlib.sdk.v2.user.V2NIMUser;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.call.common.NimUserWrapper;
import com.netease.yunxin.kit.call.common.callback.Callback2;

import java.util.ArrayList;
import java.util.List;

public final class UserManager {
  private final String TAG = "UserManager";
  private static volatile UserManager mInstance;

  private UserManager() {}

  public static UserManager getInstance() {
    if (null == mInstance) {
      synchronized (UserManager.class) {
        if (mInstance == null) {
          mInstance = new UserManager();
        }
      }
    }
    return mInstance;
  }

  public void getUserList(List<String> accountIds, Callback2<List<UserModel>> callback) {
    NimUserWrapper.getUserList(
        accountIds,
        new Callback2<List<V2NIMUser>>() {
          @Override
          public void onSuccess(List<V2NIMUser> v2NIMUsers) {
            ALog.i(TAG, "getUserList success");
            List<UserModel> list = new ArrayList<>();

            if (v2NIMUsers != null) {
              for (V2NIMUser nimUser : v2NIMUsers) {
                UserModel user = new UserModel();
                user.setMobile(nimUser.getMobile());
                user.setName(nimUser.getName());
                user.setAvatar(nimUser.getAvatar());
                list.add(user);
              }
            }
            if (callback != null) {
              callback.onSuccess(list);
            }
          }

          @Override
          public void onFailure(int code, String msg) {
            ALog.e(TAG, "getUserList failed code = " + code + ", msg = " + msg);
            if (callback != null) {
              callback.onFailure(code, msg);
            }
          }
        });
  }
}
