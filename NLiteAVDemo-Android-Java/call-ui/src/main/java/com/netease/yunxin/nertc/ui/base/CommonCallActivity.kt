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
import com.netease.lava.api.IVideoRender
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
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.ui.floating.FloatingPermission
import com.netease.yunxin.nertc.ui.p2p.CallUIFloatingWindowMgr
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.utils.AppForegroundWatcherHelper
import com.netease.yunxin.nertc.ui.utils.PermissionTipDialog
import com.netease.yunxin.nertc.ui.utils.SwitchCallTypeConfirmDialog
import com.netease.yunxin.nertc.ui.view.OverLayPermissionDialog

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

    protected val isLocalSmallVideo
        get() = CallUIOperationsMgr.callInfoWithUIState.isLocalSmallVideo

    protected val isVirtualBlur
        get() = CallUIOperationsMgr.callInfoWithUIState.isVirtualBlur

    protected var uiConfig: P2PUIConfig? = null

    protected val isFromFloatingWindow: Boolean
        get() {
            return intent.getBooleanExtra(
                Constants.PARAM_KEY_FLAG_IS_FROM_FLOATING_WINDOW,
                false
            ) || CallUIFloatingWindowMgr.isFloating()
        }

    private var occurError = false

    private var switchConfirmDialog: SwitchCallTypeConfirmDialog? = null

    private var permissionTipDialog: PermissionTipDialog? = null

    private var overLayPermissionDialog: OverLayPermissionDialog? = null

    private val watcher = object : AppForegroundWatcherHelper.Watcher() {
        override fun onBackground() {
            if (uiConfig?.enableFloatingWindow == true &&
                uiConfig?.enableAutoFloatingWindowWhenHome == true &&
                CallUIOperationsMgr.currentCallState() != CallState.STATE_INVITED &&
                CallUIOperationsMgr.currentCallState() != CallState.STATE_IDLE
            ) {
                doShowFloatingWindowInner()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 禁止自动锁屏
        configWindow()
        // 取消呼叫来电通知
        CallUIOperationsMgr.cancelCallNotification(this)
        // 初始化呼叫信息
        channelId = callParam.getChannelId()
        uiConfig = provideUIConfig(callParam)?.apply {
            ALog.d(tag, "current P2PUIConfig is $this.")
        }
        if (!isFromFloatingWindow) {
            CallUIOperationsMgr.initCallInfoAndUIState(
                CallUIOperationsMgr.CallInfoWithUIState(
                    callParam = initIntentForCallParam()
                ),
                foregroundServiceConfig = if (uiConfig?.enableForegroundService == true) {
                    CallUIOperationsMgr.CallForegroundServiceConfig(
                        this,
                        intent,
                        uiConfig?.foregroundNotificationConfig
                    )
                } else {
                    null
                }
            )
        } else {
            val info = CallUIOperationsMgr.currentSwitchTypeCallInfo()
            if (switchConfirmDialog?.isShowing != true && info?.state == SwitchCallState.INVITE) {
                showSwitchCallTypeConfirmDialog(info.callType)
            }
        }
        doOnCreate(savedInstanceState)
        // 配置前后台监听
        AppForegroundWatcherHelper.addWatcher(watcher)
    }

    open fun doOnCreate(savedInstanceState: Bundle?) {
        setContentView(provideLayoutId())
        // 由于页面启动耗时，可能出现页面启动中通话被挂断，此时需要销毁页面
        if (callParam.isCalled && callEngine.callInfo.callStatus == CallState.STATE_IDLE) {
            releaseAndFinish(false)
            return
        }
        callEngine.addCallDelegate(this)
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
        if (overLayPermissionDialog?.isShowing == true &&
            FloatingPermission.isFloatPermissionValid(this)
        ) {
            overLayPermissionDialog?.dismiss()
            overLayPermissionDialog = null
        }
        if (CallUIFloatingWindowMgr.isFloating()) {
            CallUIFloatingWindowMgr.releaseFloat(false)
        }
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

    override fun onPause() {
        super.onPause()
        if (isFinishing) {
            val floatingEnable =
                uiConfig?.enableFloatingWindow != true || !CallUIFloatingWindowMgr.isFloating()
            if (floatingEnable) {
                stopVideoPreview()
            }
            releaseAndFinish(
                CallUIOperationsMgr.currentCallState() != CallState.STATE_IDLE && floatingEnable
            )
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // 移除前后台监听
        AppForegroundWatcherHelper.removeWatcher(watcher)
        permissionTipDialog?.dismiss()
        permissionTipDialog = null
        switchConfirmDialog?.dismiss()
        switchConfirmDialog = null
    }

    override fun onBackPressed() {
        super.onBackPressed()
        releaseAndFinish(true)
    }

    protected abstract fun provideLayoutId(): Int

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
    protected open fun doVirtualBlur(enable: Boolean = !isVirtualBlur) {
        CallUIOperationsMgr.doVirtualBlur(enable)
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

    protected open fun doCall(
        observer: NEResultObserver<CommonResult<NECallInfo>>?
    ) {
        CallUIOperationsMgr.doCall(
            callParam
        ) { result ->
            channelId = result?.data?.signalInfo?.channelId
            observer?.onResult(result)
        }
    }

    @JvmOverloads
    protected open fun doAccept(observer: NEResultObserver<CommonResult<NECallInfo>>? = null) {
        CallUIOperationsMgr.doAccept(observer)
    }

    @JvmOverloads
    protected open fun doHangup(
        observer: NEResultObserver<CommonResult<Void>>? = null,
        channelId: String? = null,
        extraInfo: String? = null
    ) {
        CallUIOperationsMgr.doHangup(observer, channelId = channelId, extraInfo = extraInfo)
    }

    @JvmOverloads
    protected open fun doSwitchCallType(
        callType: Int,
        switchCallState: Int,
        observer: NEResultObserver<CommonResult<Void>>? = null
    ) {
        CallUIOperationsMgr.doSwitchCallType(callType, switchCallState, observer)
    }

    protected open fun setupLocalView(
        view: NERtcVideoView?,
        action: ((NERtcVideoView?) -> Unit)? = {
            it?.run {
                setZOrderMediaOverlay(true)
                setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
            }
        }
    ) {
        CallUIOperationsMgr.setupLocalView(view, action)
    }

    protected open fun setupRemoteView(
        view: NERtcVideoView?,
        action: ((NERtcVideoView?) -> Unit)? = {
            it?.run {
                setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
            }
        }
    ) {
        CallUIOperationsMgr.setupRemoteView(view)
    }

    protected open fun currentCallState(): Int = CallUIOperationsMgr.currentCallState()

    protected open fun releaseAndFinish(finishCall: Boolean = true) {
        callEngine.removeCallDelegate(this)
        if (!isFinishing) {
            finish()
        }
        if (finishCall) {
            CallUIOperationsMgr.doHangup(null, channelId = channelId)
            CallUIOperationsMgr.releaseCallInfoAndUIState(channelId = channelId, force = true)
        }
    }

    protected open fun showPermissionDialog(clickListener: View.OnClickListener): PermissionTipDialog {
        return PermissionTipDialog(this, clickListener).apply {
            this@CommonCallActivity.permissionTipDialog = this
            show()
        }
    }

    protected open fun showSwitchCallTypeConfirmDialog(callType: Int): SwitchCallTypeConfirmDialog {
        val dialog = this.switchConfirmDialog
        if (dialog?.isShowing == true) {
            return dialog
        }
        return SwitchCallTypeConfirmDialog(this, {
            doSwitchCallType(it, SwitchCallState.ACCEPT)
        }, {
            doSwitchCallType(it, SwitchCallState.REJECT)
        }).apply {
            this@CommonCallActivity.switchConfirmDialog = this
            show(callType)
        }
    }

    protected open fun showOverlayPermissionDialog(clickListener: View.OnClickListener): OverLayPermissionDialog {
        return OverLayPermissionDialog(this, clickListener).apply {
            this@CommonCallActivity.overLayPermissionDialog = this
            show()
        }
    }

    protected open fun doShowFloatingWindow() {
        ALog.dApi(tag, "doShowFloatingWindow")
        doShowFloatingWindowInner()
    }

    private fun doShowFloatingWindowInner() {
        ALog.d(tag, "doShowFloatingWindowInner")
        if (!FloatingPermission.isFloatPermissionValid(this)) {
            if (overLayPermissionDialog?.isShowing != true) {
                showOverlayPermissionDialog {
                    FloatingPermission.requireFloatPermission(this)
                }
            }
            return
        }
        if (!CallUIFloatingWindowMgr.isFloating()) {
            CallUIFloatingWindowMgr.showFloat(this.applicationContext)
        }
        finish()
    }

    protected open fun startVideoPreview() {
        CallUIOperationsMgr.startVideoPreview()
    }

    protected open fun stopVideoPreview() {
        CallUIOperationsMgr.stopVideoPreview()
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
