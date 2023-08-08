/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.service.CallForegroundService
import com.netease.yunxin.nertc.ui.utils.PermissionTipDialog

abstract class CommonCallActivity : AppCompatActivity(), NECallEngineDelegate {
    private val tag = "CommonCallActivity"

    protected val callParam
        get() = CallUIOperationsMgr.callInfoWithUIState.callParam

    protected var channelId: String? = null

    protected val callEngine: NECallEngine
        get() = CallUIOperationsMgr.callEngine

    protected val isLocalMuteAudio
        get() = CallUIOperationsMgr.callInfoWithUIState.isLocalMuteAudio

    protected val isLocalMuteVideo
        get() = CallUIOperationsMgr.callInfoWithUIState.isLocalMuteVideo

    protected val isLocalMuteSpeaker
        get() = CallUIOperationsMgr.callInfoWithUIState.isLocalMuteSpeaker

    protected val isRemoteMuteVideo
        get() = CallUIOperationsMgr.callInfoWithUIState.isRemoteMuteVideo

    protected val cameraDeviceStatus
        get() = CallUIOperationsMgr.callInfoWithUIState.cameraDeviceStatus

    protected var uiConfig: P2PUIConfig? = null

    private var occurError = false

    private var serviceId: String? = null

    private var permissionTipDialog: PermissionTipDialog? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 禁止自动锁屏
        configWindow()
        // 取消呼叫来电通知
        CallUIOperationsMgr.cancelCallNotification(this)
        // 初始化呼叫信息
        CallUIOperationsMgr.initCallInfoAndUIState(
            CallUIOperationsMgr.CallInfoWithUIState(callParam = initIntentForCallParam())
        )
        channelId = callParam.getChannelId()
        uiConfig = provideUIConfig(callParam)?.apply {
            ALog.d(tag, "current P2PUIConfig is $this.")
        }
        doOnCreate(savedInstanceState)
    }

    open fun doOnCreate(savedInstanceState: Bundle?) {
        provideLayoutId()?.run {
            setContentView(this)
        } ?: provideLayoutView()?.run {
            setContentView(this)
        } ?: throw IllegalArgumentException("provideLayoutId or provideLayoutView must not be null.")

        // 由于页面启动耗时，可能出现页面启动中通话被挂断，此时需要销毁页面
        if (callParam.isCalled && callEngine.callInfo.callStatus == CallState.STATE_IDLE) {
            releaseAndFinish(false)
            return
        }
        callEngine.addCallDelegate(this)
        if (uiConfig?.enableForegroundService == true) {
            serviceId = CallForegroundService.launchForegroundService(
                this,
                intent,
                uiConfig?.foregroundNotificationConfig
            )
        }
    }

    open fun configWindow() {
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
    }

    override fun onResume() {
        super.onResume()
        when (cameraDeviceStatus) {
            NERtcConstants.VideoDeviceState.DISCONNECTED,
            NERtcConstants.VideoDeviceState.FREEZED,
            NERtcConstants.VideoDeviceState.UNKNOWNERROR -> {
                callEngine.enableLocalVideo(false)
                if (callParam.callType != NECallType.VIDEO) {
                    return
                }
                if (isLocalMuteVideo && uiConfig?.closeVideoType != Constants.CLOSE_TYPE_MUTE) {
                    return
                }
                callEngine.enableLocalVideo(true)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        callEngine.removeCallDelegate(this)
        if (uiConfig?.enableForegroundService == true) {
            serviceId?.run {
                CallForegroundService.stopService(this@CommonCallActivity, this)
            }
        }
        permissionTipDialog?.dismiss()
        permissionTipDialog = null
        CallUIOperationsMgr.releaseCallInfoAndUIState(channelId = channelId)
    }

    override fun onBackPressed() {
        super.onBackPressed()
        releaseAndFinish(true)
    }

    protected open fun provideLayoutId(): Int? = null

    protected open fun provideLayoutView():View? = null

    protected open fun provideUIConfig(callParam: CallParam?): P2PUIConfig? {
        return P2PUIConfig()
    }

    protected open fun configTimeTick(config: CallUIOperationsMgr.TimeTickConfig?) {
        CallUIOperationsMgr.configTimeTick(config)
    }

    @JvmOverloads
    protected open fun doConfigSpeaker(on: Boolean = isSpeakerOn()) {
        CallUIOperationsMgr.doConfigSpeaker(on)
    }

    protected open fun isSpeakerOn(): Boolean {
        return CallUIOperationsMgr.isSpeakerOn()
    }

    @JvmOverloads
    protected open fun doMuteAudio(mute: Boolean = !isLocalMuteAudio) {
        CallUIOperationsMgr.doMuteAudio(mute)
    }

    @JvmOverloads
    protected open fun doMuteVideo(mute: Boolean = !isLocalMuteVideo) {
        when (uiConfig?.closeVideoType ?: Constants.CLOSE_TYPE_MUTE) {
            Constants.CLOSE_TYPE_MUTE -> {
                CallUIOperationsMgr.doMuteVideo(mute)
            }

            Constants.CLOSE_TYPE_DISABLE -> {
                CallUIOperationsMgr.updateUIState(isLocalMuteVideo = mute)
                NERtcEx.getInstance().enableLocalVideo(!mute)
            }

            Constants.CLOSE_TYPE_COMPAT -> {
                if (mute) {
                    CallUIOperationsMgr.doMuteVideo(true)
                    NERtcEx.getInstance().enableLocalVideo(false)
                } else {
                    NERtcEx.getInstance().enableLocalVideo(true)
                    CallUIOperationsMgr.doMuteVideo(false)
                }
            }
        }
    }

    protected open fun doSwitchCamera() {
        CallUIOperationsMgr.doSwitchCamera()
    }

    protected fun doCall(
        observer: NEResultObserver<CommonResult<NECallInfo>>?
    ) {
        CallUIOperationsMgr.doCall(callParam, observer)
    }

    @JvmOverloads
    protected fun doAccept(observer: NEResultObserver<CommonResult<NECallInfo>>? = null) {
        CallUIOperationsMgr.doAccept(observer)
    }

    @JvmOverloads
    protected fun doHangup(
        observer: NEResultObserver<CommonResult<Void>>? = null,
        channelId: String? = null,
        extraInfo: String? = null
    ) {
        CallUIOperationsMgr.doHangup(observer, channelId = channelId, extraInfo = extraInfo)
    }

    @JvmOverloads
    protected fun doSwitchCallType(
        callType: Int,
        switchCallState: Int,
        observer: NEResultObserver<CommonResult<Void>>? = null
    ) {
        CallUIOperationsMgr.doSwitchCallType(callType, switchCallState, observer)
    }

    protected open fun setupLocalView(view: NERtcVideoView?) {
        CallUIOperationsMgr.setupLocalView(view)
    }

    protected open fun setupRemoteView(view: NERtcVideoView?) {
        CallUIOperationsMgr.setupRemoteView(view)
    }

    protected open fun currentCallState(): Int = CallUIOperationsMgr.currentCallState()

    protected open fun releaseAndFinish(finishCall: Boolean = true) {
        callEngine.removeCallDelegate(this)
        if (!isFinishing) {
            finish()
        }
    }

    protected fun showPermissionDialog(clickListener: View.OnClickListener): PermissionTipDialog {
        return PermissionTipDialog(this, clickListener).apply {
            this@CommonCallActivity.permissionTipDialog = this
            show()
        }
    }

    override fun onReceiveInvited(info: NEInviteInfo) {
    }

    override fun onCallConnected(info: NECallInfo) {
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
    }

    override fun onCallEnd(info: NECallEndInfo) {
    }

    override fun onVideoAvailable(userId: String?, available: Boolean) {
    }

    override fun onVideoMuted(userId: String?, mute: Boolean) {
    }

    override fun onAudioMuted(userId: String?, mute: Boolean) {
    }

    protected open fun initIntentForCallParam(): CallParam {
        return intent.getParcelableExtra(Constants.PARAM_KEY_CALL) ?: run {
            if (occurError) {
                return CallParam(true)
            }
            occurError = true
            releaseAndFinish(true)
            ALog.e(tag, "CallParam is null. Then finish this activity.")
            CallParam(true)
        }
    }
}
