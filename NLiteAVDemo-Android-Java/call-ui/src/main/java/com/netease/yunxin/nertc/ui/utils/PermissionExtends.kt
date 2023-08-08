/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.netease.yunxin.kit.alog.ALog
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

private const val TAG = "PermissionExtends"

fun Context.isGranted(vararg permissions: String?): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        return true
    }
    return !permissions
        .asSequence()
        .filterNotNull()
        .any {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
}

fun AppCompatActivity.requestPermission(
    onGranted: ((List<String>) -> Unit)? = null,
    onDenied: ((List<String>, List<String>) -> Unit)? = null,
    vararg permissions: String?
) {
    val permissionList = permissions.filterNotNull()
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        onGranted?.invoke(permissionList.toList())
        return
    }
    val launcher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissionMap ->
        ALog.d(TAG, "$permissionMap")
        val grantedList = mutableListOf<String>()
        val deniedList = mutableListOf<String>()
        val deniedForeverList = mutableListOf<String>()
        permissionList.forEach {
            if (permissionMap[it] == true) {
                grantedList.add(it)
            } else if (!shouldShowRequestPermissionRationale(it)) {
                deniedForeverList.add(it)
            } else {
                deniedList.add(it)
            }
        }
        if (grantedList.isNotEmpty()) {
            onGranted?.invoke(grantedList)
        }
        if (deniedForeverList.isNotEmpty() || deniedList.isNotEmpty()) {
            onDenied?.invoke(deniedForeverList, deniedList)
        }
    }
    CoroutineScope(Dispatchers.Main).launch {
        launcher.launch(permissionList.toTypedArray())
    }
}

fun Fragment.requestPermission(
    onGranted: ((List<String>) -> Unit)? = null,
    onDenied: ((List<String>, List<String>) -> Unit)? = null,
    vararg permissions: String?
) {
    val permissionList = permissions.filterNotNull()
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        onGranted?.invoke(permissionList.toList())
        return
    }
    val launcher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissionMap ->
        ALog.d(TAG, "$permissionMap")
        val grantedList = mutableListOf<String>()
        val deniedList = mutableListOf<String>()
        val deniedForeverList = mutableListOf<String>()
        permissionList.forEach {
            if (permissionMap[it] == true) {
                grantedList.add(it)
            } else if (!shouldShowRequestPermissionRationale(it)) {
                deniedForeverList.add(it)
            } else {
                deniedList.add(it)
            }
        }
        if (grantedList.isNotEmpty()) {
            onGranted?.invoke(grantedList)
        }
        if (deniedForeverList.isNotEmpty() || deniedList.isNotEmpty()) {
            onDenied?.invoke(deniedForeverList, deniedList)
        }
    }
    CoroutineScope(Dispatchers.Main).launch {
        launcher.launch(permissionList.toTypedArray())
    }
}
