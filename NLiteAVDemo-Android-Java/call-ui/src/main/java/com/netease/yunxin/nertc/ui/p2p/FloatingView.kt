/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import android.Manifest.permission.CAMERA
import android.Manifest.permission.RECORD_AUDIO
import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.Toast
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.alog.ParameterMap
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallEngineDelegateAbs
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.loadAvatarByAccId
import com.netease.yunxin.nertc.ui.databinding.ViewFloatingWindowBinding
import com.netease.yunxin.nertc.ui.utils.dip2Px
import com.netease.yunxin.nertc.ui.utils.formatSecondTime
import com.netease.yunxin.nertc.ui.utils.isGranted
import com.netease.yunxin.nertc.ui.utils.requestPermission

class FloatingView(context: Context) : FrameLayout(context), IFloatingView {
    private val logTag = "FloatingView"
    private val binding by lazy {
        ViewFloatingWindowBinding.inflate(LayoutInflater.from(context), this, true)
    }
    private val delegate = object : NECallEngineDelegateAbs() {
        override fun onVideoAvailable(userId: String?, available: Boolean) {
            if (available) {
                binding.videoViewSmall.visibility = View.VISIBLE
                CallUIOperationsMgr.setupRemoteView(binding.videoViewSmall)
            } else {
                binding.videoViewSmall.visibility = View.GONE
            }
        }

        override fun onVideoMuted(userId: String?, mute: Boolean) {
            if (!mute) {
                binding.videoViewSmall.visibility = View.VISIBLE
                CallUIOperationsMgr.setupRemoteView(binding.videoViewSmall)
            } else {
                binding.videoViewSmall.visibility = View.GONE
            }
        }
    }

    override fun toInit() {
        NECallEngine.sharedInstance().addCallDelegate(delegate)
        CallUIOperationsMgr.configTimeTick(
            CallUIOperationsMgr.TimeTickConfig(onTimeTick = { timestamp: Long ->
                postCountDownTxt(timestamp.formatSecondTime())
            })
        )
        CallUIFloatingWindowMgr.registerFullScreenActionForView(context, this)
    }

    override fun transToAudioUI() {
        ALog.dApi(logTag, ParameterMap("transToAudioUI"))
        val action = { _: Any? ->
            binding.floatAudioGroup.visibility = View.VISIBLE
            binding.videoViewSmall.visibility = View.GONE
            binding.ivAvatar.visibility = View.GONE
            binding.videoBg.visibility = View.GONE
            if (CallUIOperationsMgr.currentCallState() == CallState.STATE_CALL_OUT) {
                binding.tvAudioTip.setText(R.string.ui_floating_window_audio_call)
            } else {
                binding.tvAudioTip.text = "--:--"
            }
            binding.root.radius = 6.dip2Px(context).toFloat()
        }
        if (context.isGranted(RECORD_AUDIO)) {
            action.invoke(null)
        } else {
            handPermissionRequest(listOf(RECORD_AUDIO), null, action)
        }
    }

    override fun transToVideoUI() {
        ALog.dApi(logTag, ParameterMap("transToVideoUI"))
        val action = { needToEnableLocalVideo: Boolean ->
            if (needToEnableLocalVideo) {
                NECallEngine.sharedInstance().enableLocalVideo(true)
            }
            binding.floatAudioGroup.visibility = View.GONE
            binding.ivAvatar.visibility = View.VISIBLE
            binding.videoBg.visibility = View.VISIBLE
            if (CallUIOperationsMgr.currentCallState() == CallState.STATE_DIALOG) {
                val isVideoing = !CallUIOperationsMgr.callInfoWithUIState.isRemoteMuteVideo
                if (isVideoing) {
                    binding.videoViewSmall.visibility = View.VISIBLE
                    CallUIOperationsMgr.setupRemoteView(binding.videoViewSmall)
                } else {
                    binding.videoViewSmall.visibility = View.GONE
                }
            } else {
                binding.videoViewSmall.visibility = View.VISIBLE
                CallUIOperationsMgr.setupLocalView(binding.videoViewSmall)
                CallUIOperationsMgr.startVideoPreview()
            }
            CallUIOperationsMgr.callInfoWithUIState.callParam.otherAccId
                ?.loadAvatarByAccId(context, binding.ivAvatar, enableTextDefaultAvatar = false)
            binding.root.radius = 0f
        }
        if (context.isGranted(RECORD_AUDIO, CAMERA)) {
            action.invoke(false)
        } else {
            handPermissionRequest(listOf(RECORD_AUDIO, CAMERA), true, action)
        }
    }

    override fun toDestroy(isFinished: Boolean) {
        CallUIOperationsMgr.configTimeTick(null)
        if (isFinished) {
            CallUIOperationsMgr.stopVideoPreview()
        }
        NECallEngine.sharedInstance().removeCallDelegate(delegate)
    }

    /**
     * 处理权限申请逻辑
     */
    private fun <T> handPermissionRequest(
        permissionList: List<String>,
        param: T,
        action: (T) -> Unit
    ) {
        context.requestPermission(
            {
                action.invoke(param)
            },
            { _, _ ->
                Toast.makeText(
                    context,
                    R.string.ui_dialog_permission_content,
                    Toast.LENGTH_LONG
                ).show()
                CallUIOperationsMgr.doHangup(null)
            },
            permissions = permissionList.toTypedArray()
        )
    }

    private fun postCountDownTxt(countDown: String) {
        post {
            if (binding.floatAudioGroup.visibility == View.VISIBLE) {
                binding.tvAudioTip.text = countDown
            }
        }
    }
}
