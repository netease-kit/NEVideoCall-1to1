/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import android.Manifest
import android.content.DialogInterface
import android.graphics.Color
import android.os.Bundle
import android.text.TextUtils
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.appcompat.app.AlertDialog
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.NERtcConstants.ErrorCode.ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.nimlib.sdk.ResponseCode
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.internal.NECallEngineImpl
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallInitRtcMode
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEHangupReasonCode
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CommonCallActivity
import com.netease.yunxin.nertc.ui.base.currentUserIsCaller
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.ActivityP2PcallBinding
import com.netease.yunxin.nertc.ui.utils.PermissionTipDialog
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.requestPermission
import com.netease.yunxin.nertc.ui.utils.toastShort

open class P2PCallActivity : CommonCallActivity() {
    private val tag = "P2PCallActivity"

    private var startPreviewCode = -1

    private var callFinished = true

    private var localIsSmallVideo = true

    private lateinit var binding: ActivityP2PcallBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityP2PcallBinding.inflate(layoutInflater)
        val view = binding.root
        setContentView(view)
    }

    private val onClickListener = View.OnClickListener { v ->
        when (v) {
            binding.ivAccept -> {
                v.isEnabled = false
                binding.ivSwitchType.isEnabled = false
                binding.ivCallSwitchType.isEnabled = false
                doAccept()
            }

            binding.ivReject -> {
                binding.ivAccept.isEnabled = false
                v.isEnabled = false
                doHangup()
            }

            binding.ivCancel -> {
                if (!callFinished) {
                    getString(R.string.tip_invite_was_sending).toastShort(this)
                    return@OnClickListener
                }
                v.isEnabled = false
                doHangup()
            }

            binding.ivHangUp -> {
                v.isEnabled = false
                doHangup()
            }

            binding.ivCallMuteAudio,
            binding.ivMuteAudio -> doMuteAudioSwitch(v as ImageView)

            binding.ivMuteVideo -> doMuteVideo(binding.ivMuteVideo)
            binding.ivSwitchCamera -> doSwitchCamera()
            binding.ivCallSwitchType,
            binding.ivSwitchType,
            binding.ivCallChannelTypeChange -> doSwitchCallType()

            binding.ivCallSpeaker,
            binding.ivMuteSpeaker -> doConfigSpeakerSwitch(v as ImageView)

            binding.videoViewSmall -> doSwitchCanvas()
            else -> ALog.d(tag, "can't response this clicked Event for $v")
        }
    }

    private val uiRender: UIRender
        get() = if (callParam.callType == NECallType.AUDIO) {
            AudioRender()
        } else {
            VideoRender()
        }

    override fun onCallConnected(info: NECallInfo) {
        if (isFinishing) {
            return
        }
        info.otherUserInfo()?.accId.run {
            initForOnTheCall(this)
        }

        configTimeTick(
            CallUIOperationsMgr.TimeTickConfig({
                runOnUiThread { binding.tvCountdown.text = it.formatSecondTime() }
            })
        )
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (isFinishing) {
            return
        }
        when (info.state) {
            SwitchCallState.ACCEPT -> {
                binding.switchTypeTipGroup.visibility = View.GONE
                if (callEngine.callInfo.callStatus != CallState.STATE_DIALOG) {
                    if (callParam.isCalled) {
                        uiRender.renderForCalled()
                    } else {
                        uiRender.renderForCaller()
                    }
                    return
                }
                initForOnTheCall(callParam.otherAccId)
            }

            SwitchCallState.INVITE -> {
                showSwitchCallTypeConfirmDialog(info.callType)
            }

            SwitchCallState.REJECT -> {
                binding.switchTypeTipGroup.visibility = View.GONE
                getString(R.string.ui_switch_call_type_reject_tip).toastShort(
                    this@P2PCallActivity
                )
            }
        }
    }

    override fun onCallEnd(info: NECallEndInfo) {
        super.onCallEnd(info)
        configTimeTick(null)
        when (info.reasonCode) {
            NEHangupReasonCode.CALLER_REJECTED -> if (!isFinishing && !callParam.isCalled) {
                getString(R.string.tip_reject_by_other).toastShort(this@P2PCallActivity)
            }

            NEHangupReasonCode.BUSY -> if (!isFinishing && !callParam.isCalled) {
                getString(R.string.tip_busy_by_other).toastShort(this@P2PCallActivity)
            }

            NEHangupReasonCode.CALLEE_CANCELED -> if (!isFinishing && callParam.isCalled) {
                getString(R.string.tip_cancel_by_other).toastShort(this@P2PCallActivity)
            }

            NEHangupReasonCode.TIME_OUT ->
                if (!callParam.isCalled) {
                    getString(R.string.tip_timeout_by_other).toastShort(this@P2PCallActivity)
                }

            NEHangupReasonCode.OTHER_REJECTED -> getString(R.string.tip_other_client_other_reject).toastShort(
                this@P2PCallActivity
            )

            NEHangupReasonCode.OTHER_ACCEPTED -> getString(R.string.tip_other_client_other_accept).toastShort(
                this@P2PCallActivity
            )
        }
        releaseAndFinish(false)
    }

    override fun onVideoAvailable(userId: String?, available: Boolean) {
        if (isFinishing) {
            return
        }
        uiRender.updateOnTheCallState(UserState(userId, muteVideo = !available))
    }

    override fun onVideoMuted(userId: String?, mute: Boolean) {
        if (isFinishing) {
            return
        }
        uiRender.updateOnTheCallState(UserState(userId, muteVideo = mute))
    }

    override fun doOnCreate(savedInstanceState: Bundle?) {
        super.doOnCreate(savedInstanceState)
        ALog.d(tag, callParam.toString())
        initForLaunchUI()
        val dialog: PermissionTipDialog?
        if (!isGranted(
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO
            )
        ) {
            dialog = showPermissionDialog {
                getString(R.string.tip_permission_request_failed).toastShort(this)
                releaseAndFinish(true)
            }
        } else {
            if (callParam.isCalled && callEngine.callInfo.callStatus == CallState.STATE_IDLE) {
                releaseAndFinish(false)
                return
            }
            initForLaunchAction()
            return
        }
        requestPermission({ granted ->
            if (isFinishing || isDestroyed) {
                return@requestPermission
            }
            granted.forEach {
                ALog.i(tag, "granted:$it")
            }
            if (granted.containsAll(
                    listOf(
                        Manifest.permission.CAMERA,
                        Manifest.permission.RECORD_AUDIO
                    )
                )
            ) {
                dialog.dismiss()
                if (callParam.isCalled && callEngine.callInfo.callStatus == CallState.STATE_IDLE) {
                    releaseAndFinish(false)
                    return@requestPermission
                }
                initForLaunchAction()
            }
            ALog.i(tag, "extra info is ${callParam.callExtraInfo}")
        }, { deniedForever, denied ->
            denied.forEach {
                ALog.i(tag, "denied:$it")
            }
            deniedForever.forEach {
                ALog.i(tag, "deniedForever:$it")
            }
            if (deniedForever.isNotEmpty() || denied.isNotEmpty()) {
                getString(R.string.tip_permission_request_failed).toastShort(this@P2PCallActivity)
                dialog.dismiss()
                releaseAndFinish(true)
            }
        }, Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO)
    }

    override fun provideLayoutId(): Int = R.layout.activity_p2_pcall

    override fun releaseAndFinish(finishCall: Boolean) {
        super.releaseAndFinish(false)

        if (startPreviewCode == 0 || startPreviewCode == ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED) {
            NERtcEx.getInstance().setupLocalVideoCanvas(null)
            NERtcEx.getInstance().stopVideoPreview()
        }

        if (finishCall) {
            doHangup(null)
        }
    }

    override fun onBackPressed() {
        showExitDialog()
    }

    override fun onPause() {
        super.onPause()
        if (isFinishing) {
            releaseAndFinish(true)
        }
    }

    private fun showExitDialog() {
        val confirmDialog = AlertDialog.Builder(this)
        confirmDialog.setTitle(R.string.tip_dialog_finish_call_title)
        confirmDialog.setMessage(R.string.tip_dialog_finish_call_content)
        confirmDialog.setPositiveButton(
            R.string.tip_dialog_finish_call_positive
        ) { _: DialogInterface?, _: Int ->
            if (!callFinished) {
                getString(R.string.tip_invite_was_sending).toastShort(this)
                return@setPositiveButton
            }
            finish()
        }
        confirmDialog.setNegativeButton(
            R.string.tip_dialog_finish_call_negative
        ) { _: DialogInterface?, _: Int -> }
        confirmDialog.show()
    }

    private fun initForLaunchUI() {
        if (callParam.isCalled) {
            // 主叫页面初始化
            uiRender.renderForCalled()
        } else {
            // 被叫页面初始化
            uiRender.renderForCaller()
        }
    }

    private fun initForLaunchAction() {
        if (callParam.isCalled) {
            return
        }
        doCall()
        if (CallKitUI.options?.initRtcMode != NECallInitRtcMode.GLOBAL) {
            setupLocalView(binding.videoViewPreview)
        }
        if (callParam.callType == NECallType.VIDEO &&
            CallKitUI.options?.joinRtcWhenCall == false &&
            startPreviewCode != NERtcConstants.ErrorCode.OK
        ) {
            startPreviewCode = NERtcEx.getInstance().startVideoPreview().apply {
                ALog.d(tag, "initForLaunchAction startPreviewCode is $this.")
            }
        }
    }

    /**
     * 通话中页面初始化
     */
    private fun initForOnTheCall(userAccId: String? = null) {
        uiRender.renderForOnTheCall(userAccId)
    }

    private fun doCall() {
        callFinished = false

        doCall { result ->
            callFinished = true
            if (result?.isSuccessful != true && result.code != ResponseCode.RES_PEER_NIM_OFFLINE.toInt() && result.code != ResponseCode.RES_PEER_PUSH_OFFLINE.toInt()) {
                getString(R.string.tip_start_call_failed).toastShort(this@P2PCallActivity)
            }
        }
    }

    private fun doAccept() {
        if (binding.tvConnectingTip.tag != true) {
            binding.tvConnectingTip.tag = true
            binding.tvConnectingTip.visibility = View.VISIBLE
        }
        doAccept { result ->
            if (result?.isSuccessful != true) {
                getString(R.string.tip_accept_failed).toastShort(this@P2PCallActivity)
                finish()
            }
        }
    }

    private fun doHangup() {
        releaseAndFinish(true)
    }

    private fun doMuteVideo(view: ImageView) {
        doMuteVideo()
        view.setImageResource(if (isLocalMuteVideo) R.drawable.cam_off else R.drawable.cam_on)
        uiRender.updateOnTheCallState(
            UserState(
                callParam.currentAccId!!,
                muteVideo = isLocalMuteVideo
            )
        )
    }

    private fun doConfigSpeakerSwitch(
        view: ImageView? = null,
        speakerEnable: Boolean = !isSpeakerOn()
    ) {
        doConfigSpeaker(speakerEnable)
        binding.ivMuteSpeaker.setImageResource(
            if (speakerEnable) R.drawable.speaker_on else R.drawable.speaker_off
        )
        binding.ivCallSpeaker.setImageResource(
            if (speakerEnable) R.drawable.icon_call_audio_speaker_on else R.drawable.icon_call_audio_speaker_off
        )
    }

    private fun doMuteAudioSwitch(view: ImageView? = null) {
        super.doMuteAudio(!isLocalMuteAudio)
        binding.ivMuteAudio.setImageResource(
            if (isLocalMuteAudio) R.drawable.voice_off else R.drawable.voice_on
        )
        binding.ivCallMuteAudio.setImageResource(
            if (isLocalMuteAudio) R.drawable.icon_call_audio_off else R.drawable.icon_call_audio_on
        )
    }

    private fun doSwitchCallType(switchCallState: Int = SwitchCallState.INVITE) {
        if (!NetworkUtils.isConnected()) {
            getString(R.string.tip_network_error).toastShort(this)
            return
        }
        val toCallType = if (callParam.callType == NECallType.VIDEO) {
            NECallType.AUDIO
        } else {
            NECallType.VIDEO
        }

        doSwitchCallType(
            toCallType,
            switchCallState,
            object : NEResultObserver<CommonResult<Void>> {
                override fun onResult(result: CommonResult<Void>?) {
                    if (result?.isSuccessful != true) {
                        getString(R.string.tip_switch_call_type_failed).toastShort(
                            this@P2PCallActivity
                        )
                        ALog.e(tag, "doSwitchCallType to $toCallType error, result is $result.")
                        return
                    }
                    if (switchCallState == SwitchCallState.INVITE) {
                        binding.switchTypeTipGroup.visibility = View.VISIBLE
                    }
                }
            }
        )
    }

    private fun doSwitchCanvas() {
        if (uiConfig?.enableCanvasSwitch == false) {
            return
        }

        val rtcUid = callEngine.callInfo.otherUserInfo().uid
        if (rtcUid == 0L) {
            ALog.e(tag, "doSwitchCanvas rtcUid is 0L with accId ${callParam.otherAccId}.")
            return
        }
        if (isLocalMuteVideo) {
            binding.videoViewBig.clearImage()
            binding.videoViewSmall.clearImage()
        }

        if (localIsSmallVideo) {
            NERtcEx.getInstance().setupRemoteVideoCanvas(binding.videoViewSmall, rtcUid)
            NERtcEx.getInstance().setupLocalVideoCanvas(binding.videoViewBig)
        } else {
            NERtcEx.getInstance().setupRemoteVideoCanvas(binding.videoViewBig, rtcUid)
            NERtcEx.getInstance().setupLocalVideoCanvas(binding.videoViewSmall)
        }
        localIsSmallVideo = !localIsSmallVideo

        uiRender.updateOnTheCallState(
            UserState(
                callParam.currentAccId,
                muteVideo = isLocalMuteVideo
            )
        )
        uiRender.updateOnTheCallState(
            UserState(
                callParam.otherAccId,
                muteVideo = isRemoteMuteVideo
            )
        )
    }

    private open inner class UIRender {
        open fun renderForCaller() {
            binding.tvSwitchTipClose.setOnClickListener {
                binding.switchTypeTipGroup.visibility = View.GONE
            }
            val enableAutoJoinWhenCalled = (callEngine as? NECallEngineImpl)?.recorder?.isEnableAutoJoinWhenCalled == true
            binding.calledSwitchGroup.visibility = View.GONE
            binding.callerSwitchGroup.visibility =
                if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE
        }

        open fun renderForCalled() {
            binding.tvSwitchTipClose.setOnClickListener {
                binding.switchTypeTipGroup.visibility = View.GONE
            }
            binding.callerSwitchGroup.visibility = View.GONE
            val enableAutoJoinWhenCalled = (callEngine as? NECallEngineImpl)?.recorder?.isEnableAutoJoinWhenCalled == true
            if (enableAutoJoinWhenCalled) {
                binding.calledSwitchGroup.visibility = View.VISIBLE
            } else {
                binding.calledSwitchGroup.visibility = View.GONE
            }
        }

        open fun renderForOnTheCall(userAccId: String? = null) {
            binding.tvSwitchTipClose.setOnClickListener {
                binding.switchTypeTipGroup.visibility = View.GONE
            }
            binding.callerSwitchGroup.visibility = View.GONE
            binding.calledSwitchGroup.visibility = View.GONE
            if (this is AudioRender) {
                binding.ivCallChannelTypeChange.visibility =
                    if (uiConfig?.showAudio2VideoSwitchOnTheCall == true) View.VISIBLE else View.GONE
            }
            if (this is VideoRender) {
                binding.ivCallChannelTypeChange.visibility =
                    if (uiConfig?.showVideo2AudioSwitchOnTheCall == true) View.VISIBLE else View.GONE
            }
            uiConfig?.overlayViewOnTheCall?.run {
                if (parent is ViewGroup) {
                    (parent as ViewGroup).removeView(this)
                }
                binding.clRoot.addView(
                    this,
                    ConstraintLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                )
            }
        }

        open fun updateOnTheCallState(state: UserState) {}
    }

    private inner class AudioRender : UIRender() {
        override fun renderForCaller() {
            super.renderForCaller()
            forUserInfoUI(NECallType.AUDIO, callParam.calledAccId, forVideoCaller = true)
            doConfigSpeakerSwitch(speakerEnable = false)

            if (isLocalMuteAudio) {
                doMuteAudioSwitch()
            }

            binding.ivBg.visibility = View.VISIBLE
            binding.tvCallSwitchTypeDesc.setText(R.string.tip_switch_to_video)

            binding.videoViewBig.visibility = View.GONE
            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE

            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.VISIBLE
            binding.callerAudioOperationGroup.visibility = View.VISIBLE

            binding.ivCancel.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setImageResource(R.drawable.icon_call_tip_audio_to_video)
            binding.ivCallChannelTypeChange.setOnClickListener(onClickListener)

            binding.ivCallMuteAudio.setOnClickListener(onClickListener)
            binding.ivCallSpeaker.setOnClickListener(onClickListener)
            binding.ivBg.visibility = View.VISIBLE
            if (startPreviewCode == 0 || startPreviewCode == ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED) {
                NERtcEx.getInstance().setupLocalVideoCanvas(null)
                startPreviewCode = if (NERtcEx.getInstance().stopVideoPreview() == 0) -1 else 0
            }
        }

        override fun renderForCalled() {
            super.renderForCalled()
            forUserInfoUI(NECallType.AUDIO, callParam.callerAccId)

            binding.ivAccept.setImageResource(R.drawable.icon_call_audio_accept)
            binding.ivSwitchType.setImageResource(R.drawable.icon_call_tip_audio_to_video)
            binding.tvOtherCallTip.setText(R.string.tip_invite_to_audio_call)
            binding.tvSwitchTypeDesc.setText(R.string.tip_switch_to_video)

            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewBig.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE

            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.VISIBLE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE

            binding.ivAccept.setOnClickListener(onClickListener)
            binding.ivReject.setOnClickListener(onClickListener)
            binding.ivSwitchType.setOnClickListener(onClickListener)
            binding.ivBg.visibility = View.VISIBLE
        }

        override fun renderForOnTheCall(userAccId: String?) {
            super.renderForOnTheCall(userAccId)

            callParam.run {
                forUserInfoUI(NECallType.AUDIO, otherAccId)
            }

            binding.tvOtherCallTip.setText(R.string.tip_on_the_call)
            binding.tvConnectingTip.visibility = View.GONE
            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE
            binding.videoViewBig.visibility = View.GONE
            binding.ivSmallVideoShade.visibility = View.GONE

            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.llOnTheCallOperation.visibility = View.VISIBLE
            binding.tvCountdown.visibility = View.VISIBLE

            binding.ivCallChannelTypeChange.setImageResource(R.drawable.audio_to_video)
            binding.ivCallChannelTypeChange.setOnClickListener(onClickListener)
            binding.ivMuteAudio.setOnClickListener(onClickListener)
            binding.ivMuteVideo.visibility = View.GONE
            binding.ivHangUp.setOnClickListener(onClickListener)
            binding.ivMuteSpeaker.setOnClickListener(onClickListener)

            binding.ivSwitchCamera.visibility = View.GONE

            binding.tvRemoteVideoCloseTip.visibility = View.GONE
            binding.ivSmallVideoShade.visibility = View.GONE
            if (!firstLaunch || callParam.isCalled) {
                resetSwitchState(NECallType.AUDIO)
            } else {
                firstLaunch = false
            }
            // sdk 版本变更后在加入通话前设置扬声器不生效，在对方接听后，自己加入rtc 后进行扬声器设置补充；
            if (!callParam.isCalled) {
                doConfigSpeakerSwitch(speakerEnable = isSpeakerOn())
            }
            binding.ivBg.visibility = View.VISIBLE
        }
    }

    private var firstLaunch = true

    private inner class VideoRender : UIRender() {
        override fun renderForCaller() {
            super.renderForCaller()
            forUserInfoUI(NECallType.VIDEO, callParam.calledAccId, forVideoCaller = true)
            doConfigSpeakerSwitch(speakerEnable = true)

            binding.videoViewBig.visibility = View.GONE
            binding.videoViewPreview.visibility = View.VISIBLE
            binding.videoViewSmall.visibility = View.GONE

            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.VISIBLE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.ivCancel.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setOnClickListener(onClickListener)
            binding.ivCallSwitchType.setImageResource(R.drawable.icon_call_tip_video_to_audio)
            binding.tvCallSwitchTypeDesc.setText(R.string.tip_switch_to_audio)

            setupLocalView(binding.videoViewPreview)
            if (startPreviewCode != NERtcConstants.ErrorCode.OK &&
                startPreviewCode != ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED
            ) {
                startPreviewCode = NERtcEx.getInstance().startVideoPreview().apply {
                    ALog.d(tag, "renderForCaller startPreviewCode is $this.")
                }
            }
            binding.ivBg.visibility = View.GONE
        }

        override fun renderForCalled() {
            super.renderForCalled()

            forUserInfoUI(NECallType.VIDEO, callParam.callerAccId)

            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewBig.visibility = View.GONE
            binding.videoViewSmall.visibility = View.GONE

            binding.llOnTheCallOperation.visibility = View.GONE
            binding.calledOperationGroup.visibility = View.VISIBLE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.tvOtherCallTip.setText(R.string.tip_invite_to_video_call)
            binding.tvSwitchTypeDesc.setText(R.string.tip_switch_to_audio)

            binding.ivAccept.setImageResource(R.drawable.call_accept)
            binding.ivSwitchType.setImageResource(R.drawable.icon_call_tip_video_to_audio)

            binding.ivAccept.setOnClickListener(onClickListener)
            binding.ivReject.setOnClickListener(onClickListener)
            binding.ivSwitchType.setOnClickListener(onClickListener)

            binding.ivBg.visibility = View.VISIBLE
        }

        override fun renderForOnTheCall(userAccId: String?) {
            super.renderForOnTheCall(userAccId)

            forUserInfoUI(type = NECallType.VIDEO, visible = false)

            binding.tvConnectingTip.visibility = View.GONE
            binding.videoViewPreview.visibility = View.GONE
            binding.videoViewSmall.visibility = View.VISIBLE
            binding.videoViewBig.visibility = View.VISIBLE
            binding.ivSmallVideoShade.visibility = View.GONE

            binding.calledOperationGroup.visibility = View.GONE
            binding.callerOperationGroup.visibility = View.GONE
            binding.callerAudioOperationGroup.visibility = View.GONE
            binding.llOnTheCallOperation.visibility = View.VISIBLE
            binding.tvCountdown.visibility = View.VISIBLE

            binding.videoViewSmall.setOnClickListener(onClickListener)
            binding.ivCallChannelTypeChange.setOnClickListener(onClickListener)
            binding.ivCallChannelTypeChange.setImageResource(R.drawable.video_to_audio)
            binding.ivMuteAudio.setOnClickListener(onClickListener)
            binding.ivMuteVideo.visibility = View.VISIBLE
            binding.ivMuteVideo.setOnClickListener(onClickListener)
            binding.ivHangUp.setOnClickListener(onClickListener)
            binding.ivMuteSpeaker.setOnClickListener(onClickListener)
            resetSwitchState(NECallType.VIDEO)
            binding.ivBg.visibility = View.GONE

            firstLaunch = false
            binding.ivSwitchCamera.run {
                visibility = View.VISIBLE
                setOnClickListener(onClickListener)
            }
            if (callParam.currentUserIsCaller()) {
                NERtcEx.getInstance().setupLocalVideoCanvas(null)
                NERtcEx.getInstance().stopVideoPreview()
            }
            setupRemoteView(binding.videoViewBig)
            binding.videoViewPreview.release()
            setupLocalView(binding.videoViewSmall)
        }

        override fun updateOnTheCallState(state: UserState) {
            super.updateOnTheCallState(state)
            if (localIsSmallVideo) {
                if (TextUtils.equals(state.userAccId, callParam.currentAccId)) {
                    state.muteVideo?.run {
                        loadImg(uiConfig?.closeVideoLocalUrl, binding.ivSmallVideoShade)
                        binding.ivSmallVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                    }
                } else {
                    state.muteVideo?.run {
                        loadImg(uiConfig?.closeVideoRemoteUrl, binding.ivBigVideoShade)
                        binding.ivBigVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                        binding.tvRemoteVideoCloseTip.text =
                            if (TextUtils.isEmpty(uiConfig?.closeVideoRemoteTip?.trim())) {
                                getString(
                                    R.string.ui_tip_close_camera_by_other
                                )
                            } else {
                                uiConfig?.closeVideoRemoteTip
                            }
                        binding.tvRemoteVideoCloseTip.visibility = if (this) View.VISIBLE else View.GONE
                    }
                }
            } else {
                if (TextUtils.equals(state.userAccId, callParam.currentAccId)) {
                    state.muteVideo?.run {
                        loadImg(uiConfig?.closeVideoLocalUrl, binding.ivBigVideoShade)
                        binding.ivBigVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                        binding.tvRemoteVideoCloseTip.text = if (TextUtils.isEmpty(
                                uiConfig?.closeVideoLocalTip?.trim()
                            )
                        ) {
                            getString(
                                R.string.ui_tip_close_camera_by_self
                            )
                        } else {
                            uiConfig?.closeVideoLocalTip
                        }
                        binding.tvRemoteVideoCloseTip.visibility = if (this) View.VISIBLE else View.GONE
                    }
                } else {
                    state.muteVideo?.run {
                        loadImg(uiConfig?.closeVideoRemoteUrl, binding.ivSmallVideoShade)
                        binding.ivSmallVideoShade.visibility = if (this) View.VISIBLE else View.GONE
                    }
                }
            }
        }
    }

    private fun forUserInfoUI(
        type: Int,
        accId: String? = null,
        visible: Boolean = true,
        forVideoCaller: Boolean = false
    ) {
        if (!visible) {
            binding.userInfoGroup.visibility = View.GONE
            return
        }
        binding.userInfoGroup.visibility = View.VISIBLE

        accId?.run {
            fetchNickname {
                binding.tvUserName.text = it
            }
            loadAvatarByAccId(
                this@P2PCallActivity,
                binding.ivUserInnerAvatar,
                binding.ivBg,
                binding.tvUserInnerAvatar,
                uiConfig?.enableTextDefaultAvatar ?: true
            )
        }
        val centerSize = 97.dip2Px(this)
        val topSize = 60.dip2Px(this)

        val constraintSet = ConstraintSet()
        constraintSet.clone(binding.clRoot)
        constraintSet.clear(R.id.flUserAvatar)
        constraintSet.clear(R.id.tvOtherCallTip)
        constraintSet.clear(R.id.tvUserName)
        constraintSet.constrainHeight(R.id.tvOtherCallTip, ConstraintSet.WRAP_CONTENT)
        constraintSet.constrainWidth(R.id.tvOtherCallTip, ConstraintSet.WRAP_CONTENT)
        constraintSet.constrainWidth(R.id.tvUserName, ConstraintSet.WRAP_CONTENT)
        constraintSet.constrainWidth(R.id.tvUserName, ConstraintSet.WRAP_CONTENT)

        if (type == NECallType.VIDEO && forVideoCaller) {
            val marginSize16 = 16.dip2Px(this)
            binding.flUserAvatar.run {
                constraintSet.constrainWidth(id, topSize)
                constraintSet.constrainHeight(id, topSize)
                constraintSet.connect(
                    id,
                    ConstraintSet.END,
                    ConstraintSet.PARENT_ID,
                    ConstraintSet.END,
                    marginSize16
                )
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    ConstraintSet.PARENT_ID,
                    ConstraintSet.TOP,
                    marginSize16
                )
            }
            val marginSize10 = 10.dip2Px(this)
            val marginSize5 = 5.dip2Px(this)
            binding.tvUserName.run {
                textSize = 18f
                constraintSet.connect(
                    id,
                    ConstraintSet.END,
                    binding.flUserAvatar.id,
                    ConstraintSet.START,
                    marginSize10
                )
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.flUserAvatar.id,
                    ConstraintSet.TOP,
                    marginSize5
                )
            }
            binding.tvOtherCallTip.run {
                setTextColor(ContextCompat.getColor(context, R.color.white))
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.tvUserName.id,
                    ConstraintSet.BOTTOM,
                    marginSize5
                )
                constraintSet.connect(
                    id,
                    ConstraintSet.END,
                    binding.flUserAvatar.id,
                    ConstraintSet.START,
                    marginSize10
                )
            }
        } else {
            binding.flUserAvatar.run {
                constraintSet.constrainWidth(id, centerSize)
                constraintSet.constrainHeight(id, centerSize)
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    ConstraintSet.PARENT_ID,
                    ConstraintSet.TOP,
                    160.dip2Px(context)
                )
                constraintSet.centerHorizontally(id, ConstraintSet.PARENT_ID)
            }
            binding.tvUserName.run {
                textSize = 20f
                constraintSet.centerHorizontally(id, ConstraintSet.PARENT_ID)
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.flUserAvatar.id,
                    ConstraintSet.BOTTOM,
                    15.dip2Px(context)
                )
            }
            binding.tvOtherCallTip.run {
                setTextColor(ContextCompat.getColor(context, R.color.color_cccccc))
                constraintSet.connect(
                    id,
                    ConstraintSet.TOP,
                    binding.tvUserName.id,
                    ConstraintSet.BOTTOM,
                    8.dip2Px(context)
                )
                constraintSet.centerHorizontally(id, ConstraintSet.PARENT_ID)
            }
        }
        constraintSet.applyTo(binding.clRoot)
    }

    private fun resetSwitchState(callType: Int) {
        if (callType == NECallType.VIDEO) {
            doConfigSpeaker(true)
            binding.ivMuteSpeaker.setImageResource(R.drawable.speaker_on)
        } else {
            doConfigSpeaker(false)
            binding.ivMuteSpeaker.setImageResource(R.drawable.speaker_off)
        }
        // 视频
        localIsSmallVideo = true

        doMuteAudio(false)
        binding.ivMuteVideo.setImageResource(R.drawable.cam_on)
        binding.tvRemoteVideoCloseTip.visibility = View.GONE
        binding.videoViewSmall.setBackgroundColor(Color.TRANSPARENT)
        // 音频
        if (isLocalMuteAudio) {
            doMuteAudioSwitch(binding.ivMuteAudio)
        }
    }

    private fun loadImg(url: String?, imageView: ImageView) {
        Glide.with(applicationContext).load(url)
            .error(R.color.black)
            .placeholder(R.color.black)
            .centerCrop()
            .into(imageView)
    }

    class UserState(
        val userAccId: String?,
        val muteVideo: Boolean? = null
    )
}
