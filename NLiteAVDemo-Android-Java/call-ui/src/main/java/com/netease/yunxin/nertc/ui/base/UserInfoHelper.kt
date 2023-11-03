/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.content.Context

interface UserInfoHelper {

    /**
     * 用户根据 accId 内容，利用 notify 接口将用户昵称通知组件
     */
    fun fetchNickname(accId: String, notify: ((String) -> Unit)): Boolean

    /**
     * 用户根据 accId 内容，利用 notify 接口个将用户的头像链接通知组件，
     * notify 中的两个字段其中一个为头像的url，另一个为加载头像失败后展示占位的本地资源 id
     */
    fun fetchAvatar(context: Context, accId: String, notify: (String?, Int?) -> Unit): Boolean
}
