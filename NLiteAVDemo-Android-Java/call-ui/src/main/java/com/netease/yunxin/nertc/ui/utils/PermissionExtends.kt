/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.ui.base.KEY_PERMISSION_RESULT_DENIED
import com.netease.yunxin.nertc.ui.base.KEY_PERMISSION_RESULT_DENIED_FOREVER
import com.netease.yunxin.nertc.ui.base.KEY_PERMISSION_RESULT_GRANTED
import com.netease.yunxin.nertc.ui.base.launchTask
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

private const val TAG = "PermissionExtends"

private const val REQUEST_CODE_PERMISSION = 21302

fun Context.isGranted(vararg permissions: String?): Boolean {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || permissions.isEmpty()) {
        return true
    }
    return !permissions
        .asSequence()
        .filterNotNull()
        .any {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
}

fun Context.requestPermission(
    onGranted: ((List<String>) -> Unit)? = null,
    onDenied: ((List<String>, List<String>) -> Unit)? = null,
    vararg permissions: String?
) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        onGranted?.invoke(permissions.filterNotNull())
        return
    }
    launchTask(
        this,
        REQUEST_CODE_PERMISSION,
        { activity: Activity?, _: Int? ->
            ActivityCompat.requestPermissions(
                activity!!,
                permissions,
                REQUEST_CODE_PERMISSION
            )
        }
    ) { intentResultInfo ->
        val intent: Intent? = intentResultInfo.value
        if (intent == null) {
            ALog.e(TAG, "requestPermission, intent is null")
            return@launchTask
        }
        val grantedList =
            intent.getStringArrayListExtra(KEY_PERMISSION_RESULT_GRANTED)
        if (!grantedList.isNullOrEmpty()) {
            onGranted?.invoke(grantedList)
        }
        val deniedList: List<String>? =
            intent.getStringArrayListExtra(KEY_PERMISSION_RESULT_DENIED)
        val deniedForeverList: List<String>? =
            intent.getStringArrayListExtra(KEY_PERMISSION_RESULT_DENIED_FOREVER)
        if (!deniedList.isNullOrEmpty() ||
            !deniedForeverList.isNullOrEmpty()
        ) {
            onDenied?.invoke(deniedList ?: emptyList(), deniedForeverList ?: emptyList())
        }
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

fun Fragment.registerPermissionRequesterEx(): PermissionRequester {
    val permissionRequester = PermissionRequester()

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        return permissionRequester
    }
    permissionRequester.launcher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissionMap ->
        ALog.d(TAG, "$permissionMap")
        permissionRequester.handlePermissionResult(permissionMap)
    }
    permissionRequester.shouldShowRequestPermissionRationale = {
        shouldShowRequestPermissionRationale(it)
    }
    return permissionRequester
}

fun AppCompatActivity.registerPermissionRequesterEx(): PermissionRequester {
    val permissionRequester = PermissionRequester()

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        return permissionRequester
    }
    permissionRequester.launcher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissionMap ->
        ALog.d(TAG, "$permissionMap")
        permissionRequester.handlePermissionResult(permissionMap)
    }
    permissionRequester.shouldShowRequestPermissionRationale = {
        shouldShowRequestPermissionRationale(it)
    }
    return permissionRequester
}

class PermissionRequester {
    internal var launcher: ActivityResultLauncher<Array<String>>? = null
    internal var shouldShowRequestPermissionRationale: (String) -> Boolean = { true }
    private var onGranted: ((List<String>) -> Unit)? = null
    private var onDenied: ((List<String>, List<String>) -> Unit)? = null
    private var permissionList: List<String> = emptyList()

    internal fun handlePermissionResult(permissionMap: Map<String, Boolean>) {
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

    fun request(
        permissionList: List<String>,
        onGranted: ((List<String>) -> Unit)? = null,
        onDenied: ((List<String>, List<String>) -> Unit)? = null
    ) {
        CoroutineScope(Dispatchers.Main).launch {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || permissionList.isEmpty()) {
                onGranted?.invoke(permissionList)
                return@launch
            }
            this@PermissionRequester.onGranted = onGranted
            this@PermissionRequester.onDenied = onDenied
            this@PermissionRequester.permissionList = permissionList
            launcher?.launch(permissionList.toTypedArray())
        }
    }
}
