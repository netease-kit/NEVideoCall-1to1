/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import android.text.TextUtils
import com.netease.nimlib.sdk.NIMClient
import com.netease.nimlib.sdk.RequestCallbackWrapper
import com.netease.nimlib.sdk.uinfo.UserService
import com.netease.nimlib.sdk.uinfo.model.NimUserInfo
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.group.NEGroupConstants

internal class GroupUserInfoFetcher {
    private val userService = NIMClient.getService(UserService::class.java)
    private val localCache: MutableMap<String, GroupMemberInfo> = HashMap()

    fun reset(accId: String) {
        localCache[accId]?.run {
            this.enableAudio = true
            this.enableVideo = false
            this.focus = false
            this.state = NEGroupConstants.UserState.WAITING
        }
    }

    fun getUserInfo(accId: String, observer: NEResultObserver<GroupMemberInfo>?) {
        if (observer == null) {
            return
        }
        if (TextUtils.isEmpty(accId)) {
            observer.onResult(null)
            return
        }
        var userInfo = localCache[accId]
        if (userInfo != null) {
            observer.onResult(userInfo)
            return
        }
        userInfo = userService.getUserInfo(accId)?.toGroupMemberInfo()
        if (userInfo != null) {
            localCache[accId] = userInfo
            observer.onResult(userInfo)
            return
        }
        userService.fetchUserInfo(listOf(accId))
            .setCallback(object : RequestCallbackWrapper<List<NimUserInfo>?>() {
                override fun onResult(
                    code: Int,
                    result: List<NimUserInfo>?,
                    exception: Throwable?
                ) {
                    if (result == null || result.isEmpty()) {
                        observer.onResult(null)
                    } else {
                        val info = result[0]
                        info.toGroupMemberInfo().run {
                            localCache[accId] = this
                            observer.onResult(this)
                        }
                    }
                }
            })
    }

    fun getUserInfoList(
        accIdList: List<String>?,
        observer: NEResultObserver<List<GroupMemberInfo>>?
    ) {
        if (observer == null) {
            return
        }
        if (accIdList == null || accIdList.isEmpty()) {
            observer.onResult(null)
            return
        }
        val resultList: MutableList<GroupMemberInfo> = ArrayList()
        val tempAccIdList: MutableList<String> = ArrayList(accIdList)
        val iterator = tempAccIdList.iterator()
        while (iterator.hasNext()) {
            val accId = iterator.next()
            var userInfo = localCache[accId]
            if (userInfo != null) {
                resultList.add(userInfo)
                iterator.remove()
                continue
            }
            userInfo = userService.getUserInfo(accId)?.toGroupMemberInfo()
            if (userInfo != null) {
                localCache[accId] = userInfo
                resultList.add(userInfo)
                iterator.remove()
            }
        }
        if (tempAccIdList.isEmpty()) {
            observer.onResult(resultList)
            return
        }
        userService.fetchUserInfo(tempAccIdList)
            .setCallback(object : RequestCallbackWrapper<List<NimUserInfo?>?>() {
                override fun onResult(
                    code: Int,
                    result: List<NimUserInfo?>?,
                    exception: Throwable?
                ) {
                    if (result != null && result.isNotEmpty()) {
                        val resultFromServer = mutableListOf<GroupMemberInfo>()
                        for (item in result) {
                            if (item == null) {
                                continue
                            }
                            item.toGroupMemberInfo().run {
                                localCache[item.account] = this
                                resultFromServer.add(this)
                            }
                        }
                        resultList.addAll(resultFromServer)
                    }
                    observer.onResult(resultList)
                }
            })
    }

    private fun NimUserInfo.toGroupMemberInfo(): GroupMemberInfo {
        return GroupMemberInfo(account, name, avatar)
    }
}
