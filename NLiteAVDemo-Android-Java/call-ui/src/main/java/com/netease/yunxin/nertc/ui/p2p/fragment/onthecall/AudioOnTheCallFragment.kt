/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment.onthecall

import android.Manifest
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState.REJECT
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.FragmentP2pAudioOnTheCallBinding
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.CHANGE_CALL_TYPE
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.INIT
import com.netease.yunxin.nertc.ui.utils.ClickUtils
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.requestPermission
import com.netease.yunxin.nertc.ui.utils.toastShort
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * 音频通话页面
 */
open class AudioOnTheCallFragment : BaseP2pCallFragment() {

    protected val logTag = "AudioOnTheCallFragment"

    protected lateinit var binding: FragmentP2pAudioOnTheCallBinding

    protected val switchObserver = object : NEResultObserver<CommonResult<Void>> {
        override fun onResult(result: CommonResult<Void>?) {
            if (result?.isSuccessful != true) {
                context?.run {
                    getString(R.string.tip_switch_call_type_failed).toastShort(this)
                }
                ALog.e(
                    logTag,
                    "doSwitchCallType to ${NECallType.VIDEO} error, result is $result."
                )
                return
            }
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.VISIBLE
            }
        }
    }

    override fun toCreateRootView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View = FragmentP2pAudioOnTheCallBinding.inflate(inflater, container, false).run {
        binding = this
        this.root
    }

    override fun toBindView() {
        bindView(viewKeyImageBigBackground, binding.ivBg)

        bindView(viewKeyTextUserInnerAvatar, binding.tvUserInnerAvatar)
        bindView(viewKeyImageUserInnerAvatar, binding.ivUserInnerAvatar)
        bindView(viewKeyFrameLayoutUserAvatar, binding.flUserAvatar)
        bindView(viewKeyTextUserName, binding.tvUserName)
        bindView(viewKeyTextOtherCallTip, binding.tvOtherCallTip)

        bindView(viewKeyMuteImageAudio, binding.ivMuteAudio)
        bindView(viewKeyImageSpeaker, binding.ivMuteSpeaker)
        bindView(viewKeyImageSwitchType, binding.ivCallChannelTypeChange)
        bindView(viewKeyImageHangup, binding.ivHangUp)

        bindView(viewKeyTextTimeCountdown, binding.tvCountdown)

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
                getView<ImageView>(viewKeyImageBigBackground),
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
                if (uiConfig?.showAudio2VideoSwitchOnTheCall == true) View.VISIBLE else View.GONE
            setOnClickListener {
                if (ClickUtils.isFastClick()) {
                    return@setOnClickListener
                }
                val action = Action@{
                    if (!NetworkUtils.isConnected()) {
                        context?.run {
                            getString(R.string.tip_network_error).toastShort(this)
                        }
                        return@Action
                    }
                    bridge.doSwitchCallType(
                        NECallType.VIDEO,
                        SwitchCallState.INVITE,
                        switchObserver
                    )
                }
                if (context?.isGranted(Manifest.permission.CAMERA) == true) {
                    action.invoke()
                    return@setOnClickListener
                }
                requestPermission(
                    onGranted = {
                        action.invoke()
                    },
                    onDenied = { _, _ ->
                        context?.run {
                            getString(R.string.tip_permission_request_failed).toastShort(this)
                        }
                    },
                    Manifest.permission.CAMERA
                )
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

        getView<TextView>(viewKeyTextTimeCountdown)?.run {
            bridge.configTimeTick(
                CallUIOperationsMgr.TimeTickConfig({
                    CoroutineScope(Dispatchers.Main).launch {
                        this@run.text = it.formatSecondTime()
                    }
                })
            )
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
        when (type) {
            INIT -> {
                bridge.doConfigSpeaker(!bridge.isLocalMuteSpeaker)
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
            }

            CHANGE_CALL_TYPE -> {
                bridge.doConfigSpeaker(false)
                getView<ImageView>(viewKeyImageSpeaker)?.run {
                    setImageResource(R.drawable.speaker_off)
                }
                bridge.doMuteAudio(false)
                getView<ImageView>(viewKeyMuteImageAudio)?.run {
                    setImageResource(R.drawable.voice_on)
                }
            }
        }
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (info.state == REJECT) {
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.GONE
            }
        }
    }
}
