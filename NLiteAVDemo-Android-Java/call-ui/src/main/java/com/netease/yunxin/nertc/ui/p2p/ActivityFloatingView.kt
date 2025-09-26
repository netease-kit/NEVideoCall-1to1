/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import com.bumptech.glide.Glide
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.databinding.ActivityFloatingWindowBinding
import com.netease.yunxin.nertc.ui.utils.CallUILog

class ActivityFloatingView : FrameLayout {
    private val logTag = "ActivityFloatingView"
    val binding: ActivityFloatingWindowBinding

    constructor(context: Context) : super(context) {
        binding = inflateAndInit(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        binding = inflateAndInit(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        binding = inflateAndInit(context)
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int, defStyleRes: Int) : super(
        context,
        attrs,
        defStyleAttr,
        defStyleRes
    ) {
        binding = inflateAndInit(context)
    }

    private fun inflateAndInit(context: Context): ActivityFloatingWindowBinding {
        val b = ActivityFloatingWindowBinding.inflate(LayoutInflater.from(context), this, true)
        b.tvRemoteVideoCloseTip.visibility = View.GONE
        b.videoViewSmall.visibility = View.VISIBLE
        return b
    }

    fun changeMuteVideo(isSelf: Boolean, mute: Boolean) {
        binding.tvRemoteVideoCloseTip.visibility = if (mute) View.VISIBLE else View.GONE
        binding.videoViewSmall.visibility = if (mute) View.GONE else View.VISIBLE
        binding.tvRemoteVideoCloseTip.text = if (isSelf) { context.getString(
            R.string.ui_tip_close_camera_by_self
        ) } else { context.getString(R.string.ui_tip_close_camera_by_other) }
    }

    private fun loadImg(url: String?, imageView: ImageView?) {
        imageView ?: run {
            CallUILog.e(logTag, "loadImg imageView is null.")
            return
        }
        val currentContext = context?.applicationContext ?: run {
            CallUILog.e(logTag, "loadImg context is null.")
            return
        }
        Glide.with(currentContext).load(url)
            .error(R.color.black)
            .placeholder(R.color.black)
            .centerCrop()
            .into(imageView)
    }
}
