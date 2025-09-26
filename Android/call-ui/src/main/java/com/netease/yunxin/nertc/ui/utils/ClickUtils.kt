/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

object ClickUtils {

    private const val MIN_CLICK_DELAY_TIME = 500L
    private var lastClickTime: Long = 0

    fun isFastClick(): Boolean {
        val currentTime = System.currentTimeMillis()
        val isFastClick = currentTime - lastClickTime <= MIN_CLICK_DELAY_TIME
        lastClickTime = currentTime
        return isFastClick
    }
}
