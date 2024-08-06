/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment.onthecall

import android.Manifest.permission.CAMERA
import android.Manifest.permission.RECORD_AUDIO
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
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
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.FROM_FLOATING_WINDOW
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.INIT
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
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
        bindView(viewKeyImageFloatingWindow, binding.ivFloatingWindow)
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
        getView<View>(viewKeyImageSwitchType)?.run {
            visibility =
                if (uiConfig?.showAudio2VideoSwitchOnTheCall == true) View.VISIBLE else View.GONE
            bindClick(viewKeyImageSwitchType) {
                if (!NetworkUtils.isConnected()) {
                    context?.run {
                        getString(R.string.tip_network_error).toastShort(this)
                    }
                    return@bindClick
                }
                val action = Action@{
                    switchCallType(NECallType.VIDEO)
                }
                if (arePermissionsGranted(listOf(CAMERA))) {
                    action.invoke()
                    return@bindClick
                }
                requestPermission(
                    listOf(CAMERA),
                    onGranted = {
                        action.invoke()
                    },
                    onDenied = { _, _ ->
                        context?.run {
                            getString(R.string.tip_permission_request_failed).toastShort(this)
                        }
                    }
                )
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
    }

    override fun permissionList(): List<String> {
        return listOf(RECORD_AUDIO)
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
                bridge.doConfigSpeaker(false)
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
            FROM_FLOATING_WINDOW -> {
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
        }
        toInitState()
    }

    protected open fun toInitState() {
        getView<TextView>(viewKeyTextTimeCountdown)?.run {
            bridge.configTimeTick(
                CallUIOperationsMgr.TimeTickConfig({
                    CoroutineScope(Dispatchers.Main).launch {
                        this@run.text = it.formatSecondTime()
                    }
                })
            )
        }
        getView<View>(viewKeySwitchTypeTipGroup)?.run {
            visibility = View.GONE
        }
    }
}
