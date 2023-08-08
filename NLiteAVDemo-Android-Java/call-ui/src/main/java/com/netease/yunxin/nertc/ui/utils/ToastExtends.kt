/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import android.content.Context
import android.widget.Toast

fun String.toastShort(context: Context?) {
    context ?: return
    Toast.makeText(context, this, Toast.LENGTH_SHORT).show()
}

fun String.toastLong(context: Context?) {
    context ?: return
    Toast.makeText(context, this, Toast.LENGTH_LONG).show()
}
