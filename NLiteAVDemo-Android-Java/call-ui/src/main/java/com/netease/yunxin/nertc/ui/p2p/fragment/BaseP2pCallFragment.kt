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
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PUIUpdateType.INIT
import com.netease.yunxin.nertc.ui.utils.PermissionRequester
import com.netease.yunxin.nertc.ui.utils.PermissionTipDialog
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.registerPermissionRequesterEx
import com.netease.yunxin.nertc.ui.utils.toastShort

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

    /**
     * 页面中小窗触发控件
     */
    protected val viewKeyImageFloatingWindow = "ivFloatingWindow"

    /**
     * 视频背景虚化开关图片控件
     */
    protected val viewKeyImageVirtualBlur = "ivVirtualBlur"

    /**
     * fragment和activity交互接口
     */
    protected lateinit var bridge: FragmentActionBridge
        private set

    /**
     * 页面根布局
     */
    protected var rootView: View? = null
        private set

    /**
     * 申请权限工具
     */
    protected var permissionRequester: PermissionRequester? = null

    /**
     * 权限提示弹窗
     */
    protected var permissionTipDialog: PermissionTipDialog? = null

    /**
     * 日志标签
     */
    private val logTag = "BaseP2pCallFragment"

    /**
     * 页面初始化类型
     */
    private var initType: Int = INIT

    /**
     * 页面元素绑定映射关系
     */
    private val viewBindMap = mutableMapOf<String, View?>()

    /**
     * 页面点击事件前置动作行为映射
     */
    private val beforeClickMap = mutableMapOf<String, (View) -> Boolean>()

    /**
     * 页面点击事件后置动作行为映射
     */
    private val afterClickMap = mutableMapOf<String, (View) -> Unit>()

    /**
     * 页面切换通话类型回调
     */
    private val switchObserver = object : NEResultObserver<CommonResult<Void>> {
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

    private val rtcDelegate = object : NERtcCallbackExTemp() {
        override fun onJoinChannel(res: Int, cid: Long, time: Long, uid: Long) {
            this@BaseP2pCallFragment.onJoinChannel(res, cid, time, uid)
        }
    }

    fun configData(bridge: FragmentActionBridge, initType: Int = INIT) {
        this.bridge = bridge
        this.initType = initType
    }

    open fun toUpdateUIState(type: Int) {
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerPermissionRequester()
    }

    final override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View? = toCreateRootView(inflater, container, savedInstanceState).apply {
        logApiInvoke("toCreateRootView")
        this@BaseP2pCallFragment.rootView = this
        NERtcCallbackProxyMgr.getInstance().addCallback(rtcDelegate)
        toBindView()
        logApiInvoke("toBindView")
        toRenderView(bridge.callParam, bridge.uiConfig)
        logApiInvoke("toRenderView")
        onPermissionRequest()
        logApiInvoke("onPermissionRequest")
        onCreateAction()
        logApiInvoke("onCreateAction")
        toUpdateUIState(initType)
        logApiInvoke("toUpdateUIState")
        initType = INIT
    }

    override fun onDestroyView() {
        super.onDestroyView()
        NERtcCallbackProxyMgr.getInstance().removeCallback(rtcDelegate)
        permissionTipDialog?.dismiss()
        viewBindMap.clear()
        logApiInvoke("onDestroyAction")
    }

    protected open fun registerPermissionRequester() {
        val permissionList = permissionList()
        if (permissionList.isNotEmpty()) {
            permissionRequester = registerPermissionRequesterEx()
        }
    }

    protected open fun arePermissionsGranted(permissionList: List<String> = permissionList()): Boolean {
        return context?.isGranted(*permissionList().toTypedArray()) == true
    }

    protected open fun onPermissionRequest() {
        permissionTipDialog = if (arePermissionsGranted()) {
            actionForPermissionGranted()
            logApiInvoke("actionForPermissionGranted")
            return
        } else {
            bridge.showPermissionDialog {
                activity?.finish()
            }
        }
        val permissionList = permissionList()
        permissionRequester?.request(
            onGranted = {
                if (it.containsAll(permissionList)) {
                    permissionTipDialog?.dismiss()
                    actionForPermissionGranted()
                    logApiInvoke("actionForPermissionGranted")
                }
            },
            onDenied = { _, _ ->
                actionForPermissionDenied()
                logApiInvoke("actionForPermissionDenied")
            },
            permissionList = permissionList
        )
    }

    protected open fun requestPermission(
        permissionList: List<String>,
        onGranted: ((List<String>) -> Unit)? = null,
        onDenied: ((List<String>, List<String>) -> Unit)? = null
    ) {
        permissionRequester?.request(
            onGranted = {
                onGranted?.invoke(it)
            },
            onDenied = { deniedForeverList, deniedList ->
                onDenied?.invoke(deniedForeverList, deniedList)
            },
            permissionList = permissionList
        )
    }

    protected open fun toCreateRootView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? = null

    protected open fun permissionList(): List<String> = emptyList()

    protected open fun actionForPermissionGranted() {
    }

    protected open fun actionForPermissionDenied() {
        context?.run {
            getString(R.string.tip_permission_request_failed).toastShort(this)
        }
    }

    protected open fun toBindView() {
    }

    protected open fun toRenderView(callParam: CallParam, uiConfig: P2PUIConfig?) {
    }

    protected open fun onCreateAction() {
    }

    protected open fun onDestroyAction() {
    }

    protected open fun switchCallType(
        callType: Int,
        switchCallState: Int = SwitchCallState.INVITE,
        observer: NEResultObserver<CommonResult<Void>>? = switchObserver
    ) {
        bridge.doSwitchCallType(callType, SwitchCallState.INVITE, switchObserver)
    }

    protected fun bindView(key: String, view: View?) {
        viewBindMap[key] = view
    }

    @Suppress("UNCHECKED_CAST")
    protected fun <T> getView(key: String): T? {
        return viewBindMap[key] as? T
    }

    protected open fun View.bindClick(
        key: String,
        onClick: (View) -> Unit
    ) {
        setOnClickListener {
            if (beforeClickMap[key]?.invoke(this) == true) {
                return@setOnClickListener
            }
            onClick.invoke(this)
            afterClickMap[key]?.invoke(this)
        }
    }

    protected fun bindBeforeClick(key: String, onClick: (View) -> Boolean) {
        beforeClickMap[key] = onClick
    }

    protected fun bindAfterClick(key: String, onClick: (View) -> Unit) {
        afterClickMap[key] = onClick
    }

    protected fun removeView(key: String) = viewBindMap.remove(key)

    override fun onReceiveInvited(info: NEInviteInfo) {}

    override fun onCallConnected(info: NECallInfo) {}

    override fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (info.state == SwitchCallState.REJECT || info.state == SwitchCallState.ACCEPT) {
            getView<View>(viewKeySwitchTypeTipGroup)?.run {
                visibility = View.GONE
            }
        }
    }

    override fun onCallEnd(info: NECallEndInfo) {}

    override fun onVideoAvailable(userId: String?, available: Boolean) {}

    override fun onVideoMuted(userId: String?, mute: Boolean) {}

    override fun onAudioMuted(userId: String?, mute: Boolean) {}

    open fun onJoinChannel(res: Int, cid: Long, time: Long, uid: Long) {}

    private fun logApiInvoke(name: String?) {
        ALog.dApi(logTag, "${this@BaseP2pCallFragment}:$name was invoked.")
    }
}
