/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.content.Context

interface UserInfoHelper {

    fun fetchNickname(accId: String, notify: ((String) -> Unit)): Boolean

    fun fetchAvatar(context: Context, accId: String, notify: (String?, Int?) -> Unit): Boolean
}
