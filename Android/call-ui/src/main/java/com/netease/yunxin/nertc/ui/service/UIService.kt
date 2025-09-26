/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.nertc.ui.service

import android.app.Activity
import android.content.Context
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig

interface UIService {
    /**
     * 获取一对一音频通话时启动的 activity 页面 class
     */
    fun getOneToOneAudioChat(): Class<out Activity>?

    /**
     * 获取一对一视频通话时启动的 activity 页面 class
     */
    fun getOneToOneVideoChat(): Class<out Activity>?

    /**
     * 获取群组通话时启动的 activity 页面 class
     */
    fun getGroupChat(): Class<out Activity>?

    /**
     * 获取呼叫组件产生呼叫推送时的本地图标资源 id
     */
    fun getNotificationConfig(invitedInfo: NEInviteInfo): CallKitNotificationConfig?

    /**
     * 获取呼叫组件产生呼叫推送时的本地图标资源 id
     */
    fun getNotificationConfig(invitedInfo: NEGroupCallInfo): CallKitNotificationConfig?

    /**
     * 群组通话邀请他人时触发联系人的选择列表
     *
     * @param context         上下文
     * @param groupId         群组id
     * @param excludeUserList 列表中已选择用户，不需要进行选择
     * @param observer        联系人选择通过结果通知
     */
    fun startContactSelector(
        context: Context,
        groupId: String?,
        excludeUserList: List<String>?,
        observer: NEResultObserver<List<String>?>?
    )
}
