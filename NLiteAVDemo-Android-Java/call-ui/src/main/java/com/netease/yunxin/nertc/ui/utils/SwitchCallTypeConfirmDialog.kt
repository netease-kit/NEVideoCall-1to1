/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import android.app.Activity
import android.app.Dialog
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import androidx.annotation.LayoutRes
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.R

/**
 * 底部弹窗基类，子类需要实现 顶部view，以及底部view 的渲染即可
 */
class SwitchCallTypeConfirmDialog(
    activity: Activity,
    val onPositive: (Int) -> Unit,
    val onNegative: (Int) -> Unit
) :
    Dialog(
        activity,
        R.style.BottomDialogTheme
    ) {
    private var rootView: View

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val window = window
        if (window != null) {
            window.decorView.setPadding(20.dip2Px(context), 0, 20.dip2Px(context), 0)
            val wlp = window.attributes
            wlp.gravity = Gravity.CENTER
            wlp.width = WindowManager.LayoutParams.MATCH_PARENT
            wlp.height = WindowManager.LayoutParams.WRAP_CONTENT
            window.attributes = wlp
        }
        setContentView(rootView)
        setCanceledOnTouchOutside(false)
        setCancelable(false)
    }

    @LayoutRes
    private fun contentLayoutId(): Int {
        return R.layout.view_switch_call_type_tip_dialog
    }

    /**
     * 页面渲染
     */
    private fun renderRootView(rootView: View?, type: Int) {
        if (rootView == null) {
            return
        }
        rootView.findViewById<View>(R.id.tv_tip_accept)?.run {
            setOnClickListener {
                onPositive(type)
                dismiss()
            }
        }

        rootView.findViewById<View>(R.id.tv_tip_reject)?.run {
            setOnClickListener {
                onNegative(type)
                dismiss()
            }
        }
    }

    fun show(type: Int) {
        if (isShowing) {
            return
        }
        rootView.findViewById<TextView>(R.id.tv_tip_content)
            ?.setText(
                if (type == NECallType.AUDIO) R.string.ui_dialog_switch_call_type_content_audio else R.string.ui_dialog_switch_call_type_content_video
            )
        renderRootView(rootView, type)
        try {
            show()
        } catch (ignored: Throwable) {
            ignored.printStackTrace()
        }
    }

    override fun dismiss() {
        if (!isShowing) {
            return
        }
        try {
            super.dismiss()
        } catch (ignored: Throwable) {
        }
    }

    init {
        rootView = LayoutInflater.from(context).inflate(contentLayoutId(), null)
    }
}
