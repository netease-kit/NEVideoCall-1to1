/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.content.Context
import android.widget.ImageView

interface UserInfoHelper {

    fun fetchNickname(accId: String, notify: ((String) -> Unit)): Boolean

    fun fetchNicknameByTeam(accId: String, teamId: String, notify: ((String) -> Unit)): Boolean

    fun loadAvatar(context: Context, accId: String, avatar: ImageView?): Boolean
}
