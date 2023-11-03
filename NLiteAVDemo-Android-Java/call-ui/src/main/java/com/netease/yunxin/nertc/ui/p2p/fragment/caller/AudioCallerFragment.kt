/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment.caller

import android.Manifest.permission.CAMERA
import android.Manifest.permission.RECORD_AUDIO
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.netease.nimlib.sdk.ResponseCode
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.FragmentP2pAudioCallerBinding
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.FROM_FLOATING_WINDOW
import com.netease.yunxin.nertc.ui.utils.toastShort

/**
 * 音频呼叫页面
 */
open class AudioCallerFragment : BaseP2pCallFragment() {

    protected val logTag = "AudioCallerFragment"

    protected lateinit var binding: FragmentP2pAudioCallerBinding

    override fun toCreateRootView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? = FragmentP2pAudioCallerBinding.inflate(inflater, container, false).run {
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

        bindView(viewKeyImageCancel, binding.ivCancel)
        bindView(viewKeyTextCancelDesc, binding.tvCancelTip)

        bindView(viewKeyImageSwitchType, binding.ivCallSwitchType)
        bindView(viewKeyTextSwitchTypeDesc, binding.tvCallSwitchTypeDesc)
        bindView(viewKeyTextSwitchTip, binding.tvSwitchTip)
        bindView(viewKeyImageSwitchTipClose, binding.ivSwitchTipClose)
        bindView(viewKeySwitchTypeTipGroup, binding.switchTypeTipGroup)

        bindView(viewKeyMuteImageAudio, binding.ivCallMuteAudio)
        bindView(viewKeyTextMuteAudioDesc, binding.tvCallMuteAudioTip)
        bindView(viewKeyImageSpeaker, binding.ivCallSpeaker)
        bindView(viewKeyTextSpeakerDesc, binding.tvCallSpeakerTip)
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
        getView<View>(viewKeyImageCancel)?.bindClick(viewKeyImageCancel) {
            bridge.doHangup()
            activity?.finish()
        }

        val enableAutoJoinWhenCalled = CallKitUI.options?.enableAutoJoinWhenCalled == true
        getView<View>(viewKeySwitchTypeTipGroup)?.run {
            visibility = View.GONE
        }
        getView<View>(viewKeyImageSwitchType)?.run {
            visibility = if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE
            bindClick(viewKeyImageSwitchType) {
                if (!NetworkUtils.isConnected()) {
                    context?.run { getString(R.string.tip_network_error).toastShort(this) }
                    return@bindClick
                }
                val action = Action@{
                    switchCallType(NECallType.VIDEO)
                }
                if (arePermissionsGranted(listOf(CAMERA))) {
                    action.invoke()
                    return@bindClick
                }
                requestPermission(listOf(CAMERA), {
                    action.invoke()
                }, { _, _ ->
                    context?.run {
                        getString(R.string.tip_permission_request_failed).toastShort(this)
                    }
                })
            }
        }
        getView<View>(viewKeyTextSwitchTypeDesc)?.visibility =
            if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE

        getView<ImageView>(viewKeyMuteImageAudio)?.run {
            bindClick(viewKeyMuteImageAudio) {
                bridge.doMuteAudio()
                setImageResource(
                    if (bridge.isLocalMuteAudio) R.drawable.icon_call_audio_off else R.drawable.icon_call_audio_on
                )
            }
        }

        getView<ImageView>(viewKeyImageSpeaker)?.run {
            bindClick(viewKeyImageSpeaker) {
                val speakerEnable = !bridge.isSpeakerOn()
                bridge.doConfigSpeaker(speakerEnable)
                setImageResource(
                    if (bridge.isSpeakerOn()) R.drawable.icon_call_audio_speaker_on else R.drawable.icon_call_audio_speaker_off
                )
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

    override fun actionForPermissionGranted() {
        if (bridge.currentCallState() != CallState.STATE_IDLE) {
            return
        }
        bridge.doCall { result ->
            if (result?.isSuccessful != true &&
                result.code != ResponseCode.RES_PEER_NIM_OFFLINE.toInt() &&
                result.code != ResponseCode.RES_PEER_PUSH_OFFLINE.toInt()
            ) {
                context?.run { getString(R.string.tip_start_call_failed).toastShort(this) }
            }
        }
    }

    override fun toUpdateUIState(type: Int) {
        when (type) {
            FROM_FLOATING_WINDOW -> {
                getView<ImageView>(viewKeyImageSpeaker)?.run {
                    setImageResource(
                        if (bridge.isSpeakerOn()) R.drawable.icon_call_audio_speaker_on else R.drawable.icon_call_audio_speaker_off
                    )
                }
                getView<ImageView>(viewKeyMuteImageAudio)?.run {
                    setImageResource(
                        if (bridge.isLocalMuteAudio) R.drawable.icon_call_audio_off else R.drawable.icon_call_audio_on
                    )
                }
            }

            else -> {
                bridge.doConfigSpeaker(false)
                getView<ImageView>(viewKeyImageSpeaker)?.run {
                    setImageResource(
                        if (bridge.isSpeakerOn()) R.drawable.icon_call_audio_speaker_on else R.drawable.icon_call_audio_speaker_off
                    )
                }
            }
        }
    }
}
