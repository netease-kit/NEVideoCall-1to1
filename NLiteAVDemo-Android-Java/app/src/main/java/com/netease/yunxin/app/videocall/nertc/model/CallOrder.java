package com.netease.yunxin.app.videocall.nertc.model;

import com.netease.nimlib.sdk.msg.attachment.NetCallAttachment;
import com.netease.nimlib.sdk.msg.constant.MsgDirectionEnum;

import java.io.Serializable;

public class CallOrder implements Serializable {
    public long receivedTime;//收到时间

    public String nickname;//昵称

    public String sessionId;//对方的imAccount

    public MsgDirectionEnum direction;//方向

    public NetCallAttachment attachment;

    public CallOrder(String sessionId, long receivedTime, MsgDirectionEnum direction, NetCallAttachment attachment, String nickname) {
        this.sessionId = sessionId;
        this.receivedTime = receivedTime;
        this.direction = direction;
        this.attachment = attachment;
        this.nickname = nickname;
    }
}
