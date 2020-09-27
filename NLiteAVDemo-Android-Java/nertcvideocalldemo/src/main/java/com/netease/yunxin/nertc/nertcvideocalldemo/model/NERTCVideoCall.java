package com.netease.yunxin.nertc.nertcvideocalldemo.model;

import android.content.Context;

import com.netease.lava.api.IVideoRender;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.impl.NERTCVideoCallImpl;

public abstract class NERTCVideoCall {
    protected NERTCVideoCall() {
    }

    public static NERTCVideoCall sharedInstance(Context context) {
        return NERTCVideoCallImpl.sharedInstance(context);
    }

    public static void destroySharedInstance() {
        NERTCVideoCallImpl.destroySharedInstance();
    }


    /**
     * 增加回调接口
     *
     * @param delegate 上层可以通过回调监听事件
     */
    public abstract void addDelegate(NERTCCallingDelegate delegate);


    /**
     * 移除回调接口
     *
     * @param delegate 需要移除的监听器
     */
    public abstract void removeDelegate(NERTCCallingDelegate delegate);

    /**
     * 设置远端的视频接受播放器
     *
     * @param videoRender
     * @param uid
     */
    public abstract void setupRemoteView(NERtcVideoView videoRender, long uid);

    /**
     * 设置本端的视频接受播放器
     *
     * @param videoRender
     */
    public abstract void setupLocalView(NERtcVideoView videoRender);

    /**
     * C2C邀请通话，被邀请方会收到 {@link NERTCCallingDelegate#onInvitedByUser } 的回调
     *
     * @param userId 被邀请方
     * @param type   1-语音通话，2-视频通话
     */
    public abstract void call(String userId, ChannelType type);

    /**
     * 当您作为被邀请方收到 {@link NERTCCallingDelegate#onInvitedByUser } 的回调时，可以调用该函数接听来电
     *
     * @param invitedParam 邀请信息
     */
    public abstract void accept(InviteParamBuilder invitedParam);

    /**
     * 当您作为被邀请方收到 {@link NERTCCallingDelegate#onInvitedByUser } 的回调时，可以调用该函数拒绝来电
     *
     * @param inviteParam 邀请信息
     */
    public abstract void reject(InviteParamBuilder inviteParam);

    /**
     * 当您处于通话中，可以调用该函数结束通话
     */
    public abstract void hangup();

    /**
     * 当您处于呼叫中，可以调用该函数取消呼叫
     */
    public abstract void cancel();

    /**
     * 您可以调用该函数开启摄像头，并渲染在指定的TXCloudVideoView中
     * 处于通话中的用户会收到 {@link NERTCCallingDelegate#onCameraAvailable(long, boolean)} 回调
     *
     * @param enable 是否开启摄像头
     */
    public abstract void enableCamera(boolean enable);

    /**
     * 您可以调用该函数切换前后摄像头
     */
    public abstract void switchCamera();

    /**
     * 是否静音mic
     *
     * @param isMute true:麦克风关闭 false:麦克风打开
     */
    public abstract void setMicMute(boolean isMute);

    /**
     * 设置超时，最长2分钟
     *
     * @param timeOut 超时市场，最长两分钟，单位ms
     */
    public abstract void setTimeOut(int timeOut);
}
