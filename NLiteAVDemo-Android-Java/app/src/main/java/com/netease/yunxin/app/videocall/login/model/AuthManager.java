// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.login.model;

import android.text.TextUtils;
import android.util.Log;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.auth.LoginInfo;
import com.netease.nimlib.sdk.v2.V2NIMError;
import com.netease.nimlib.sdk.v2.V2NIMFailureCallback;
import com.netease.nimlib.sdk.v2.V2NIMSuccessCallback;
import com.netease.nimlib.sdk.v2.auth.V2NIMLoginService;
import com.netease.nimlib.sdk.v2.user.V2NIMUserService;
import com.netease.nimlib.sdk.v2.user.params.V2NIMUserUpdateParams;
import com.netease.yunxin.app.videocall.base.CommonDataManager;
import com.netease.yunxin.app.videocall.nertc.utils.SPUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.nertc.nertcvideocall.utils.GsonUtils;

public final class AuthManager {
  private final String TAG = "AuthManager";
  private static final AuthManager instance = new AuthManager();

  public static AuthManager getInstance() {
    return instance;
  }

  private static final String PER_USER_MODEL = "per_user_model";

  private LoginModel userModel;
  private String token;
  private boolean isLogin = false;

  private AuthManager() {}

  public boolean isLogin() {
    return isLogin;
  }

  public void setLogin(boolean login) {
    isLogin = login;
    Log.e("======", "setLogin " + isLogin);
  }

  public LoginModel getUserModel() {
    if (userModel == null) {
      loadUserModel();
    }
    Log.e("======", "setUserModel " + userModel);
    return userModel;
  }

  /**
   * 是否是本用户
   *
   * @param imAccId
   * @return
   */
  public boolean isCurrentUser(String imAccId) {
    if (getUserModel() == null) {
      return false;
    }
    return TextUtils.equals(getUserModel().imAccid, imAccId);
  }

  /**
   * 音视频uid 判断
   *
   * @param g2Uid
   * @return
   */
  public boolean isCurrentUser(long g2Uid) {
    if (getUserModel() == null) {
      return false;
    }
    return getUserModel().avRoomUid == g2Uid;
  }

  public String getAccessToken() {
    if (token == null) {
      loadAccessToken();
    }
    return token;
  }

  public void setUserModel(LoginModel model) {
    Log.e("======", "setUserModel " + model);
    userModel = model;
    saveUserModel();
  }

  public void setAccessToken(String token) {
    this.token = token;
    CommonDataManager.getInstance().setAccessToken(token);
  }

  private void loadAccessToken() {
    token = CommonDataManager.getInstance().getAccessToken();
  }

  private void loadUserModel() {

    try {
      String json = SPUtils.getInstance(CommonDataManager.PER_DATA).getString(PER_USER_MODEL);
      userModel = GsonUtils.fromJson(json, LoginModel.class);
      Log.e(TAG, "loadUserModel " + userModel);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  private void saveUserModel() {
    Log.e("======", "saveUserModel " + userModel);
    try {
      if (userModel != null) {
        SPUtils.getInstance(CommonDataManager.PER_DATA)
            .put(PER_USER_MODEL, GsonUtils.toJson(userModel));
      } else {
        SPUtils.getInstance(CommonDataManager.PER_DATA).put(PER_USER_MODEL, "");
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void login(LoginInfo loginInfo, RequestCallback<Void> callback) {
    NIMClient.getService(V2NIMLoginService.class)
        .login(
            loginInfo.getAccount(),
            loginInfo.getToken(),
            null,
            new V2NIMSuccessCallback<Void>() {
              @Override
              public void onSuccess(Void unused) {
                ALog.i(TAG, "login im success");
                if (callback != null) {
                  callback.onSuccess(null);
                }
              }
            },
            new V2NIMFailureCallback() {
              @Override
              public void onFailure(V2NIMError error) {
                ALog.e(
                    TAG,
                    "login im failed code = " + error.getCode() + ", msg = " + error.getDesc());
                if (callback != null) {
                  callback.onFailed(error.getCode());
                }
              }
            });
  }

  public void updateUserInfo(LoginModel userModel) {
    V2NIMUserUpdateParams params =
        V2NIMUserUpdateParams.V2NIMUserUpdateParamsBuilder.builder()
            .withAvatar(userModel.avatar)
            .withMobile(userModel.mobile)
            .build();

    NIMClient.getService(V2NIMUserService.class)
        .updateSelfUserProfile(
            params,
            new V2NIMSuccessCallback<Void>() {
              @Override
              public void onSuccess(Void unused) {
                ALog.i(TAG, "updateUserInfo success");
              }
            },
            new V2NIMFailureCallback() {
              @Override
              public void onFailure(V2NIMError error) {
                ALog.e(
                    TAG,
                    "updateUserInfo failed code = "
                        + error.getCode()
                        + ", msg = "
                        + error.getDesc());
              }
            });
  }

  public void logout() {
    ALog.e(TAG, "logout");
    isLogin = false;
    userModel = null;
    token = null;
    NIMClient.getService(V2NIMLoginService.class)
        .logout(
            new V2NIMSuccessCallback<Void>() {
              @Override
              public void onSuccess(Void unused) {
                ALog.i(TAG, "logout success");
              }
            },
            new V2NIMFailureCallback() {
              @Override
              public void onFailure(V2NIMError error) {
                ALog.e(
                    TAG, "logout failed code = " + error.getCode() + ", msg = " + error.getDesc());
              }
            });
    SPUtils.getInstance(CommonDataManager.PER_DATA).put(PER_USER_MODEL, "", true);
  }
}
