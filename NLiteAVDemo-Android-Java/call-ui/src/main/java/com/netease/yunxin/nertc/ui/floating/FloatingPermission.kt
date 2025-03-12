/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.floating

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.netease.yunxin.kit.alog.ALog

/**
 * 浮窗权限请求，以及检测
 */
object FloatingPermission {
    private const val TAG = "FloatPermission"

    fun isFloatPermissionValid(context: Context): Boolean {
        // Android 6.0 以下无需申请权限
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // 判断是否拥有悬浮窗权限，无则跳转悬浮窗权限授权页面
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    /**
     * 请求浮窗权限
     */
    fun requireFloatPermission(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return
        }
        try {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            intent.data = Uri.parse("package:" + context.packageName)
            if (context !is Activity) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            ALog.e(TAG, "requestFloatWindowPermission Exception", e)
        }
    }
}
