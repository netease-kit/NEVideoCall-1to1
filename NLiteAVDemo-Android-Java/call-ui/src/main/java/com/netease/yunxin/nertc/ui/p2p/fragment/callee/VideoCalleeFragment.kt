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
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.utils.NetworkUtils
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.fetchNickname
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.FragmentP2pVideoCalleeBinding
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.utils.ClickUtils
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.requestPermission
import com.netease.yunxin.nertc.ui.utils.toastShort

/**
 * 视频被叫页面
 */
open class VideoCalleeFragment : BaseP2pCallFragment() {

    protected val logTag = "VideoCalleeFragment"

    protected lateinit var binding: FragmentP2pVideoCalleeBinding

    protected val switchObserver = object : NEResultObserver<CommonResult<Void>> {
        override fun onResult(result: CommonResult<Void>?) {
            if (result?.isSuccessful != true) {
                context?.run { getString(R.string.tip_switch_call_type_failed).toastShort(this) }
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

    override fun toCreateRootView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View = FragmentP2pVideoCalleeBinding.inflate(inflater, container, false).run {
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
        getView<View>(viewKeyImageCancel)?.setOnClickListener {
            bridge.doHangup()
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
                if (!NetworkUtils.isConnected()) {
                    context?.run { getString(R.string.tip_network_error).toastShort(this) }
                    return@setOnClickListener
                }
                bridge.doSwitchCallType(NECallType.AUDIO, SwitchCallState.INVITE, switchObserver)
            }
        }
        getView<View>(viewKeyTextSwitchTypeDesc)?.visibility =
            if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE

        getView<ImageView>(viewKeyImageReject)?.run {
            setOnClickListener {
                bridge.doHangup()
            }
        }
        getView<ImageView>(viewKeyImageAccept)?.run {
            setOnClickListener {
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
            setOnClickListener {
                getView<View>(viewKeySwitchTypeTipGroup)?.run {
                    visibility = View.GONE
                }
            }
        }
    }

    override fun onCreateAction() {
        val dialog = if (context?.isGranted(RECORD_AUDIO, CAMERA) == true) {
            return
        } else {
            bridge.showPermissionDialog {
                bridge.doHangup()
            }
        }
        requestPermission(
            onGranted = {
                if (it.containsAll(listOf(RECORD_AUDIO, CAMERA))) {
                    dialog.dismiss()
                } else {
                    context?.run {
                        getString(R.string.tip_permission_request_failed).toastShort(this)
                    }
                }
            },
            onDenied = { _, _ ->
                context?.run { getString(R.string.tip_permission_request_failed).toastShort(this) }
            },
            RECORD_AUDIO,
            CAMERA
        )
    }

    override fun toUpdateUIState(type: Int) {
        bridge.doConfigSpeaker(true)
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (info.state == SwitchCallState.REJECT) {
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.GONE
            }
        }
    }
}
