/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.nertc.ui.service

import android.content.Context
import android.text.TextUtils
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.ResponseCode
import com.netease.yunxin.kit.alog.ParameterMap
import com.netease.yunxin.kit.call.group.GroupCallEndEvent
import com.netease.yunxin.kit.call.group.GroupCallHangupEvent
import com.netease.yunxin.kit.call.group.GroupCallMember
import com.netease.yunxin.kit.call.group.NEGroupCall
import com.netease.yunxin.kit.call.group.NEGroupCallDelegate
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.group.NEGroupConstants
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.extra.NECallLocalActionMgr
import com.netease.yunxin.kit.call.p2p.extra.NECallLocalActionObserver
import com.netease.yunxin.kit.call.p2p.model.NECallEndInfo
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegate
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegateAbs
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NECallTypeChangeInfo
import com.netease.yunxin.kit.call.p2p.model.NEHangupReasonCode
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.nertcvideocall.model.CallErrorCode
import com.netease.yunxin.nertc.nertcvideocall.model.CallLocalAction
import com.netease.yunxin.nertc.nertcvideocall.model.SwitchCallState
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.ui.base.AVChatSoundPlayer
import com.netease.yunxin.nertc.ui.group.GroupCallUIDelegate
import com.netease.yunxin.nertc.ui.group.GroupCallUIManager
import com.netease.yunxin.nertc.ui.utils.CallUILog

/**
 * 邀请消息分发
 *
 * 当消息过来时
 */
open class CallKitUIBridgeService @JvmOverloads constructor(
    val context: Context,
    val incomingCallEx: IncomingCallEx = DefaultIncomingCallEx()
) {
    protected val logTag = "CallKitUIBridgeService"

    /**
     * 记录 app 在后台时收到的邀请信息，点对点
     */
    protected var bgInvitedInfo: NEInviteInfo? = null

    /**
     * 记录 app 在后台时收到的邀请信息，群组
     */
    protected var bgGroupInvitedInfo: NEGroupCallInfo? = null

    /**
     * 是否能停止音频播放
     */
    protected var canStopAudioPlay = true

    /**
     * 呼叫方用户 accId
     */
    protected var callerAccId: String? = null

    /**
     * 群组通话行为监听
     */
    private val groupActionObserver = object :
        NEGroupCallDelegate {
        override fun onReceiveGroupInvitation(info: NEGroupCallInfo) {
            this@CallKitUIBridgeService.onReceiveGroupInvitation(info)
        }
        override fun onGroupMemberListChanged(callId: String, userList: MutableList<GroupCallMember>?) {
            this@CallKitUIBridgeService.onMemberChanged(callId, userList)
        }

        override fun onGroupCallHangup(hangupEvent: GroupCallHangupEvent) {
            this@CallKitUIBridgeService.onGroupCallHangup(hangupEvent.callId)
        }

        override fun onGroupCallEnd(endEvent: GroupCallEndEvent) {
            this@CallKitUIBridgeService.onGroupCallHangup(endEvent.callId)
        }
    }

    private val groupCallUIDelegate = object : GroupCallUIDelegate {
        override fun onLocalAction(actionId: Int) {
            this@CallKitUIBridgeService.onLocalAction(actionId)
        }
    }

    /**
     * 点对点本地行为监听
     */
    private val localActionObserver = NECallLocalActionObserver { actionId, resultCode, _ ->
        this@CallKitUIBridgeService.onLocalAction(actionId, resultCode)
    }

    /**
     * 点对点通话行为监听
     */
    private val callEngineDelegate: NECallEngineDelegate = object : NECallEngineDelegateAbs() {

        override fun onReceiveInvited(info: NEInviteInfo) {
            this@CallKitUIBridgeService.onReceiveInvited(info)
        }

        override fun onCallConnected(info: NECallInfo) {
            this@CallKitUIBridgeService.onCallConnected(info)
        }

        override fun onCallTypeChange(info: NECallTypeChangeInfo) {
            this@CallKitUIBridgeService.onCallTypeChange(info)
        }

        override fun onCallEnd(info: NECallEndInfo) {
            this@CallKitUIBridgeService.onCallEnd(info)
        }
    }

    init {
        /**
         * 初始化注册相关监听及
         */
        NECallEngine.sharedInstance().addCallDelegate(callEngineDelegate)
        NECallLocalActionMgr.getInstance().addCallback(localActionObserver)
        NEGroupCall.instance().addGroupCallDelegate(groupActionObserver)
        GroupCallUIManager.getInstance().addDelegate(groupCallUIDelegate)
    }

    // //////////////////////////////////// GroupCallLocalActionObserver ////////////////////////////
    /**
     * 群组本地行为监听
     */
    open fun onLocalAction(actionId: Int) {
        CallUILog.dApi(
            logTag,
            ParameterMap("onLocalAction").append("actionId", actionId)
        )
        if (bgGroupInvitedInfo != null) {
            incomingCallEx.onIncomingCallInvalid(bgGroupInvitedInfo)
            bgGroupInvitedInfo = null
        }
    }

    // //////////////////////////////////// NEGroupCallActionObserver ///////////////////////////////
    /**
     * 群组通话人员变更
     */
    open fun onMemberChanged(callId: String?, userList: MutableList<GroupCallMember>?) {
        if (bgGroupInvitedInfo != null && TextUtils.equals(
                callId,
                bgGroupInvitedInfo!!.callId
            ) && userList != null
        ) {
            val index = userList.indexOf(GroupCallMember(NIMClient.getCurrentAccount()))
            if (index < 0) {
                return
            }
            if (userList[index].state == NEGroupConstants.UserState.LEAVING || userList[index].state == NEGroupConstants.UserState.JOINED) {
                incomingCallEx.onIncomingCallInvalid(bgGroupInvitedInfo)
                bgGroupInvitedInfo = null
            }
        }
    }

    /**
     * 群组通话结束挂断
     */
    open fun onGroupCallHangup(callId: String) {
        if (bgGroupInvitedInfo != null && TextUtils.equals(
                callId,
                bgGroupInvitedInfo!!.callId
            )
        ) {
            incomingCallEx.onIncomingCallInvalid(bgGroupInvitedInfo)
            bgGroupInvitedInfo = null
        }
    }

    // //////////////////////////////////// NEGroupIncomingCallReceiver /////////////////////////////
    /**
     * 群组来电监听
     */
    open fun onReceiveGroupInvitation(info: NEGroupCallInfo) {
        CallUILog.dApi(logTag, ParameterMap("onReceiveGroupInvitation").append("info", info))
        // 检查参数合理性
        if (!isValidParam(info)) {
            CallUILog.d(logTag, "onIncomingCall for group, param is invalid.")
            return
        }
        if (!incomingCallEx.onIncomingCall(info)) {
            bgGroupInvitedInfo = info
        }
    }

    // //////////////////////////////////// NECallLocalActionObserver ///////////////////////////////
    /**
     * 点对点本地行为监听
     */
    open fun onLocalAction(actionId: Int, resultCode: Int) {
        CallUILog.d(logTag, "onLocalAction actionId is $actionId, resultCode is $resultCode.")
        if (actionId == CallLocalAction.ACTION_CALL && NECallEngine.sharedInstance().callInfo.callStatus == CallState.STATE_CALL_OUT) {
            callerAccId = NIMClient.getCurrentAccount()
            canStopAudioPlay = true
            AVChatSoundPlayer.play(context, AVChatSoundPlayer.RingerTypeEnum.CONNECTING)
        } else if (canStopAudioPlay && callerAccId != null &&
            actionId != CallLocalAction.ACTION_BEFORE_RESET &&
            actionId != CallLocalAction.ACTION_SWITCH &&
            (resultCode == CallErrorCode.SUCCESS || resultCode == ResponseCode.RES_SUCCESS.toInt())
        ) {
            AVChatSoundPlayer.stop(context)
            callerAccId = null
        }
        if (bgInvitedInfo != null) {
            incomingCallEx.onIncomingCallInvalid(bgInvitedInfo)
            bgInvitedInfo = null
        }
    }
    // //////////////////////////////////// NECallEngineDelegateAbs /////////////////////////////////
    /**
     * 点对点通话行为监听
     */
    open fun onReceiveInvited(info: NEInviteInfo) {
        CallUILog.dApi(logTag, ParameterMap("onReceiveInvited").append("info", info))
        // 检查参数合理性
        if (!isValidParam(info)) {
            CallUILog.d(logTag, "onIncomingCall, param is invalid.")
            return
        }
        if (!incomingCallEx.onIncomingCall(info)) {
            bgInvitedInfo = info
        }

        callerAccId = info.callerAccId
        canStopAudioPlay = true
        if (NECallEngine.sharedInstance().callInfo.callStatus == CallState.STATE_INVITED) {
            AVChatSoundPlayer.play(context, AVChatSoundPlayer.RingerTypeEnum.RING)
        }
    }

    /**
     * 点对点通话建立
     */
    open fun onCallConnected(info: NECallInfo) {
        CallUILog.dApi(logTag, ParameterMap("onCallConnected").append("info", info))
        incomingCallEx.onIncomingCallInvalid(bgInvitedInfo)
        bgInvitedInfo = null
        AVChatSoundPlayer.stop(context)
    }

    /**
     * 点对点通话类型变更
     */
    open fun onCallTypeChange(info: NECallTypeChangeInfo) {
        if (info.state == SwitchCallState.ACCEPT && bgInvitedInfo != null) {
            bgInvitedInfo = bgInvitedInfo?.run {
                NEInviteInfo(callerAccId, info.callType, extraInfo, channelId)
            }
        }
    }

    /**
     * 点对点通话结束回调
     */
    open fun onCallEnd(info: NECallEndInfo) {
        CallUILog.dApi(logTag, ParameterMap("onCallEnd").append("info", info))
        incomingCallEx.onIncomingCallInvalid(bgInvitedInfo)
        when (info.reasonCode) {
            NEHangupReasonCode.CALLER_REJECTED -> if (callerAccId == NIMClient.getCurrentAccount()) {
                playStopAudio(AVChatSoundPlayer.RingerTypeEnum.PEER_REJECT)
            } else {
                AVChatSoundPlayer.stop(context)
            }

            NEHangupReasonCode.BUSY -> if (callerAccId == NIMClient.getCurrentAccount()) {
                playStopAudio(AVChatSoundPlayer.RingerTypeEnum.PEER_BUSY)
            } else {
                AVChatSoundPlayer.stop(context)
            }

            NEHangupReasonCode.TIME_OUT -> if (callerAccId == NIMClient.getCurrentAccount()) {
                playStopAudio(AVChatSoundPlayer.RingerTypeEnum.NO_RESPONSE)
            } else {
                AVChatSoundPlayer.stop(context)
            }

            else -> AVChatSoundPlayer.stop(context)
        }
        bgInvitedInfo = null
        callerAccId = null
    }

    /**
     * 尝试恢复被叫在后台无法展示的页面UI
     *
     * @return true 恢复成功，false 恢复失败。
     */
    open fun tryResumeInvitedUI(): Boolean {
        return bgInvitedInfo?.run {
            val result = incomingCallEx.tryResumeInvitedUI(this)
            if (result) {
                bgInvitedInfo = null
            }
            result
        } ?: bgGroupInvitedInfo?.run {
            val result = incomingCallEx.tryResumeInvitedUI(this)
            if (result) {
                bgGroupInvitedInfo = null
            }
            result
        } ?: run {
            CallUILog.d(logTag, "no background inviteInfo, mContext or uiService is null.")
            false
        }
    }

    /**
     * 播放停止音频内容
     */
    protected open fun playStopAudio(type: AVChatSoundPlayer.RingerTypeEnum) {
        AVChatSoundPlayer.play(context, type)
        canStopAudioPlay = false
    }

    /**
     * 判断群组呼叫参数是否有效
     */
    protected open fun isValidParam(invitedInfo: NEGroupCallInfo): Boolean {
        if (TextUtils.isEmpty(invitedInfo.callId) ||
            TextUtils.isEmpty(invitedInfo.callerAccId) ||
            invitedInfo.memberList == null ||
            invitedInfo.memberList.isEmpty()
        ) {
            return false
        }
        val index = invitedInfo.memberList.indexOf(GroupCallMember(NIMClient.getCurrentAccount()))
        if (index < 0) {
            return false
        }
        return true
    }

    /**
     * 判断点对点呼叫是否有效
     */
    protected open fun isValidParam(invitedInfo: NEInviteInfo): Boolean {
        return invitedInfo.callType == NECallType.VIDEO || invitedInfo.callType == NECallType.AUDIO
    }

    /**
     * 销毁
     */
    internal open fun destroy() {
        NECallEngine.sharedInstance().removeCallDelegate(callEngineDelegate)
        NECallLocalActionMgr.getInstance().removeCallback(localActionObserver)
        NEGroupCall.instance().removeGroupCallDelegate(groupActionObserver)
        GroupCallUIManager.getInstance().removeDelegate(groupCallUIDelegate)
    }
}
