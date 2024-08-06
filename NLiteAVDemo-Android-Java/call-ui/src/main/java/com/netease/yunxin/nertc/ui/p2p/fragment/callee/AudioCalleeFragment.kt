/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment.callee

import android.Manifest.permission.CAMERA
import android.Manifest.permission.RECORD_AUDIO
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.FragmentP2pAudioCalleeBinding
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.utils.toastShort

/**
 * 音频被叫页面
 */
open class AudioCalleeFragment : BaseP2pCallFragment() {
    protected val logTag = "AudioCalleeFragment"

    protected lateinit var binding: FragmentP2pAudioCalleeBinding

    override fun toCreateRootView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View = FragmentP2pAudioCalleeBinding.inflate(inflater, container, false).run {
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

        bindView(viewKeyImageReject, binding.ivReject)
        bindView(viewKeyTextRejectDesc, binding.tvRejectDesc)
        bindView(viewKeyImageAccept, binding.ivAccept)
        bindView(viewKeyTextAcceptDesc, binding.tvAcceptTip)

        bindView(viewKeyImageSwitchType, binding.ivSwitchType)
        bindView(viewKeyTextSwitchTypeDesc, binding.tvSwitchTypeDesc)

        bindView(viewKeyTextSwitchTip, binding.tvSwitchTip)
        bindView(viewKeyImageSwitchTipClose, binding.ivSwitchTipClose)
        bindView(viewKeySwitchTypeTipGroup, binding.switchTypeTipGroup)

        bindView(viewKeyTextConnectingTip, binding.tvConnectingTip)
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
                requestPermission(
                    listOf(CAMERA),
                    {
                        action.invoke()
                    },
                    { _, _ ->
                        context?.run {
                            getString(R.string.tip_permission_request_failed).toastShort(this)
                        }
                    }
                )
            }
        }
        getView<View>(viewKeyTextSwitchTypeDesc)?.visibility =
            if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE

        getView<ImageView>(viewKeyImageReject)?.run {
            bindClick(viewKeyImageReject) {
                bridge.doHangup()
            }
        }
        getView<ImageView>(viewKeyImageAccept)?.run {
            bindClick(viewKeyImageAccept) {
                getView<View>(viewKeyTextConnectingTip)?.visibility = View.VISIBLE
                bridge.doAccept {
                    if (!it.isSuccessful) {
                        context?.run {
                            getString(R.string.tip_accept_failed).toastShort(this)
                        }
                    }
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
    }

    override fun permissionList(): List<String> {
        return listOf(RECORD_AUDIO)
    }

    override fun toUpdateUIState(type: Int) {
        bridge.doConfigSpeaker(true)
    }
}
