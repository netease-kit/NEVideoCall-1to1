/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import com.netease.nimlib.sdk.v2.notification.V2NIMCustomNotification
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.group.NEGroupCall
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.group.NEGroupConstants
import com.netease.yunxin.kit.call.group.PushConfigProviderForGroup
import com.netease.yunxin.kit.call.group.param.GroupAcceptParam
import com.netease.yunxin.kit.call.group.param.GroupCallParam
import com.netease.yunxin.kit.call.group.param.GroupConfigParam
import com.netease.yunxin.kit.call.group.param.GroupHangupParam
import com.netease.yunxin.kit.call.group.param.GroupInviteParam
import com.netease.yunxin.kit.call.group.param.GroupJoinParam
import com.netease.yunxin.kit.call.group.param.GroupQueryCallInfoParam
import com.netease.yunxin.kit.call.group.param.GroupQueryMembersParam
import com.netease.yunxin.kit.call.group.result.GroupAcceptResult
import com.netease.yunxin.kit.call.group.result.GroupCallResult
import com.netease.yunxin.kit.call.group.result.GroupHangupResult
import com.netease.yunxin.kit.call.group.result.GroupInviteResult
import com.netease.yunxin.kit.call.group.result.GroupJoinResult
import com.netease.yunxin.kit.call.group.result.GroupQueryCallInfoResult
import com.netease.yunxin.kit.call.group.result.GroupQueryMembersResult
import com.netease.yunxin.nertc.ui.utils.CallUILog

/**
 * 群呼管理器单例类
 * 封装所有群呼相关的接口，为UI层提供统一的调用入口
 */
class GroupCallUIManager private constructor() {

    companion object {
        private const val TAG = "GroupCallUIManager"

        @Volatile
        private var INSTANCE: GroupCallUIManager? = null

        /**
         * 获取群呼管理器单例实例
         * @return GroupCallManager实例
         */
        fun getInstance(): GroupCallUIManager {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: GroupCallUIManager().also { INSTANCE = it }
            }
        }
    }

    private val groupCallUIDelegateList = mutableListOf<GroupCallUIDelegate>()

    private val groupCall: NEGroupCall by lazy { NEGroupCall.instance() }

    fun addDelegate(delegate: GroupCallUIDelegate) {
        CallUILog.d(TAG, "addDelegate: $delegate")
        if (!groupCallUIDelegateList.contains(delegate)) {
            groupCallUIDelegateList.add(delegate)
        }
    }

    fun removeDelegate(delegate: GroupCallUIDelegate) {
        CallUILog.d(TAG, "removeDelegate: $delegate")
        groupCallUIDelegateList.remove(delegate)
    }

    /**
     * 初始化群呼功能
     * @param param 初始化参数
     */
    fun init(param: GroupConfigParam) {
        CallUILog.d(TAG, "init: $param")
        groupCall.init(param)
    }

    /**
     * 预初始化群呼功能
     * 为避免离线后在打开应用后不能立即收到离线呼叫邀请
     */
    fun preInit() {
        CallUILog.d(TAG, "preInit")
        groupCall.preInit()
    }

    /**
     * 释放群呼功能
     */
    fun release() {
        CallUILog.d(TAG, "release")
        groupCall.release()
    }

    /**
     * 发起群呼
     * @param param 呼叫参数
     * @param observer 结果回调
     */
    fun groupCall(param: GroupCallParam, observer: NEResultObserver<GroupCallResult>? = null) {
        CallUILog.d(TAG, "groupCall: $param")
        groupCallUIDelegateList.forEach { it.onLocalAction(NEGroupConstants.ActionId.CALL) }
        groupCall.groupCall(param, observer ?: createDefaultObserver("groupCall"))
    }

    /**
     * 拒接/挂断群呼
     * @param param 挂断参数
     * @param observer 结果回调
     */
    fun groupHangup(param: GroupHangupParam, observer: NEResultObserver<GroupHangupResult>? = null) {
        CallUILog.d(TAG, "groupHangup: param=$param")
        groupCallUIDelegateList.forEach { it.onLocalAction(NEGroupConstants.ActionId.HANGUP) }
        groupCall.groupHangup(param, observer ?: createDefaultObserver("groupHangup"))
    }

    /**
     * 接听群呼
     * @param param  接听参数
     * @param observer 结果回调
     */
    fun groupAccept(param: GroupAcceptParam, observer: NEResultObserver<GroupAcceptResult>? = null) {
        CallUILog.d(TAG, "groupAccept: param=$param")
        groupCallUIDelegateList.forEach { it.onLocalAction(NEGroupConstants.ActionId.ACCEPT) }
        groupCall.groupAccept(param, observer ?: createDefaultObserver("groupAccept"))
    }

    /**
     * 邀请成员加入群呼
     * @param param 邀请参数
     * @param observer 结果回调
     */
    fun groupInvite(param: GroupInviteParam, observer: NEResultObserver<GroupInviteResult>? = null) {
        CallUILog.d(TAG, "groupInvite: param=$param")
        groupCallUIDelegateList.forEach { it.onLocalAction(NEGroupConstants.ActionId.INVITE) }
        groupCall.groupInvite(param, observer ?: createDefaultObserver("groupInvite"))
    }

    /**
     * 主动加入群呼
     * @param param 呼叫参数
     * @param observer 结果回调
     */
    fun groupJoin(param: GroupJoinParam, observer: NEResultObserver<GroupJoinResult>? = null) {
        CallUILog.d(TAG, "groupJoin: param=$param")
        groupCallUIDelegateList.forEach { it.onLocalAction(NEGroupConstants.ActionId.JOIN) }
        groupCall.groupJoin(param, observer ?: createDefaultObserver("groupJoin"))
    }

    /**
     * 查询群呼详情
     * @param param 查询参数
     * @param observer 结果回调
     */
    fun groupQueryCallInfo(param: GroupQueryCallInfoParam, observer: NEResultObserver<GroupQueryCallInfoResult>? = null) {
        CallUILog.d(TAG, "groupQueryCallInfo: param=$param")
        groupCall.groupQueryCallInfo(param, observer ?: createDefaultObserver("groupQueryCallInfo"))
    }

    /**
     * 查询群呼成员列表
     * @param callId 呼叫ID
     * @param observer 结果回调
     */
    fun groupQueryMembers(callId: String, observer: NEResultObserver<GroupQueryMembersResult>? = null) {
        CallUILog.d(TAG, "groupQueryMembers: callId=$callId")
        val param = GroupQueryMembersParam(callId)
        groupCall.groupQueryMembers(param, observer ?: createDefaultObserver("groupQueryMembers"))
    }

    /**
     * 获取当前群呼信息
     * @return 当前群呼信息，如果没有则返回null
     */
    fun getCurrentGroupCallInfo(): NEGroupCallInfo? {
        val info = groupCall.currentGroupCallInfo()
        CallUILog.d(TAG, "getCurrentGroupCallInfo: $info")
        return info
    }

    /**
     * 判断是否为群呼组件的自定义通知
     * @param notification 自定义通知
     * @return true表示是群呼组件消息，false表示不是
     */
    fun isMsgFromKit(notification: V2NIMCustomNotification): Boolean {
        val isFromKit = groupCall.ifMsgFromKit(notification)
        CallUILog.d(TAG, "isMsgFromKit: $isFromKit")
        return isFromKit
    }

    /**
     * 设置群呼推送配置
     * @param provider 推送配置提供者
     */
    fun setPushConfigProviderForGroup(provider: PushConfigProviderForGroup) {
        CallUILog.d(TAG, "setPushConfigProviderForGroup: $provider")
        groupCall.setPushConfigProviderForGroup(provider)
    }

    /**
     * 创建默认的结果观察者
     * @param operation 操作名称
     * @return 默认观察者
     */
    private fun <T> createDefaultObserver(operation: String): NEResultObserver<T> {
        return object : NEResultObserver<T> {
            override fun onResult(result: T) {
                CallUILog.d(TAG, "$operation success: $result")
            }
        }
    }
}

interface GroupCallUIDelegate {
    /**
     * 本地操作回调
     *
     * @param actionId 操作id
     */
    fun onLocalAction(actionId: Int)
}
