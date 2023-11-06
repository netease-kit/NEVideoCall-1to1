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
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.nimlib.sdk.ResponseCode
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.FragmentP2pVideoCallerBinding
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.utils.toastShort

/**
 * 视频呼叫页面
 */
open class VideoCallerFragment : BaseP2pCallFragment() {
    protected val logTag = "VideoCallerFragment"

    protected lateinit var binding: FragmentP2pVideoCallerBinding

    override fun toCreateRootView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? = FragmentP2pVideoCallerBinding.inflate(inflater, container, false).run {
        binding = this
        this.root
    }

    override fun toBindView() {
        bindView(viewKeyVideoViewPreview, binding.videoViewPreview)

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
                null,
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
                switchCallType(NECallType.AUDIO)
            }
        }
        getView<View>(viewKeyTextSwitchTypeDesc)?.visibility =
            if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE
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
        return listOf(RECORD_AUDIO, CAMERA)
    }

    override fun actionForPermissionGranted() {
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
        getView<NERtcVideoView>(viewKeyVideoViewPreview)?.run {
            bridge.setupLocalView(this)
        }
        bridge.startVideoPreview()
    }

    override fun toUpdateUIState(type: Int) {
        bridge.doConfigSpeaker(true)
    }

    override fun onHiddenChanged(hidden: Boolean) {
        if (hidden) {
            getView<NERtcVideoView>(viewKeyVideoViewPreview)?.run {
                visibility = View.GONE
            }
            bridge.stopVideoPreview()
        } else {
            getView<NERtcVideoView>(viewKeyVideoViewPreview)?.run {
                visibility = View.VISIBLE
            }
            bridge.startVideoPreview()
        }
    }

    override fun onCallEnd(info: NECallEndInfo) {
        bridge.stopVideoPreview()
    }
}
