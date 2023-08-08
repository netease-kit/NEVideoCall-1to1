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
import com.netease.lava.nertc.sdk.NERtcConstants.ErrorCode.ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED
import com.netease.lava.nertc.sdk.NERtcConstants.ErrorCode.OK
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.nimlib.sdk.ResponseCode
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
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
import com.netease.yunxin.nertc.ui.databinding.FragmentP2pVideoCallerBinding
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment
import com.netease.yunxin.nertc.ui.utils.ClickUtils
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.requestPermission
import com.netease.yunxin.nertc.ui.utils.toastShort

/**
 * 视频呼叫页面
 */
open class VideoCallerFragment : BaseP2pCallFragment() {
    protected val logTag = "VideoCallerFragment"

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

    protected lateinit var binding: FragmentP2pVideoCallerBinding

    protected var startPreviewCode: Int? = null

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
                if (!NetworkUtils.isConnected()) {
                    context?.run { getString(R.string.tip_network_error).toastShort(this) }
                    return@setOnClickListener
                }
                bridge.doSwitchCallType(NECallType.AUDIO, SwitchCallState.INVITE, switchObserver)
            }
        }
        getView<View>(viewKeyTextSwitchTypeDesc)?.visibility =
            if (enableAutoJoinWhenCalled) View.VISIBLE else View.GONE
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
            getView<NERtcVideoView>(viewKeyVideoViewPreview)?.run {
                bridge.setupLocalView(this)
            }
            if (CallKitUI.options?.joinRtcWhenCall == false &&
                startPreviewCode != OK &&
                startPreviewCode != ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED
            ) {
                startPreviewCode = startVideoPreview()
            }
        }

        val dialog = if (context?.isGranted(RECORD_AUDIO, CAMERA) == true) {
            action.invoke()
            return
        } else {
            bridge.showPermissionDialog {
                activity?.finish()
            }
        }

        requestPermission(
            onGranted = {
                if (it.containsAll(listOf(RECORD_AUDIO, CAMERA))) {
                    dialog.dismiss()
                    action.invoke()
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

    override fun onCallEnd(info: NECallEndInfo) {
        if (startPreviewCode == OK || startPreviewCode == ENGINE_ERROR_DEVICE_PREVIEW_ALREADY_STARTED) {
            stopVideoPreview()
            startPreviewCode = null
        }
    }

    protected open fun startVideoPreview(): Int = NERtcEx.getInstance().startVideoPreview().apply {
        ALog.d(logTag, "startVideoPreview is $this, this fragment is ${this@VideoCallerFragment}")
    }

    protected open fun stopVideoPreview(): Int = NERtcEx.getInstance().stopVideoPreview().apply {
        ALog.d(logTag, "stopVideoPreview is $this, this fragment is ${this@VideoCallerFragment}")
    }

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (info.state == SwitchCallState.REJECT) {
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.GONE
            }
        }
    }
}
