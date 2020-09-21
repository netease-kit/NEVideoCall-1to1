package com.netease.yunxin.nertc.login.model;

import android.text.TextUtils;

import java.io.Serializable;

/**
 * 业务用户数据
 */
public final class UserModel implements Serializable {
    public String mobile;//String  登录的手机号
    public String accessToken;//String  登录令牌，重新生成的新令牌，过期时间重新计算
    public long imAccid;//long  IM账号
    public String imToken;//String  IM令牌，重新生成的新令牌
    public long avRoomUid;//String  音视频房间内成员编号
    public String avatar;//String  头像地址

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserModel userModel = (UserModel) o;
        return TextUtils.equals(this.mobile, userModel.mobile);
    }

}
