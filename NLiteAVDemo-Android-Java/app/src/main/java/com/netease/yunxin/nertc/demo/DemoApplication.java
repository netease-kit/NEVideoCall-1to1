package com.netease.yunxin.nertc.demo;

import android.app.Application;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Environment;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowManager;

import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.SDKOptions;
import com.netease.nimlib.sdk.StatusBarNotificationConfig;
import com.netease.nimlib.sdk.auth.LoginInfo;

import com.netease.nimlib.sdk.util.NIMUtil;
import com.netease.yunxin.nertc.baselib.NativeConfig;
import com.netease.yunxin.nertc.login.model.ProfileManager;
import com.netease.yunxin.nertc.login.model.UserModel;


public class DemoApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        NIMClient.init(this, loginInfo(), options());

        if (NIMUtil.isMainProcess(this)) {
            // 注意：操作必须在主进程中进行

        }
    }

    // 如果返回值为 null，则全部使用默认参数。
    private SDKOptions options() {
        SDKOptions options = new SDKOptions();
        //此处仅设置appkey，其他设置请自行参看信令文档设置 ：https://dev.yunxin.163.com/docs/product/信令/SDK开发集成/Android开发集成/初始化
        options.appKey = NativeConfig.getAppKey();
        return options;
    }

    // 如果已经存在用户登录信息，返回LoginInfo，否则返回null即可
    private LoginInfo loginInfo() {
        UserModel userModel = ProfileManager.getInstance().getUserModel();
        if (userModel != null) {
            if (TextUtils.isEmpty(userModel.imToken) && userModel.imAccid != 0) {
                ProfileManager.getInstance().setLogin(true);//如果已有IM数据会自动登录，此处直接设置为已经登录
                return new LoginInfo(String.valueOf(userModel.imAccid), userModel.imToken);
            }
        }
        return null;
    }
}
