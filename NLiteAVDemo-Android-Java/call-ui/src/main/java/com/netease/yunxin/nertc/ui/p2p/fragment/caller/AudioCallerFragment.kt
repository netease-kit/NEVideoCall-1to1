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
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
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
import com.netease.yunxin.nertc.ui.utils.ClickUtils
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.requestPermission
import com.netease.yunxin.nertc.ui.utils.toastShort

/**
 * 音频呼叫页面
 */
open class AudioCallerFragment : BaseP2pCallFragment() {

    protected val logTag = "AudioCallerFragment"

    protected lateinit var binding: FragmentP2pAudioCallerBinding

    protected val switchObserver = object : NEResultObserver<CommonResult<Void>> {
        override fun onResult(result: CommonResult<Void>?) {
            if (result?.isSuccessful != true) {
                context?.run { getString(R.string.tip_switch_call_type_failed).toastShort(this) }
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
            activity?.finish()
        }

        val enableAutoJoinWhenCalled = CallKitUI.options?.enableAutoJoinWhenCalled == true
        getView<View>(viewKeySwitchTypeTipGroup)?.run {
            visibility = View.GONE
        }
        getView<View>(viewKeyImageSwitchType)?.run {
            visibility = if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE
            setOnClickListener {
                if (ClickUtils.isFastClick()) {
                    return@setOnClickListener
                }
                val action = Action@{
                    if (!NetworkUtils.isConnected()) {
                        context?.run { getString(R.string.tip_network_error).toastShort(this) }
                        return@Action
                    }
                    bridge.doSwitchCallType(
                        NECallType.VIDEO,
                        SwitchCallState.INVITE,
                        switchObserver
                    )
                }
                if (context?.isGranted(CAMERA) == true) {
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
                    CAMERA
                )
            }
        }
        getView<View>(viewKeyTextSwitchTypeDesc)?.visibility =
            if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE

        getView<ImageView>(viewKeyMuteImageAudio)?.run {
            setOnClickListener {
                bridge.doMuteAudio()
                setImageResource(
                    if (bridge.isLocalMuteAudio) R.drawable.icon_call_audio_off else R.drawable.icon_call_audio_on
                )
            }
        }

        getView<ImageView>(viewKeyImageSpeaker)?.run {
            setOnClickListener {
                val speakerEnable = !bridge.isSpeakerOn()
                bridge.doConfigSpeaker(speakerEnable)
                setImageResource(
                    if (bridge.isSpeakerOn()) R.drawable.icon_call_audio_speaker_on else R.drawable.icon_call_audio_speaker_off
                )
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
        val action = {
            if (bridge.currentCallState() == CallState.STATE_IDLE) {
                bridge.doCall { result ->
                    if (result?.isSuccessful != true &&
                        result.code != ResponseCode.RES_PEER_NIM_OFFLINE.toInt() &&
                        result.code != ResponseCode.RES_PEER_PUSH_OFFLINE.toInt()
                    ) {
                        context?.run { getString(R.string.tip_start_call_failed).toastShort(this) }
                    }
                }
            }
        }

        val dialog = if (context?.isGranted(RECORD_AUDIO) == true) {
            action.invoke()
            return
        } else {
            bridge.showPermissionDialog {
                activity?.finish()
            }
        }

        requestPermission(
            onGranted = {
                dialog.dismiss()
                action.invoke()
            },
            onDenied = { _, _ ->
                context?.run {
                    getString(R.string.tip_permission_request_failed).toastShort(this)
                }
            },
            RECORD_AUDIO
        )
    }

    override fun toUpdateUIState(type: Int) {
        bridge.doConfigSpeaker(false)
        getView<ImageView>(viewKeyImageSpeaker)?.run {
            setImageResource(
                if (bridge.isSpeakerOn()) R.drawable.icon_call_audio_speaker_on else R.drawable.icon_call_audio_speaker_off
            )
        }
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (info.state == SwitchCallState.REJECT) {
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.GONE
            }
        }
    }
}
