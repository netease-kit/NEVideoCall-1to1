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
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.databinding.ViewSwitchCallTypeTipDialogBinding

/**
 * 底部弹窗基类，子类需要实现 顶部view，以及底部view 的渲染即可
 */
open class SwitchCallTypeConfirmDialog(
    activity: Activity,
    val onPositive: (Int) -> Unit,
    val onNegative: (Int) -> Unit
) :
    Dialog(
        activity,
        R.style.BottomDialogTheme
    ) {
    private val binding: ViewSwitchCallTypeTipDialogBinding by lazy {
        ViewSwitchCallTypeTipDialogBinding.inflate(LayoutInflater.from(context))
    }

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
        setContentView(binding.root)
        setCanceledOnTouchOutside(false)
        setCancelable(false)
    }

    /**
     * 页面渲染
     */
    protected open fun renderRootView(rootView: View?, type: Int) {
        if (rootView == null) {
            return
        }

        binding.tvTipAccept.setOnClickListener {
            onPositive(type)
            dismiss()
        }

        binding.tvTipReject.setOnClickListener {
            onNegative(type)
            dismiss()
        }
    }

    final override fun show() {
        super.show()
    }

    open fun show(type: Int) {
        if (isShowing) {
            return
        }

        binding.tvTipContent.setText(
            if (type == NECallType.AUDIO) R.string.ui_dialog_switch_call_type_content_audio else R.string.ui_dialog_switch_call_type_content_video
        )
        renderRootView(binding.root, type)
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
}
