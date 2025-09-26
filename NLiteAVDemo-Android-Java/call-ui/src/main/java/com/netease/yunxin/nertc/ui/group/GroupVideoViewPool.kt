/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.group

import android.content.Context
import android.view.ViewGroup
import android.widget.LinearLayout
import com.netease.lava.api.IVideoRender
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.lava.nertc.sdk.video.NERtcTextureView
import com.netease.yunxin.kit.alog.ParameterMap
import com.netease.yunxin.nertc.ui.utils.CallUILog
import java.util.*

class GroupVideoViewPool {
    companion object {
        const val TAG = "GroupVideoViewPool"
    }
    private val maxSize = 8
    private val rtcVideoMap = mutableMapOf<Long, NERtcTextureView?>()
    private val queue = LinkedList<NERtcTextureView>()
    private var context: Context? = null

    fun init(context: Context) {
        this.context = context
    }

    fun recycleRtcVideo(rtcUid: Long, forceRecycler: Boolean = false) {
        if (!forceRecycler && maxSize <= rtcVideoMap.size) {
            return
        }
        CallUILog.d(
            "GroupVideoViewPool",
            ParameterMap("recycleRtcVideo").append("rtcUid", rtcUid).toValue()
        )
        val neRtcVideoView = rtcVideoMap[rtcUid]
        removeSelf(neRtcVideoView)
        rtcVideoMap[rtcUid] = null
    }

    fun obtainRtcVideo(rtcUid: Long, isSelf: Boolean): NERtcTextureView {
        CallUILog.i(TAG, "obtainRtcVideo rtcUid is $rtcUid isSelf is $isSelf")
        var videoView = rtcVideoMap[rtcUid]
        videoView = pickVideoView(videoView)
        rtcVideoMap[rtcUid] = videoView
        if (isSelf) {
            NERtcEx.getInstance().setupLocalVideoCanvas(videoView)
        } else {
            NERtcEx.getInstance().setupRemoteVideoCanvas(videoView, rtcUid)
        }
        return videoView
    }

    fun release() {
        queue.clear()
        rtcVideoMap.clear()
        context = null
    }

    private fun removeSelf(neRtcVideoView: NERtcTextureView?) {
        if (neRtcVideoView != null) {
            if (neRtcVideoView.parent != null) {
                (neRtcVideoView.parent as ViewGroup).removeView(neRtcVideoView)
            }
            queue.add(neRtcVideoView)
        }
    }

    private fun pickVideoView(videoView: NERtcTextureView?): NERtcTextureView {
        var videoView1 = videoView
        if (videoView1 == null) {
            videoView1 = queue.poll()
        }
        if (videoView1 == null) {
            videoView1 = NERtcTextureView(context!!).apply {
//                setZOrderMediaOverlay(true)
                layoutParams = ViewGroup.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                )
                setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_FILL)
            }
        }
        if (videoView1.parent != null) {
            (videoView1.parent as ViewGroup).removeView(videoView1)
        }
        return videoView1
    }
}
