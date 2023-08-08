/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.INIT

/**
 * 处理 ui 相关内容，主要处理 页面点击相关内容，添加相关监听，页面状态切换
 */
@Suppress("unused")
open class BaseP2pCallFragment : Fragment(), NECallEngineDelegate {
    /**
     * 视频呼叫本地预览控件
     */
    protected val viewKeyVideoViewPreview = "videoViewPreview"

    /**
     * 视频通话大视频控件
     */
    protected val viewKeyVideoViewBig = "videoViewBig"

    /**
     * 视频通话小视频控件
     */
    protected val viewKeyVideoViewSmall = "videoViewSmall"

    /**
     * 视频通话关闭视频时大视频的覆盖涂层控件
     */
    protected val viewKeyImageVideoShadeBig = "ivBigVideoShade"

    /**
     * 视频通话关闭视频时小视频的覆盖涂层控件
     */
    protected val viewKeyImageVideoShadeSmall = "ivSmallVideoShade"

    /**
     * 语音通话时大的背景图控件
     */
    protected val viewKeyImageBigBackground = "bigBackground"

    /**
     * 对端用户没有头像时展示文本头像控件
     */
    protected val viewKeyTextUserInnerAvatar = "tvUserInnerAvatar"

    /**
     * 对端用户头像展示控件
     */
    protected val viewKeyImageUserInnerAvatar = "ivUserInnerAvatar"

    /**
     * 头像整体父布局控件
     */
    protected val viewKeyFrameLayoutUserAvatar = "flUserAvatar"

    /**
     * 对端用户昵称文本控件
     */
    protected val viewKeyTextUserName = "tvUserName"

    /**
     * 呼叫/被叫时文本提示控件
     */
    protected val viewKeyTextOtherCallTip = "tvOtherCallTip"

    /**
     * 取消呼叫图片控件
     */
    protected val viewKeyImageCancel = "ivCancel"

    /**
     * 取消呼叫文本控件
     */
    protected val viewKeyTextCancelDesc = "tvCancelDesc"

    /**
     * 拒绝接听图片控件
     */
    protected val viewKeyImageReject = "ivReject"

    /**
     * 拒绝文本控件
     */
    protected val viewKeyTextRejectDesc = "tvRejectDesc"

    /**
     * 接听图片控件
     */
    protected val viewKeyImageAccept = "ivAccept"

    /**
     * 接听文本控件
     */
    protected val viewKeyTextAcceptDesc = "tvAcceptDesc"

    /**
     * 通话中挂断图片控件
     */
    protected val viewKeyImageHangup = "ivHangUp"

    /**
     * 切换摄像头图片控件
     */
    protected val viewKeyImageSwitchCamera = "ivSwitchCamera"

    /**
     * 切换通话类型图片控件
     */
    protected val viewKeyImageSwitchType = "ivSwitchType"

    /**
     * 切换通话类型文本控件
     */
    protected val viewKeyTextSwitchTypeDesc = "tvSwitchTypeDesc"

    /**
     * 切换通话过程中提示文本控件
     */
    protected val viewKeyTextSwitchTip = "tvSwitchTip"

    /**
     * 切换通话过程中提示关闭图片控件
     */
    protected val viewKeyImageSwitchTipClose = "ivSwitchTipClose"

    /**
     * 切换通话过程中整体提示组控件，用户控制 [viewKeyTextSwitchTip] 和 [viewKeyImageSwitchTipClose] 的展示/隐藏
     */
    protected val viewKeySwitchTypeTipGroup = "switchTypeTipGroup"

    /**
     * 摄像头开关图片控件
     */
    protected val viewKeyMuteImageVideo = "ivVideo"

    /**
     * 本地麦克风开关图片控件
     */
    protected val viewKeyMuteImageAudio = "ivAudio"

    /**
     * 本地麦克风文本控件
     */
    protected val viewKeyTextMuteAudioDesc = "tvMuteAudioDesc"

    /**
     * 扬声器开关图片控件
     */
    protected val viewKeyImageSpeaker = "ivSpeaker"

    /**
     * 扬声器开关文本控件
     */
    protected val viewKeyTextSpeakerDesc = "tvSpeakerDesc"

    /**
     * 接听中提示文本控件
     */
    protected val viewKeyTextConnectingTip = "tvConnectingTip"

    /**
     * 通话中倒计时文本控件
     */
    protected val viewKeyTextTimeCountdown = "tvCountdown"

    /**
     * 视频通话中远端视频关闭时文本提示控件
     */
    protected val viewKeyTextRemoteVideoCloseTip = "tvRemoteVideoCloseTip"

    protected lateinit var bridge: FragmentActionBridge
        private set

    /**
     * 页面根布局
     */
    protected var rootView: View? = null
        private set

    /**
     * 页面元素绑定映射关系
     */
    private val viewBindMap = mutableMapOf<String, View?>()

    private val rtcDelegate = object : NERtcCallbackExTemp() {
        override fun onJoinChannel(res: Int, cid: Long, time: Long, uid: Long) {
            this@BaseP2pCallFragment.onJoinChannel(res, cid, time, uid)
        }
    }

    fun configData(bridge: FragmentActionBridge) {
        this.bridge = bridge
    }

    open fun toUpdateUIState(type: Int) {
    }

    final override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? = toCreateRootView(inflater, container, savedInstanceState).apply {
        this@BaseP2pCallFragment.rootView = this
        NERtcCallbackProxyMgr.getInstance().addCallback(rtcDelegate)
        toBindView()
        toRenderView(bridge.callParam, bridge.uiConfig)
        onCreateAction()
        toUpdateUIState(INIT)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        NERtcCallbackProxyMgr.getInstance().removeCallback(rtcDelegate)
        viewBindMap.clear()
        onDestroyAction()
    }

    protected open fun toCreateRootView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? = null

    protected open fun toBindView() {
    }

    protected open fun toRenderView(callParam: CallParam, uiConfig: P2PUIConfig?) {
    }

    protected open fun onCreateAction() {
    }

    protected open fun onDestroyAction() {
    }

    protected fun bindView(key: String, view: View?) {
        viewBindMap[key] = view
    }

    @Suppress("UNCHECKED_CAST")
    protected fun <T> getView(key: String): T? {
        return viewBindMap[key] as? T
    }

    protected fun removeView(key: String) = viewBindMap.remove(key)

    override fun onReceiveInvited(info: NEInviteInfo) {}

    override fun onCallConnected(info: NECallInfo) {}

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {}

    override fun onCallEnd(info: NECallEndInfo) {}

    override fun onVideoAvailable(userId: String?, available: Boolean) {}

    override fun onVideoMuted(userId: String?, mute: Boolean) {}

    override fun onAudioMuted(userId: String?, mute: Boolean) {}

    open fun onJoinChannel(res: Int, cid: Long, time: Long, uid: Long) {}
}
