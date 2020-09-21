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
import com.netease.nimlib.sdk.avsignalling.SignallingServiceObserver;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;
import com.netease.nimlib.sdk.avsignalling.constant.SignallingEventType;
import com.netease.nimlib.sdk.avsignalling.event.CanceledInviteEvent;
import com.netease.nimlib.sdk.avsignalling.event.ChannelCloseEvent;
import com.netease.nimlib.sdk.avsignalling.event.ChannelCommonEvent;
import com.netease.nimlib.sdk.avsignalling.event.ControlEvent;
import com.netease.nimlib.sdk.avsignalling.event.InviteAckEvent;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.nimlib.sdk.avsignalling.event.UserJoinEvent;
import com.netease.nimlib.sdk.avsignalling.event.UserLeaveEvent;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.uinfo.UserInfoProvider;
import com.netease.nimlib.sdk.uinfo.UserService;
import com.netease.nimlib.sdk.uinfo.constant.UserInfoFieldEnum;
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo;
import com.netease.nimlib.sdk.uinfo.model.UserInfo;
import com.netease.nimlib.sdk.util.NIMUtil;
import com.netease.yunxin.nertc.login.model.ProfileManager;
import com.netease.yunxin.nertc.login.model.UserModel;
import com.netease.yunxin.nertc.nertcvideocalldemo.ui.NERTCVideoCallActivity;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
        return null;
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
