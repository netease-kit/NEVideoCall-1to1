// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.videocall.login.model;

import android.text.TextUtils;
import com.google.gson.annotations.SerializedName;
import java.io.Serializable;

/** 业务用户数据 */
public final class LoginModel implements Serializable {
    @SerializedName("mobile")
    public String mobile; //String  登录的手机号

    @SerializedName("accessToken")
    public String accessToken; //String  登录令牌，重新生成的新令牌，过期时间重新计算

    @SerializedName("imAccid")
    public String imAccid; //long  IM账号

    @SerializedName("imToken")
    public String imToken; //String  IM令牌，重新生成的新令牌

    @SerializedName("avRoomUid")
    public long avRoomUid; //String  音视频房间内成员编号

    @SerializedName("avatar")
    public String avatar; //String  头像地址

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        LoginModel userModel = (LoginModel) o;
        return TextUtils.equals(this.mobile, userModel.mobile);
    }

    @Override
    public String toString() {
        return "UserModel{"
            + "mobile='"
            + mobile
            + '\''
            + ", accessToken='"
            + accessToken
            + '\''
            + ", imAccid='"
            + imAccid
            + '\''
            + ", imToken='"
            + imToken
            + '\''
            + ", avRoomUid="
            + avRoomUid
            + ", avatar='"
            + avatar
            + '\''
            + '}';
    }
}
