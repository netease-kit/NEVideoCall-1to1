/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
@file:JvmName("TransHelper")

package com.netease.yunxin.nertc.ui.base

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

private val transferMap = HashMap<Int, TransferHelperParam?>()

fun launchTask(
    context: Context,
    requestId: Int,
    action: (Context) -> Unit,
    result: (ResultInfo<Intent>) -> Unit
) {
    transferMap[requestId] = TransferHelperParam(action, result)
    TransferHelperActivity.launch(context, requestId)
}

internal class TransferHelperParam(
    val action: ((Context) -> Unit)? = null,
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
            param.action.invoke(this)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val param = transferMap.remove(requestId)
        param?.result?.invoke(ResultInfo(data, resultCode == RESULT_OK))
        finish()
    }
}
