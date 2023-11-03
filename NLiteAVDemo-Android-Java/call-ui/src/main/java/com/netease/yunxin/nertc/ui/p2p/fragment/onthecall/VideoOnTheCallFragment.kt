/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment.onthecall

import android.Manifest.permission.CAMERA
import android.Manifest.permission.RECORD_AUDIO
import android.graphics.Color
import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import com.bumptech.glide.Glide
import com.netease.lava.api.IVideoRender
import com.netease.lava.nertc.sdk.NERtcConstants
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.FragmentP2pVideoOnTheCallBinding
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.CHANGE_CALL_TYPE
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.FROM_FLOATING_WINDOW
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.INIT
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
import com.netease.yunxin.nertc.ui.utils.toastShort
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * 视频通话页面
 */
open class VideoOnTheCallFragment : BaseP2pCallFragment() {

    protected val logTag = "VideoOnTheCallFragment"

    protected lateinit var binding: FragmentP2pVideoOnTheCallBinding

    protected open val rtcCallback = object : NERtcCallbackExTemp() {
        override fun onVirtualBackgroundSourceEnabled(enabled: Boolean, reason: Int) {
            var tipRes: Int? = null
            when (reason) {
                NERtcConstants.NERtcVirtualBackgroundSourceStateReason.VBS_STATE_REASON_SUCCESS -> {
                    tipRes = R.string.ui_tip_virtual_blur_success
                }

                NERtcConstants.NERtcVirtualBackgroundSourceStateReason.VBS_STATE_REASON_DEVICE_NOT_SUPPORTED -> {
                    tipRes = R.string.ui_tip_virtual_blur_device_not_supported
                    getView<ImageView>(viewKeyImageVirtualBlur)?.run {
                        setImageResource(R.drawable.icon_call_virtual_blur_off)
                    }
                    CallUIOperationsMgr.updateUIState(isVirtualBlur = false)
                }
            }

            tipRes ?: return
            context?.run {
                Toast.makeText(this, tipRes, Toast.LENGTH_SHORT).show()
            }
        }
    }

    private var permissionAllowed = false

    override fun toCreateRootView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View = FragmentP2pVideoOnTheCallBinding.inflate(inflater, container, false).run {
        binding = this
        this.root
    }

    override fun toBindView() {
        bindView(viewKeyVideoViewBig, binding.videoViewBig)
        bindView(viewKeyVideoViewSmall, binding.videoViewSmall)
        bindView(viewKeyImageVideoShadeSmall, binding.ivSmallVideoShade)
        bindView(viewKeyImageVideoShadeBig, binding.ivBigVideoShade)

        bindView(viewKeyMuteImageAudio, binding.ivMuteAudio)
        bindView(viewKeyMuteImageVideo, binding.ivMuteVideo)
        bindView(viewKeyImageSpeaker, binding.ivMuteSpeaker)
        bindView(viewKeyImageSwitchType, binding.ivCallChannelTypeChange)
        bindView(viewKeyImageHangup, binding.ivHangUp)
        bindView(viewKeyImageSwitchCamera, binding.ivSwitchCamera)

        bindView(viewKeyTextTimeCountdown, binding.tvCountdown)
        bindView(viewKeyTextRemoteVideoCloseTip, binding.tvRemoteVideoCloseTip)

        bindView(viewKeyTextSwitchTip, binding.tvSwitchTip)
        bindView(viewKeyImageSwitchTipClose, binding.ivSwitchTipClose)
        bindView(viewKeySwitchTypeTipGroup, binding.switchTypeTipGroup)
        bindView(viewKeyImageFloatingWindow, binding.ivFloatingWindow)
        bindView(viewKeyImageVirtualBlur, binding.ivVirtualBlur)
    }

    override fun toRenderView(callParam: CallParam, uiConfig: P2PUIConfig?) {
        renderUserInfo(callParam.otherAccId, uiConfig)
        renderOperations(uiConfig)
    }

    protected open fun renderUserInfo(userAccId: String?, uiConfig: P2PUIConfig?) {
        userAccId?.run {
            fetchNickname {
                getView<TextView>(viewKeyTextUserName)?.run {
                    text = it
                }
            }
            loadAvatarByAccId(
                requireContext(),
                getView<ImageView>(viewKeyImageUserInnerAvatar),
                null,
                getView<TextView>(viewKeyTextUserInnerAvatar),
                uiConfig?.enableTextDefaultAvatar ?: true
            )
        }
    }

    protected open fun renderOperations(uiConfig: P2PUIConfig?) {
        getView<View>(viewKeyImageSwitchType)?.run {
            visibility =
                if (uiConfig?.showVideo2AudioSwitchOnTheCall == true) View.VISIBLE else View.GONE
            bindClick(viewKeyImageSwitchType) {
                if (!NetworkUtils.isConnected()) {
                    context?.run { getString(R.string.tip_network_error).toastShort(this) }
                    return@bindClick
                }
                switchCallType(NECallType.AUDIO)
            }
        }
        getView<ImageView>(viewKeyMuteImageAudio)?.run {
            bindClick(viewKeyMuteImageAudio) {
                bridge.doMuteAudio()
                setImageResource(
                    if (bridge.isLocalMuteAudio) R.drawable.voice_off else R.drawable.voice_on
                )
            }
        }
        getView<ImageView>(viewKeyMuteImageVideo)?.run {
            bindClick(viewKeyMuteImageVideo) {
                bridge.doMuteVideo()
                setImageResource(
                    if (bridge.isLocalMuteVideo) R.drawable.cam_off else R.drawable.cam_on
                )
                updateCloseVideoTipUI(bridge.callParam.currentAccId, bridge.isLocalMuteVideo)
            }
        }
        getView<ImageView>(viewKeyImageSpeaker)?.run {
            bindClick(viewKeyImageSpeaker) {
                val speakerEnable = !bridge.isSpeakerOn()
                bridge.doConfigSpeaker(speakerEnable)
                setImageResource(
                    if (bridge.isSpeakerOn()) R.drawable.speaker_on else R.drawable.speaker_off
                )
            }
        }
        getView<ImageView>(viewKeyImageHangup)?.run {
            bindClick(viewKeyImageHangup) {
                bridge.doHangup()
            }
        }
        getView<ImageView>(viewKeyImageSwitchCamera)?.run {
            bindClick(viewKeyImageSwitchCamera) {
                bridge.doSwitchCamera()
            }
        }
        getView<NERtcVideoView>(viewKeyVideoViewSmall)?.run {
            if (uiConfig?.enableCanvasSwitch == true) {
                bindClick(viewKeyVideoViewSmall) {
                    doSwitchCanvas()
                }
            }
        }
        getView<View>(viewKeyImageSwitchTipClose)?.run {
            bindClick(viewKeyImageSwitchTipClose) {
                getView<View>(viewKeySwitchTypeTipGroup)?.run {
                    visibility = View.GONE
                }
            }
        }
        getView<View>(viewKeyImageFloatingWindow)?.run {
            visibility = if (uiConfig?.enableFloatingWindow == true) View.VISIBLE else View.GONE
            bindClick(viewKeyImageFloatingWindow) {
                bridge.showFloatingWindow()
            }
        }
        getView<ImageView>(viewKeyImageVirtualBlur)?.run {
            visibility = if (uiConfig?.enableVirtualBlur == true) View.VISIBLE else View.GONE
            bindClick(viewKeyImageVirtualBlur) {
                bridge.doVirtualBlur()
                setImageResource(
                    if (bridge.isVirtualBlur) R.drawable.icon_call_virtual_blur_on else R.drawable.icon_call_virtual_blur_off
                )
            }
        }
    }

    override fun permissionList(): List<String> {
        return listOf(RECORD_AUDIO, CAMERA)
    }

    override fun actionForPermissionGranted() {
        if (!permissionAllowed) {
            bridge.callEngine.enableLocalVideo(true)
        }
    }

    override fun onPermissionRequest() {
        permissionAllowed = arePermissionsGranted()
        super.onPermissionRequest()
    }

    override fun onCreateAction() {
        NERtcCallbackProxyMgr.getInstance().addCallback(rtcCallback)
        if (bridge.currentCallState() == CallState.STATE_IDLE) {
            bridge.doCall()
        }
    }

    override fun onDestroyAction() {
        super.onDestroyAction()
        NERtcCallbackProxyMgr.getInstance().removeCallback(rtcCallback)
    }

    override fun onCallEnd(info: NECallEndInfo) {
        bridge.configTimeTick(null)
    }

    override fun toUpdateUIState(type: Int) {
        when (type) {
            INIT, CHANGE_CALL_TYPE -> toInitState()
            FROM_FLOATING_WINDOW -> {
                toFromFloatingWindowState()
            }
        }
    }

    override fun onVideoMuted(userId: String?, mute: Boolean) {
        userId ?: return
        updateCloseVideoTipUI(userId, mute)
    }

    override fun onVideoAvailable(userId: String?, available: Boolean) {
        userId ?: return
        updateCloseVideoTipUI(userId, !available)
    }

    protected open fun doSwitchCanvas() {
        val videoViewSmall = getView<NERtcVideoView>(viewKeyVideoViewSmall)
        val videoViewBig = getView<NERtcVideoView>(viewKeyVideoViewBig)
        if (bridge.isLocalMuteVideo) {
            videoViewBig?.clearImage()
            videoViewSmall?.clearImage()
        }
        if (bridge.isLocalSmallVideo) {
            bridge.setupRemoteView(videoViewSmall, action = {
                it?.run {
                    setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
                }
            })
            bridge.setupLocalView(videoViewBig, action = {
                it?.run {
                    setZOrderMediaOverlay(true)
                    setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
                }
            })
        } else {
            bridge.setupRemoteView(videoViewBig)
            bridge.setupLocalView(videoViewSmall)
        }
        CallUIOperationsMgr.updateUIState(isLocalSmallVideo = !bridge.isLocalSmallVideo)

        updateCloseVideoTipUI(bridge.callParam.currentAccId, muteVideo = bridge.isLocalMuteVideo)
        updateCloseVideoTipUI(bridge.callParam.otherAccId, muteVideo = bridge.isRemoteMuteVideo)
    }

    protected open fun updateCloseVideoTipUI(userAccId: String?, muteVideo: Boolean?) {
        val ivSmallVideoShade = getView<ImageView>(viewKeyImageVideoShadeSmall)
        val ivBigVideoShade = getView<ImageView>(viewKeyImageVideoShadeBig)
        val tvRemoteVideoCloseTip = getView<TextView>(viewKeyTextRemoteVideoCloseTip)

        if (bridge.isLocalSmallVideo) {
            if (TextUtils.equals(userAccId, bridge.callParam.currentAccId)) {
                muteVideo?.run {
                    loadImg(bridge.uiConfig?.closeVideoLocalUrl, ivSmallVideoShade)
                    ivSmallVideoShade?.visibility = if (this) View.VISIBLE else View.GONE
                }
            } else {
                muteVideo?.run {
                    loadImg(bridge.uiConfig?.closeVideoRemoteUrl, ivBigVideoShade)
                    ivBigVideoShade?.visibility = if (this) View.VISIBLE else View.GONE
                    tvRemoteVideoCloseTip?.text =
                        if (TextUtils.isEmpty(bridge.uiConfig?.closeVideoRemoteTip?.trim())) {
                            getString(
                                R.string.ui_tip_close_camera_by_other
                            )
                        } else {
                            bridge.uiConfig?.closeVideoRemoteTip
                        }
                    tvRemoteVideoCloseTip?.visibility = if (this) View.VISIBLE else View.GONE
                }
            }
        } else {
            if (TextUtils.equals(userAccId, bridge.callParam.currentAccId)) {
                muteVideo?.run {
                    loadImg(bridge.uiConfig?.closeVideoLocalUrl, ivBigVideoShade)
                    ivBigVideoShade?.visibility = if (this) View.VISIBLE else View.GONE
                    tvRemoteVideoCloseTip?.text = if (TextUtils.isEmpty(
                            bridge.uiConfig?.closeVideoLocalTip?.trim()
                        )
                    ) {
                        getString(
                            R.string.ui_tip_close_camera_by_self
                        )
                    } else {
                        bridge.uiConfig?.closeVideoLocalTip
                    }
                    tvRemoteVideoCloseTip?.visibility = if (this) View.VISIBLE else View.GONE
                }
            } else {
                muteVideo?.run {
                    loadImg(bridge.uiConfig?.closeVideoRemoteUrl, ivSmallVideoShade)
                    ivSmallVideoShade?.visibility = if (this) View.VISIBLE else View.GONE
                }
            }
        }
    }

    protected open fun loadImg(url: String?, imageView: ImageView?) {
        imageView ?: run {
            ALog.e(logTag, "loadImg", "imageView is null.")
            return
        }
        val currentContext = context?.applicationContext ?: run {
            ALog.e(logTag, "loadImg", "context is null.")
            return
        }
        Glide.with(currentContext).load(url)
            .error(R.color.black)
            .placeholder(R.color.black)
            .centerCrop()
            .into(imageView)
    }

    protected open fun toInitState() {
        getView<View>(viewKeySwitchTypeTipGroup)?.run {
            visibility = View.GONE
        }
        getView<View>(viewKeyImageVideoShadeSmall)?.run {
            setBackgroundColor(Color.BLACK)
        }
        getView<TextView>(viewKeyTextTimeCountdown)?.run {
            bridge.configTimeTick(
                CallUIOperationsMgr.TimeTickConfig({
                    CoroutineScope(Dispatchers.Main).launch {
                        this@run.text = it.formatSecondTime()
                    }
                })
            )
        }
        bridge.doVirtualBlur(false)
        getView<ImageView>(viewKeyImageVirtualBlur)?.run {
            setImageResource(
                if (bridge.isVirtualBlur) R.drawable.icon_call_virtual_blur_on else R.drawable.icon_call_virtual_blur_off
            )
        }
        bridge.doConfigSpeaker(true)
        getView<ImageView>(viewKeyImageSpeaker)?.run {
            setImageResource(
                if (bridge.isSpeakerOn()) R.drawable.speaker_on else R.drawable.speaker_off
            )
        }
        bridge.doMuteAudio(false)
        getView<ImageView>(viewKeyMuteImageAudio)?.run {
            setImageResource(
                if (bridge.isLocalMuteAudio) R.drawable.voice_off else R.drawable.voice_on
            )
        }
        bridge.doMuteVideo(false)
        getView<ImageView>(viewKeyMuteImageVideo)?.run {
            setImageResource(
                if (bridge.isLocalMuteVideo) R.drawable.cam_off else R.drawable.cam_on
            )
            updateCloseVideoTipUI(bridge.callParam.currentAccId, bridge.isLocalMuteVideo)
        }
        updateCloseVideoTipUI(bridge.callParam.otherAccId, muteVideo = false)

        getView<NERtcVideoView>(viewKeyVideoViewBig)?.run {
            bridge.setupRemoteView(this)
        }
        getView<NERtcVideoView>(viewKeyVideoViewSmall)?.run {
            bridge.setupLocalView(this)
        }
    }

    protected open fun toFromFloatingWindowState() {
        getView<TextView>(viewKeyTextTimeCountdown)?.run {
            bridge.configTimeTick(
                CallUIOperationsMgr.TimeTickConfig({
                    CoroutineScope(Dispatchers.Main).launch {
                        this@run.text = it.formatSecondTime()
                    }
                })
            )
        }
        getView<ImageView>(viewKeyImageVirtualBlur)?.run {
            setImageResource(
                if (bridge.isVirtualBlur) R.drawable.icon_call_virtual_blur_on else R.drawable.icon_call_virtual_blur_off
            )
        }
        getView<ImageView>(viewKeyImageSpeaker)?.run {
            setImageResource(
                if (bridge.isSpeakerOn()) R.drawable.speaker_on else R.drawable.speaker_off
            )
        }
        getView<ImageView>(viewKeyMuteImageAudio)?.run {
            setImageResource(
                if (bridge.isLocalMuteAudio) R.drawable.voice_off else R.drawable.voice_on
            )
        }
        getView<ImageView>(viewKeyMuteImageVideo)?.run {
            setImageResource(
                if (bridge.isLocalMuteVideo) R.drawable.cam_off else R.drawable.cam_on
            )
        }
        if (bridge.isLocalSmallVideo) {
            getView<NERtcVideoView>(viewKeyVideoViewBig)?.run {
                bridge.setupRemoteView(this)
            }
            getView<NERtcVideoView>(viewKeyVideoViewSmall)?.run {
                bridge.setupLocalView(this)
            }
        } else {
            getView<NERtcVideoView>(viewKeyVideoViewBig)?.run {
                bridge.setupLocalView(this, action = {
                    it?.run {
                        setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
                    }
                })
            }
            getView<NERtcVideoView>(viewKeyVideoViewSmall)?.run {
                bridge.setupRemoteView(this, action = {
                    it?.run {
                        setZOrderMediaOverlay(true)
                        setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
                    }
                })
            }
        }
        updateCloseVideoTipUI(bridge.callParam.currentAccId, muteVideo = bridge.isLocalMuteVideo)
        updateCloseVideoTipUI(bridge.callParam.otherAccId, muteVideo = bridge.isRemoteMuteVideo)
    }
}
