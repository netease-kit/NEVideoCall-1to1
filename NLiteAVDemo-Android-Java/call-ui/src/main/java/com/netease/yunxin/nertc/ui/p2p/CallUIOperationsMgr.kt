/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import android.annotation.SuppressLint
import android.app.NotificationManager
import android.content.Context
import android.media.AudioManager
import com.netease.lava.api.IVideoRender
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.alog.ParameterMap
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegateAbs
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.param.NECallParam
import com.netease.yunxin.kit.call.p2p.param.NEHangupParam
import com.netease.yunxin.kit.call.p2p.param.NESwitchParam
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.channelId
import com.netease.yunxin.nertc.ui.base.getChannelId
import com.netease.yunxin.nertc.ui.service.DefaultIncomingCallEx.Companion.INCOMING_CALL_NOTIFY_ID
import com.netease.yunxin.nertc.ui.utils.SecondsTimer

@SuppressLint("StaticFieldLeak")
object CallUIOperationsMgr {
    private const val TAG = "CallUIOperationsMgr"

    val callEngine: NECallEngine
        get() = NECallEngine.sharedInstance()

    var callInfoWithUIState: CallInfoWithUIState = CallInfoWithUIState()
        private set

    private val callEngineDelegate = object : NECallEngineDelegateAbs() {
        override fun onCallTypeChange(info: NECallTypeChangeInfo) {
            if (info.state == SwitchCallState.ACCEPT) {
                callInfoWithUIState.callParam.callType = info.callType
            }
        }

        override fun onVideoAvailable(userId: String?, available: Boolean) {
            callInfoWithUIState.callParam.run {
                userId?.run {
                    if (this == otherAccId) {
                        callInfoWithUIState.isRemoteMuteVideo = !available
                    }
                }
            }
        }

        override fun onVideoMuted(userId: String?, mute: Boolean) {
            callInfoWithUIState.callParam.run {
                userId?.run {
                    if (this == otherAccId) {
                        callInfoWithUIState.isRemoteMuteVideo = mute
                    }
                }
            }
        }

        override fun onCallConnected(info: NECallInfo) {
            timer?.run { cancel() }
            timer = (
                timeTickConfig?.run {
                    SecondsTimer(delay = delay, period = period)
                } ?: SecondsTimer()
                ).apply {
                start {
                    timeTickConfig?.onTimeTick?.invoke(it)
                }
            }
        }
    }

    private val neRtcCallback = object : NERtcCallbackExTemp() {
        override fun onVideoDeviceStageChange(deviceState: Int) {
            if (currentCallState() == CallState.STATE_IDLE) {
                return
            }
            callInfoWithUIState.cameraDeviceStatus = deviceState
        }
    }

    private var timeTickConfig: TimeTickConfig? = null

    private var timer: SecondsTimer? = null

    private lateinit var context: Context

    init {
        callEngine.addCallDelegate(callEngineDelegate)
        NERtcCallbackProxyMgr.getInstance().addCallback(neRtcCallback)
    }

    /**
     * 初始化呼叫信息及状态
     */
    fun initCallInfoAndUIState(callInfoWithUIState: CallInfoWithUIState): String? {
        ALog.d(
            TAG,
            ParameterMap("initCallInfoAndUIState").append(
                "callInfoWithUIState",
                callInfoWithUIState
            ).toValue()
        )
        this.callInfoWithUIState = callInfoWithUIState
        return this.callInfoWithUIState.callParam.getChannelId()
    }

    /**
     * 释放呼叫信息及状态
     */
    fun releaseCallInfoAndUIState(force: Boolean = false, channelId: String? = null) {
        ALog.dApi(
            TAG,
            ParameterMap("releaseCallInfoAndUIState").append("force", force)
                .append("channelId", channelId)
        )
        if (channelId != callInfoWithUIState.callParam.getChannelId() && !force) {
            ALog.e(
                TAG,
                "releaseCallInfoAndUIState, current channelId is ${callInfoWithUIState.callParam.getChannelId()}, to release channelId is $channelId."
            )
            return
        }
        this.callInfoWithUIState = CallInfoWithUIState()
        this.timer?.cancel()
        this.timer = null
        this.timeTickConfig = null
    }

    /**
     * 配置通话计时，此计时仅用来进行展示 ui 上的时间，实际通话时间以服务抄送为准
     */
    fun configTimeTick(config: TimeTickConfig?) {
        ALog.dApi(TAG, ParameterMap("configTimeTick").append("config", config))
        this.timeTickConfig = config
    }

    /**
     * 更新ui初始化状态，避免 sdk 和 ui 状态不一致
     */
    @JvmOverloads
    fun updateUIState(
        isRemoteMuteVideo: Boolean? = null,
        isLocalMuteVideo: Boolean? = null,
        isLocalMuteAudio: Boolean? = null,
        isLocalMuteSpeaker: Boolean? = null,
        cameraDeviceStatus: Int? = null
    ) {
        ALog.dApi(
            TAG,
            ParameterMap("updateInitUIState")
                .append("isRemoteMuteVideo", isRemoteMuteVideo)
                .append("isLocalMuteVideo", isLocalMuteVideo)
                .append("isLocalMuteAudio", isLocalMuteAudio)
                .append("isLocalMuteSpeaker", isLocalMuteSpeaker)
                .append("cameraDeviceStatus", cameraDeviceStatus)
        )
        isRemoteMuteVideo?.run {
            callInfoWithUIState.isRemoteMuteVideo = this
        }
        isLocalMuteVideo?.run {
            callInfoWithUIState.isLocalMuteVideo = this
        }
        isLocalMuteAudio?.run {
            callInfoWithUIState.isLocalMuteAudio = this
        }
        isLocalMuteSpeaker?.run {
            callInfoWithUIState.isLocalMuteSpeaker = this
        }
        cameraDeviceStatus?.run {
            callInfoWithUIState.cameraDeviceStatus = this
        }
    }

    /**
     * 发起呼叫
     */
    fun doCall(
        callParam: CallParam,
        observer: NEResultObserver<CommonResult<NECallInfo>>?
    ) {
        ALog.dApi(
            TAG,
            ParameterMap("doCall")
                .append("callParam", callParam)
                .append("observer", observer)
        )
        with(callParam) {
            callEngine.call(
                NECallParam.Builder(calledAccId)
                    .callType(callType)
                    .extraInfo(callExtraInfo)
                    .globalExtraCopy(globalExtraCopy)
                    .pushConfig(pushConfig)
                    .rtcChannelName(rtcChannelName)
                    .build()
            ) { result ->
                ALog.d(TAG, "call result is $result.")
                observer?.onResult(result)
                callParam.channelId(callEngine.callInfo.signalInfo.channelId)
            }
        }
    }

    /**
     * 接听
     */
    fun doAccept(observer: NEResultObserver<CommonResult<NECallInfo>>?) {
        ALog.dApi(TAG, ParameterMap("doAccept").append("observer", observer))
        callEngine.accept { result ->
            ALog.d(TAG, "accept result is $result.")
            observer?.onResult(result)
        }
    }

    /**
     * 挂断
     */
    fun doHangup(
        observer: NEResultObserver<CommonResult<Void>>?,
        channelId: String? = null,
        extraInfo: String? = null
    ) {
        ALog.dApi(
            TAG,
            ParameterMap("doHangup").append("observer", observer).append("extraInfo", extraInfo)
        )
        callEngine.hangup(
            NEHangupParam(channelId ?: callInfoWithUIState.callParam.getChannelId(), extraInfo)
        ) { result ->
            ALog.d(TAG, "hangup result is $result.")
            observer?.onResult(result)
        }
    }

    /**
     * 切换通话类型
     */
    fun doSwitchCallType(
        callType: Int,
        switchCallState: Int,
        observer: NEResultObserver<CommonResult<Void>>?
    ) {
        ALog.dApi(
            TAG,
            ParameterMap("doSwitchCallType")
                .append("callType", callType)
                .append("switchCallState", switchCallState)
                .append("observer", observer)
        )
        callEngine.switchCallType(
            NESwitchParam(callType, switchCallState)
        ) { result ->
            ALog.d(TAG, "switch type result is $result.")
            observer?.onResult(result)
        }
    }

    /**
     * 设置本地画布
     */
    @JvmOverloads
    fun setupLocalView(
        view: NERtcVideoView?,
        action: ((NERtcVideoView?) -> Unit)? = {
            it?.run {
                setZOrderMediaOverlay(true)
                setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
            }
        }
    ) {
        ALog.dApi(
            TAG,
            ParameterMap("setupLocalView").append("view", view).append("action", action)
        )
        action?.invoke(view)
        callEngine.setupLocalView(view)
    }

    /**
     * 设置远端画布
     */
    @JvmOverloads
    fun setupRemoteView(
        view: NERtcVideoView?,
        action: ((NERtcVideoView?) -> Unit)? = {
            it?.setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
        }
    ) {
        ALog.dApi(
            TAG,
            ParameterMap("setupRemoteView").append("view", view).append("action", action)
        )
        action?.invoke(view)
        callEngine.setupRemoteView(view)
    }

    /**
     * 配置麦克风/扬声器模式
     */
    @JvmOverloads
    fun doConfigSpeaker(enableSpeaker: Boolean = !isSpeakerOn()) {
        val action = {
            callInfoWithUIState.isLocalMuteSpeaker = !enableSpeaker
            NERtcEx.getInstance().isSpeakerphoneOn = enableSpeaker
        }
        if (CallKitUI.options?.joinRtcWhenCall == true && !callInfoWithUIState.callParam.isCalled) {
            action.invoke()
            return
        }
        ALog.dApi(TAG, ParameterMap("doConfigSpeaker").append("enableSpeaker", enableSpeaker))
        (context.getSystemService(Context.AUDIO_SERVICE) as AudioManager).run {
            @Suppress("DEPRECATION")
            if (isBluetoothA2dpOn) {
                startBluetoothSco()
                return
            }
        }
        if (!callInfoWithUIState.callParam.isCalled && CallKitUI.options?.joinRtcWhenCall != true && currentCallState() != CallState.STATE_DIALOG) {
            (context.getSystemService(Context.AUDIO_SERVICE) as AudioManager).run {
                if (enableSpeaker) {
                    mode = AudioManager.MODE_NORMAL
                    isSpeakerphoneOn = true
                } else {
                    mode = AudioManager.MODE_IN_CALL
                    isSpeakerphoneOn = false
                }
            }
        }
        action.invoke()
    }

    /**
     * 判断扬声器是否开启
     */
    fun isSpeakerOn(): Boolean {
        ALog.dApi(TAG, ParameterMap("isSpeakerOn"))
        (context.getSystemService(Context.AUDIO_SERVICE) as AudioManager).run {
            @Suppress("DEPRECATION")
            if (isBluetoothA2dpOn) {
                return true
            }
        }
        val result = if (callEngine.callInfo.callStatus != CallState.STATE_DIALOG) {
            !callInfoWithUIState.isLocalMuteSpeaker
        } else {
            NERtcEx.getInstance().isSpeakerphoneOn
        }
        ALog.dApi(TAG, ParameterMap("isSpeakerOn").append("result", result))
        return result
    }

    /**
     * 关闭/开启音频
     */
    @JvmOverloads
    fun doMuteAudio(mute: Boolean = !callInfoWithUIState.isLocalMuteAudio) {
        ALog.dApi(TAG, ParameterMap("doMuteAudio").append("mute", mute))
        callInfoWithUIState.isLocalMuteAudio = mute
        callEngine.muteLocalAudio(callInfoWithUIState.isLocalMuteAudio)
    }

    /**
     * 关闭/开启视频
     */
    @JvmOverloads
    fun doMuteVideo(mute: Boolean = !callInfoWithUIState.isLocalMuteVideo) {
        ALog.dApi(TAG, ParameterMap("doMuteVideo").append("mute", mute))
        callInfoWithUIState.isLocalMuteVideo = mute
        callEngine.muteLocalVideo(callInfoWithUIState.isLocalMuteVideo)
    }

    /**
     * 切换摄像头方向
     */
    fun doSwitchCamera() {
        ALog.dApi(TAG, ParameterMap("doSwitchCamera"))
        callEngine.switchCamera()
    }

    /**
     * 取消来电通知
     */
    fun cancelCallNotification(context: Context, notificationId: Int = INCOMING_CALL_NOTIFY_ID) {
        ALog.dApi(
            TAG,
            ParameterMap("cancelCallNotification").append("context", context)
                .append("notificationId", notificationId)
        )
        try {
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager)
                ?.cancel(notificationId)
        } catch (exception: Exception) {
            ALog.e(TAG, "call cancel notification", exception)
        }
    }

    /**
     * 当前的呼叫状态
     */
    fun currentCallState(): Int {
        return callInfoWithUIState.callState
    }

    internal fun load(context: Context) {
        ALog.dApi(TAG, ParameterMap("load"))
        this.context = context.applicationContext
        releaseCallInfoAndUIState(force = true)
    }

    internal fun unload() {
        ALog.dApi(TAG, ParameterMap("unload"))
        releaseCallInfoAndUIState(force = true)
    }

    /**
     * 记录当前通话的信息及ui状态
     */
    class CallInfoWithUIState(
        val callParam: CallParam = CallParam(false, -1),
        var isRemoteMuteVideo: Boolean = false,
        var isLocalMuteVideo: Boolean = false,
        var isLocalMuteAudio: Boolean = false,
        var isLocalMuteSpeaker: Boolean = (
            CallKitUI.baseContext()
                ?.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            )?.isSpeakerphoneOn
            ?: !NERtcEx.getInstance().isSpeakerphoneOn,
        var cameraDeviceStatus: Int = NERtcConstants.VideoDeviceState.OPENED
    ) {
        val callState: Int
            get() = callEngine.callInfo.callStatus

        override fun toString(): String {
            return "CallInfoWithUIState(callParam=$callParam, isRemoteMuteVideo=$isRemoteMuteVideo, isLocalMuteVideo=$isLocalMuteVideo, isLocalMuteAudio=$isLocalMuteAudio, isLocalMuteSpeaker=$isLocalMuteSpeaker, cameraDeviceStatus=$cameraDeviceStatus)"
        }
    }

    class TimeTickConfig(
        var onTimeTick: (Long) -> Unit,
        val period: Long = 1000L,
        val delay: Long = 0L
    ) {
        override fun toString(): String {
            return "TimeTickConfig(onTimeTick=$onTimeTick, period=$period, delay=$delay)"
        }
    }
}
