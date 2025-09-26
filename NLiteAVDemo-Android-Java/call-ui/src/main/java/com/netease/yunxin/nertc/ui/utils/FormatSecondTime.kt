/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import java.util.Locale

fun Long.formatSecondTime(): String {
    if (this <= 0) {
        return "00:00"
    }

    val s = (this % 60).toInt()
    val m = ((this % 3600) / 60).toInt()
    val h = ((this % 360000) / 3600).toInt()
    return when {
        h > 0 -> {
            String.format(Locale.CHINA, "%02d:%02d:%02d", h, m, s)
        }
        else -> {
            String.format(Locale.CHINA, "%02d:%02d", m, s)
        }
    }
}
