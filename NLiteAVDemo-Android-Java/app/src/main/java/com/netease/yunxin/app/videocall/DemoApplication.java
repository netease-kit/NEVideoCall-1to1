// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall;

import android.app.Application;
import android.content.Intent;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.util.NIMUtil;
import com.netease.yunxin.app.videocall.nertc.ui.CallModeType;
import com.netease.yunxin.app.videocall.nertc.ui.NERTCSelectCallUserActivity;
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils;
import com.netease.yunxin.nertc.ui.CallKitUI;
import com.netease.yunxin.nertc.ui.CallKitUIOptions;
import com.netease.yunxin.nertc.ui.NECallUILanguage;
import com.netease.yunxin.nertc.ui.base.TransHelper;

import java.util.ArrayList;

public class DemoApplication extends Application {
  private static final int CODE_REQUEST_INVITE_USERS = 9101;
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
      initCallKit();
    }
  }

  // 如果返回值为 null，则全部使用默认参数。
  private SDKOptions options() {
    SDKOptions options = new SDKOptions();
    //此处仅设置appkey，其他设置请自行参看信令文档设置 ：https://dev.yunxin.163.com/docs/product/信令/SDK开发集成/Android开发集成/初始化
    options.appKey = BuildConfig.APP_KEY;
    return options;
  }

  private void initCallKit() {
    // 预收到离线消息时需在 IM 初始化后立即注册群组
    CallKitUI.preGroupConfig();
    CallKitUIOptions options =
        new CallKitUIOptions.Builder()
            // 音视频通话 sdk appKey，用于通话中使用
            .rtcAppKey(BuildConfig.APP_KEY)
            // 通话接听成功的超时时间单位 毫秒，默认30s
            .timeOutMillisecond(30 * 1000L)
            // 收到被叫时若 app 在后台，在恢复到前台时是否自动唤起被叫页面，默认为 true
            .resumeBGInvitation(true)
            .enableGroup(true)
            // 设置用户信息
            .userInfoHelper(new SelfUserInfoHelper())
            // rtc 初始化模式
            // 注册自定义通话页面
            .p2pVideoActivity(TestActivity.class)
            .p2pAudioActivity(TestActivity.class)
            .contactSelector(
                (context, groupId, strings, listNEResultObserver) -> {
                  if (listNEResultObserver == null) {
                    return null;
                  }
                  TransHelper.launchTask(
                      context,
                      CODE_REQUEST_INVITE_USERS,
                      (innerContext, code) -> {
                        NERTCSelectCallUserActivity.startSelectUser(
                            innerContext,
                            CODE_REQUEST_INVITE_USERS,
                            CallModeType.RTC_GROUP_INVITE,
                            strings);
                        return null;
                      },
                      intentResultInfo -> {
                        if (intentResultInfo == null || intentResultInfo.getValue() == null) {
                          return null;
                        }
                        Intent data = intentResultInfo.getValue();
                        if (intentResultInfo.getSuccess()) {
                          ArrayList<String> selectorList =
                              data.getStringArrayListExtra(
                                  NERTCSelectCallUserActivity.KEY_CALL_USER_LIST);
                          listNEResultObserver.onResult(selectorList);
                        }
                        return null;
                      });
                  return null;
                })
            .language(NECallUILanguage.AUTO)
            .build();
    // 初始化
    CallKitUI.init(getApplicationContext(), options);
  }
}
