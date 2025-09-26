/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import com.netease.yunxin.kit.call.group.NEGroupConstants

class GroupMemberInfo @JvmOverloads constructor(
    val accId: String,
    val name: String = "",
    val avatarUrl: String? = null,
    var enableVideo: Boolean = false,
    var enableAudio: Boolean = true,
    var focus: Boolean = false,
    var state: Int? = NEGroupConstants.UserState.WAITING,
    var uid: Long = 0
) {

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as GroupMemberInfo

        if (accId != other.accId) return false

        return true
    }

    override fun hashCode(): Int {
        return accId.hashCode()
    }

    override fun toString(): String {
        return "GroupMemberInfo(accId='$accId', name='$name', avatarUrl=$avatarUrl, " +
            "enableVideo=$enableVideo, enableAudio=$enableAudio, focus=$focus, state=$state, uid=$uid)"
    }

    fun clone(): GroupMemberInfo =
        GroupMemberInfo(accId, name, avatarUrl, enableVideo, enableAudio, focus, state, uid)
}
