/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
@file:JvmName("TransHelper")

package com.netease.yunxin.nertc.ui.base

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.netease.yunxin.kit.alog.ALog

private const val TAG = "TransHelper"

const val KEY_PERMISSION_RESULT_GRANTED = "permissions_result_granted"
const val KEY_PERMISSION_RESULT_DENIED = "permissions_result_denied"
const val KEY_PERMISSION_RESULT_DENIED_FOREVER = "permissions_result_denied_forever"

private val transferMap = HashMap<Int, TransferHelperParam?>()

fun launchTask(
    context: Context,
    requestId: Int,
    action: (Activity, Int) -> Unit,
    result: (ResultInfo<Intent>) -> Unit
) {
    transferMap[requestId] = TransferHelperParam(action, result)
    TransferHelperActivity.launch(context, requestId)
}

internal class TransferHelperParam(
    val action: ((Activity, Int) -> Unit)? = null,
    val result: ((ResultInfo<Intent>) -> Unit)? = null
)

class TransferHelperActivity : AppCompatActivity() {
    private val requestId: Int by lazy {
        intent.getIntExtra(PARAM_KEY_FOR_REQUEST_ID, -1)
    }

    companion object {
        const val PARAM_KEY_FOR_REQUEST_ID = "transfer_request_id"

        fun launch(context: Context, requestId: Int) {
            Intent(context, TransferHelperActivity::class.java).apply {
                putExtra(PARAM_KEY_FOR_REQUEST_ID, requestId)
                if (context !is Activity) {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(this)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val param = transferMap[requestId]
        if (param?.action == null) {
            finish()
        } else {
            param.action.invoke(this, requestId)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        try {
            val param = transferMap.remove(requestId)
            param?.result?.invoke(ResultInfo(data, resultCode == RESULT_OK))
        } catch (ignored: Throwable) {
            ALog.e(TAG, "onActivityResult", ignored)
        } finally {
            finish()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        try {
            val param = transferMap.remove(requestId)
            val callbackResult = param?.result ?: run {
                finish()
                return
            }
            permissions.toList()
            val size = permissions.size
            val grantedList = ArrayList<String>()
            val deniedList = ArrayList<String>()
            val deniedForeverList = ArrayList<String>()
            for (index in 0 until size) {
                val permission = permissions[index]
                when (grantResults[index]) {
                    PackageManager.PERMISSION_GRANTED -> grantedList.add(permission)
                    PackageManager.PERMISSION_DENIED -> {
                        if (!ActivityCompat.shouldShowRequestPermissionRationale(
                                this,
                                permission
                            )
                        ) {
                            deniedForeverList.add(permission)
                        } else {
                            deniedList.add(permission)
                        }
                    }
                }
            }

            callbackResult.invoke(
                ResultInfo(
                    Intent()
                        .apply {
                            putStringArrayListExtra(KEY_PERMISSION_RESULT_GRANTED, grantedList)
                            putStringArrayListExtra(KEY_PERMISSION_RESULT_DENIED, deniedList)
                            putStringArrayListExtra(
                                KEY_PERMISSION_RESULT_DENIED_FOREVER,
                                deniedForeverList
                            )
                        },
                    true
                )
            )
        } catch (ignored: Throwable) {
            ALog.e(TAG, "onRequestPermissionsResult", ignored)
        } finally {
            finish()
        }
    }
}
