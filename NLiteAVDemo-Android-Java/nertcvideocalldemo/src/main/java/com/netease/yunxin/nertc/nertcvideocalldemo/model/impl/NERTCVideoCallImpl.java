package com.netease.yunxin.nertc.nertcvideocalldemo.model.impl;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.util.Log;

import com.blankj.utilcode.util.ToastUtils;
import com.netease.lava.nertc.sdk.NERtc;
import com.netease.lava.nertc.sdk.NERtcCallback;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcParameters;
import com.netease.lava.nertc.sdk.video.NERtcRemoteVideoStreamType;
import com.netease.lava.nertc.sdk.video.NERtcVideoView;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallbackWrapper;
import com.netease.nimlib.sdk.ResponseCode;
import com.netease.nimlib.sdk.avsignalling.SignallingService;
import com.netease.nimlib.sdk.avsignalling.SignallingServiceObserver;
import com.netease.nimlib.sdk.avsignalling.builder.CallParamBuilder;
import com.netease.nimlib.sdk.avsignalling.builder.InviteParamBuilder;
import com.netease.nimlib.sdk.avsignalling.constant.ChannelType;
import com.netease.nimlib.sdk.avsignalling.constant.InviteAckStatus;
import com.netease.nimlib.sdk.avsignalling.constant.SignallingEventType;
import com.netease.nimlib.sdk.avsignalling.event.CanceledInviteEvent;
import com.netease.nimlib.sdk.avsignalling.event.ChannelCloseEvent;
import com.netease.nimlib.sdk.avsignalling.event.ChannelCommonEvent;
import com.netease.nimlib.sdk.avsignalling.event.ControlEvent;
import com.netease.nimlib.sdk.avsignalling.event.InviteAckEvent;
import com.netease.nimlib.sdk.avsignalling.event.InvitedEvent;
import com.netease.nimlib.sdk.avsignalling.event.UserJoinEvent;
import com.netease.nimlib.sdk.avsignalling.event.UserLeaveEvent;
import com.netease.nimlib.sdk.avsignalling.model.ChannelFullInfo;
import com.netease.yunxin.nertc.baselib.NativeConfig;
import com.netease.yunxin.nertc.login.model.ProfileManager;
import com.netease.yunxin.nertc.login.model.UserModel;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.NERTCCallingDelegate;
import com.netease.yunxin.nertc.nertcvideocalldemo.model.NERTCVideoCall;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;


public class NERTCVideoCallImpl extends NERTCVideoCall {

    private static final String LOG_TAG = "NERTCVideoCallImpl";

    private static final int STATE_IDLE = 0;//状态空闲

    private static final int STATE_INVITED = 1;//被邀请了

    private static final int STATE_CALL_OUT = 2;//正在呼叫别人

    private static final int STATE_DIALOG = 3;//通话中

    private static final int TIME_OUT_LIMITED = 2 * 60 * 1000;//呼叫超时限制

    private int status;//初始化状态 0

    private boolean haveJoinNertcChannel = false;//是否加入了NERTC的频道

    private static NERTCVideoCallImpl instance;

    private NERTCInternalDelegateManager delegateManager;

    private InviteParamBuilder invitedParam;//邀请别人后保留的邀请信息

    private String imChannelId;//IM渠道号

    private int timeOut = TIME_OUT_LIMITED;//呼叫超时，最长2分钟

    private CountDownTimer timer;//呼出倒计时


    private static final String BUSY_LINE = "i_am_busy";

    public static synchronized NERTCVideoCall sharedInstance(Context context) {
        if (instance == null) {
            instance = new NERTCVideoCallImpl(context.getApplicationContext());
        }
        return instance;
    }

    public static synchronized void destroySharedInstance() {
        if (instance != null) {
            instance.destroy();
            instance = null;
        }
    }

    /**
     * 信令在线消息的回调
     */
    Observer<ChannelCommonEvent> nimOnlineObserver = new Observer<ChannelCommonEvent>() {
        @Override
        public void onEvent(ChannelCommonEvent event) {
            handleNIMEvent(event);
        }
    };

    /**
     * 信令离线消息
     */
    Observer<ArrayList<ChannelCommonEvent>> nimOfflineObserver = new Observer<ArrayList<ChannelCommonEvent>>() {
        @Override
        public void onEvent(ArrayList<ChannelCommonEvent> channelCommonEvents) {
            if (channelCommonEvents != null && channelCommonEvents.size() > 0) {
                for (ChannelCommonEvent event : channelCommonEvents) {
                    handleNIMEvent(event);
                }
            }
        }
    };

    /**
     * 处理IM信令事件
     *
     * @param event
     */
    private void handleNIMEvent(ChannelCommonEvent event) {
        SignallingEventType eventType = event.getEventType();

        switch (eventType) {
            case CLOSE:
                ChannelCloseEvent channelCloseEvent = (ChannelCloseEvent) event;
                break;
            case JOIN:
                UserJoinEvent userJoinEvent = (UserJoinEvent) event;
                break;
            case INVITE:
                InvitedEvent invitedEvent = (InvitedEvent) event;
                if (delegateManager != null) {
                    if (status != STATE_IDLE) { //占线，直接拒绝
                        InviteParamBuilder paramBuilder = new InviteParamBuilder(invitedEvent.getChannelBaseInfo().getChannelId(),
                                invitedEvent.getFromAccountId(), invitedEvent.getRequestId());
                        paramBuilder.customInfo(BUSY_LINE);
                        reject(paramBuilder);
                    } else {
                        delegateManager.onInvitedByUser(invitedEvent);
                    }
                }
                status = STATE_INVITED;
                break;
            case CANCEL_INVITE:
                CanceledInviteEvent canceledInviteEvent = (CanceledInviteEvent) event;
                if (delegateManager != null) {
                    delegateManager.onCancelByUserId(canceledInviteEvent.getFromAccountId());
                }
                status = STATE_IDLE;
                break;
            case REJECT:
            case ACCEPT:
                InviteAckEvent ackEvent = (InviteAckEvent) event;
                if (delegateManager != null) {
                    if (ackEvent.getAckStatus() == InviteAckStatus.REJECT) {
                        if (TextUtils.equals(ackEvent.getCustomInfo(), BUSY_LINE)) {
                            delegateManager.onUserBusy(ackEvent.getFromAccountId());
                        } else {
                            delegateManager.onRejectByUserId(ackEvent.getFromAccountId());
                        }
                        status = STATE_IDLE;
                    }
                }
                break;
            case LEAVE:
                UserLeaveEvent userLeaveEvent = (UserLeaveEvent) event;
                break;
            case CONTROL:
                ControlEvent controlEvent = (ControlEvent) event;
                break;
        }
    }

    /**
     * Nertc的回调
     */
    private NERtcCallback rtcCallback = new NERtcCallback() {
        @Override
        public void onJoinChannel(int i, long l, long l1) {
            haveJoinNertcChannel = true;
        }

        @Override
        public void onLeaveChannel(int i) {
            haveJoinNertcChannel = false;

        }

        @Override
        public void onUserJoined(long l) {
            if (!ProfileManager.getInstance().isCurrentUser(l)) {
                status = STATE_DIALOG;
            }
            if (delegateManager != null) {
                delegateManager.onUserEnter(l);
            }
        }

        @Override
        public void onUserLeave(long l, int i) {
            status = STATE_IDLE;
            if (delegateManager != null) {
                delegateManager.onUserHangup(l);
            }
        }

        @Override
        public void onUserAudioStart(long l) {
            if (!ProfileManager.getInstance().isCurrentUser(l)) {
                NERtcEx.getInstance().subscribeRemoteAudioStream(l, true);
            }
        }

        @Override
        public void onUserAudioStop(long l) {

        }

        @Override
        public void onUserVideoStart(long l, int i) {
            if (!ProfileManager.getInstance().isCurrentUser(l)) {
                NERtcEx.getInstance().subscribeRemoteVideoStream(l, NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh, true);
            }
            if (delegateManager != null) {
                delegateManager.onCameraAvailable(l, true);
            }
        }

        @Override
        public void onUserVideoStop(long l) {
            if (delegateManager != null) {
                delegateManager.onCameraAvailable(l, false);
            }
        }

        @Override
        public void onDisconnect(int i) {

        }
    };


    private NERTCVideoCallImpl(Context context) {
        NERtcParameters parameters = new NERtcParameters();
        NERtc.getInstance().setParameters(parameters); //先设置参数，后初始化
        try {
            String appKey = NativeConfig.getAppKey();
            NERtc.getInstance().init(context, appKey, rtcCallback, null);
        } catch (Exception e) {
            ToastUtils.showShort("SDK初始化失败");
            return;
        }
        delegateManager = new NERTCInternalDelegateManager();
        NIMClient.getService(SignallingServiceObserver.class).observeOnlineNotification(nimOnlineObserver, true);
        NIMClient.getService(SignallingServiceObserver.class).observeOfflineNotification(nimOfflineObserver, true);
    }

    @Override
    public void addDelegate(NERTCCallingDelegate delegate) {
        delegateManager.addDelegate(delegate);
    }

    @Override
    public void removeDelegate(NERTCCallingDelegate delegate) {
        delegateManager.removeDelegate(delegate);
    }

    @Override
    public void setupRemoteView(NERtcVideoView videoRender, long uid) {
        videoRender.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
        NERtc.getInstance().setupRemoteVideoCanvas(videoRender, uid);
    }

    @Override
    public void setupLocalView(NERtcVideoView videoRender) {
        videoRender.setZOrderMediaOverlay(true);
        videoRender.setScalingType(NERtcConstants.VideoScalingType.SCALE_ASPECT_BALANCED);
        NERtc.getInstance().setupLocalVideoCanvas(videoRender);
    }

    @Override
    public void setTimeOut(int timeOut) {
        if (timeOut < TIME_OUT_LIMITED) {
            this.timeOut = timeOut;
        }
    }

    /**
     * 启动倒计时，用于实现timeout
     */
    private void startCount() {
        if (timer != null) {
            timer.cancel();
        } else {
            timer = new CountDownTimer(timeOut, 1000) {
                @Override
                public void onTick(long l) {
                    if (status != STATE_CALL_OUT) {
                        timer.cancel();
                    }
                }

                @Override
                public void onFinish() {
                    if (delegateManager != null) {
                        delegateManager.timeOut();
                        NERTCVideoCallImpl.this.cancel();
                    }
                }
            };
        }
        timer.start();
    }

    @Override
    public void call(final String userId, ChannelType type) {
        final String requestId = String.valueOf(System.currentTimeMillis());
        status = STATE_CALL_OUT;
        startCount();//启动倒计时
        CallParamBuilder paramBuilder = new CallParamBuilder(type, userId, requestId);
        paramBuilder.offlineEnabled(true);
        //信令呼叫
        NIMClient.getService(SignallingService.class).call(paramBuilder).setCallback(new RequestCallbackWrapper<ChannelFullInfo>() {

            @Override
            public void onResult(int code, ChannelFullInfo result, Throwable exception) {
                if (result != null) {
                    String channelId = result.getChannelId();
                    //保留邀请信息，取消用
                    invitedParam = new InviteParamBuilder(result.getChannelId(), userId, requestId);
                    imChannelId = result.getChannelId();
                    long uid = ProfileManager.getInstance().getUserModel().imAccid;
                    joinChannel(null, channelId, uid);
                } else {
                    Log.d(LOG_TAG, "call failed code = " + code);
                    if (delegateManager != null) {
                        delegateManager.onError(code, "呼叫失败");
                    }
                    status = STATE_IDLE;
                }
            }
        });

    }


    /**
     * 加入视频通话频道
     *
     * @param token
     * @param uid
     * @param channelName
     * @return 0 方法调用成功，其他失败
     */
    private int joinChannel(String token, String channelName, long uid) {
        return NERtcEx.getInstance().joinChannel(token, channelName, uid);
    }

    @Override
    public void accept(InviteParamBuilder inviteParam) {
        UserModel userModel = ProfileManager.getInstance().getUserModel();
        final long selfUid = userModel.imAccid;
        NIMClient.getService(SignallingService.class).acceptInviteAndJoin(inviteParam, selfUid).setCallback(
                new RequestCallbackWrapper<ChannelFullInfo>() {

                    @Override
                    public void onResult(int code, ChannelFullInfo channelFullInfo, Throwable throwable) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            imChannelId = channelFullInfo.getChannelId();
                            joinChannel(null, channelFullInfo.getChannelId(), selfUid);
                        } else {
                            //do something
                        }
                    }
                });
    }

    @Override
    public void reject(InviteParamBuilder inviteParam) {
        NIMClient.getService(SignallingService.class).rejectInvite(inviteParam);
        status = STATE_IDLE;
    }

    @Override
    public void hangup() {
        //离开NERtc的channel
        if (haveJoinNertcChannel) {
            NERtc.getInstance().leaveChannel();
        }
        //离开信令的channel
        if (!TextUtils.isEmpty(imChannelId)) {
            leaveAndCloseIMChannel(imChannelId);
        }
        status = STATE_IDLE;
    }

    @Override
    public void cancel() {
        if (invitedParam != null) {
            NIMClient.getService(SignallingService.class).cancelInvite(invitedParam);
            hangup();
        }
    }

    private void leaveAndCloseIMChannel(String channelId) {
        NIMClient.getService(SignallingService.class).leave(channelId, false, null)
                .setCallback(new RequestCallbackWrapper<Void>() {

                    @Override
                    public void onResult(int code, Void result, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            imChannelId = null;
                        }
                    }
                });

        NIMClient.getService(SignallingService.class).close(channelId, false, null)
                .setCallback(new RequestCallbackWrapper<Void>() {
                    @Override
                    public void onResult(int code, Void result, Throwable exception) {
                        if (code == ResponseCode.RES_SUCCESS) {
                            imChannelId = null;
                        }
                    }
                });

    }

    @Override
    public void enableCamera(boolean enable) {
        NERtcEx.getInstance().enableLocalVideo(enable);
    }

    @Override
    public void switchCamera() {
        NERtcEx.getInstance().switchCamera();
    }

    @Override
    public void setMicMute(boolean isMute) {
        NERtcEx.getInstance().muteLocalAudioStream(isMute);
    }

    private void destroy() {
        NIMClient.getService(SignallingServiceObserver.class).observeOnlineNotification(nimOnlineObserver, false);
        NIMClient.getService(SignallingServiceObserver.class).observeOfflineNotification(nimOfflineObserver, false);
        NERtc.getInstance().release();
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }
}
