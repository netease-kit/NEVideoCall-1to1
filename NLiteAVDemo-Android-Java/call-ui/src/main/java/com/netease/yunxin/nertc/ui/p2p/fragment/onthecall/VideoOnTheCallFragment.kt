/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment.onthecall

import android.graphics.Color
import android.os.Bundle
import android.text.TextUtils
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
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
import com.netease.yunxin.nertc.ui.utils.ClickUtils
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

    protected val switchObserver = object : NEResultObserver<CommonResult<Void>> {
        override fun onResult(result: CommonResult<Void>?) {
            if (result?.isSuccessful != true) {
                context?.run {
                    getString(R.string.tip_switch_call_type_failed).toastShort(this)
                }
                ALog.e(
                    logTag,
                    "doSwitchCallType to ${NECallType.AUDIO} error, result is $result."
                )
                return
            }
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.VISIBLE
            }
        }
    }

    protected lateinit var binding: FragmentP2pVideoOnTheCallBinding

    protected var localIsSmallVideo = true

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
        getView<View>(viewKeyImageCancel)?.setOnClickListener {
            bridge.doHangup()
        }
        getView<View>(viewKeySwitchTypeTipGroup)?.run {
            visibility = View.GONE
        }
        getView<View>(viewKeyImageSwitchType)?.run {
            visibility =
                if (uiConfig?.showVideo2AudioSwitchOnTheCall == true) View.VISIBLE else View.GONE
            setOnClickListener {
                if (ClickUtils.isFastClick()) {
                    return@setOnClickListener
                }
                if (!NetworkUtils.isConnected()) {
                    context?.run { getString(R.string.tip_network_error).toastShort(this) }
                    return@setOnClickListener
                }
                bridge.doSwitchCallType(NECallType.AUDIO, SwitchCallState.INVITE, switchObserver)
            }
        }
        getView<ImageView>(viewKeyMuteImageAudio)?.run {
            setOnClickListener {
                bridge.doMuteAudio()
                setImageResource(
                    if (bridge.isLocalMuteAudio) R.drawable.voice_off else R.drawable.voice_on
                )
            }
        }
        getView<View>(viewKeyImageVideoShadeSmall)?.run {
            setBackgroundColor(Color.BLACK)
        }
        getView<ImageView>(viewKeyMuteImageVideo)?.run {
            setOnClickListener {
                bridge.doMuteVideo()
                setImageResource(
                    if (bridge.isLocalMuteVideo) R.drawable.cam_off else R.drawable.cam_on
                )
                updateCloseVideoTipUI(bridge.callParam.currentAccId, bridge.isLocalMuteVideo)
            }
        }
        getView<ImageView>(viewKeyImageSpeaker)?.run {
            setOnClickListener {
                val speakerEnable = !bridge.isSpeakerOn()
                bridge.doConfigSpeaker(speakerEnable)
                setImageResource(
                    if (bridge.isSpeakerOn()) R.drawable.speaker_on else R.drawable.speaker_off
                )
            }
        }
        getView<ImageView>(viewKeyImageHangup)?.run {
            setOnClickListener {
                bridge.doHangup()
            }
        }
        getView<ImageView>(viewKeyImageSwitchCamera)?.run {
            setOnClickListener {
                bridge.doSwitchCamera()
            }
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
        getView<NERtcVideoView>(viewKeyVideoViewBig)?.run {
            bridge.setupRemoteView(this)
        }
        getView<NERtcVideoView>(viewKeyVideoViewSmall)?.run {
            bridge.setupLocalView(this)
            if (uiConfig?.enableCanvasSwitch == true) {
                setOnClickListener {
                    doSwitchCanvas()
                }
            }
        }
        getView<View>(viewKeyImageSwitchTipClose)?.run {
            setOnClickListener {
                getView<View>(viewKeySwitchTypeTipGroup)?.run {
                    visibility = View.GONE
                }
            }
        }
    }

    override fun onCreateAction() {
        if (bridge.currentCallState() == CallState.STATE_IDLE) {
            bridge.doCall()
        }
    }

    override fun onCallEnd(info: NECallEndInfo) {
        bridge.configTimeTick(null)
    }

    override fun toUpdateUIState(type: Int) {
        bridge.doConfigSpeaker(true)
        bridge.doMuteAudio(false)
        bridge.doMuteVideo(false)
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (info.state == SwitchCallState.REJECT) {
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.GONE
            }
        }
    }

    override fun onVideoMuted(userId: String?, mute: Boolean) {
        userId ?: return
        updateCloseVideoTipUI(userId, mute)
    }

    protected open fun doSwitchCanvas() {
        val videoViewSmall = getView<NERtcVideoView>(viewKeyVideoViewSmall)
        val videoViewBig = getView<NERtcVideoView>(viewKeyVideoViewBig)
        if (bridge.isLocalMuteVideo) {
            videoViewBig?.clearImage()
            videoViewSmall?.clearImage()
        }
        if (localIsSmallVideo) {
            bridge.setupRemoteView(videoViewSmall)
            bridge.setupLocalView(videoViewBig)
        } else {
            bridge.setupRemoteView(videoViewBig)
            bridge.setupLocalView(videoViewSmall)
        }
        localIsSmallVideo = !localIsSmallVideo

        updateCloseVideoTipUI(bridge.callParam.currentAccId, muteVideo = bridge.isLocalMuteVideo)
        updateCloseVideoTipUI(bridge.callParam.otherAccId, muteVideo = bridge.isRemoteMuteVideo)
    }

    protected open fun updateCloseVideoTipUI(userAccId: String?, muteVideo: Boolean?) {
        val ivSmallVideoShade = getView<ImageView>(viewKeyImageVideoShadeSmall)
        val ivBigVideoShade = getView<ImageView>(viewKeyImageVideoShadeBig)
        val tvRemoteVideoCloseTip = getView<TextView>(viewKeyTextRemoteVideoCloseTip)

        if (localIsSmallVideo) {
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
}
