/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p.fragment

import android.view.View.OnClickListener
import com.netease.lava.api.IVideoRender
import com.netease.lava.nertc.sdk.video.NERtcVideoView
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallInfo
import com.netease.yunxin.nertc.nertcvideocall.bean.CommonResult
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.utils.PermissionTipDialog

interface FragmentActionBridge {

    val callParam: CallParam

    val uiConfig: P2PUIConfig?

    val callEngine: NECallEngine

    val isLocalMuteAudio: Boolean

    val isRemoteMuteVideo: Boolean

    val isLocalMuteVideo: Boolean

    val isLocalMuteSpeaker: Boolean

    val isLocalSmallVideo: Boolean

    val isVirtualBlur: Boolean

    fun isSpeakerOn(): Boolean

    fun configTimeTick(config: CallUIOperationsMgr.TimeTickConfig?)

    fun doConfigSpeaker(on: Boolean = !isSpeakerOn())

    fun doMuteAudio(mute: Boolean = !isLocalMuteAudio)

    fun doMuteVideo(mute: Boolean = !isLocalMuteVideo)

    fun doVirtualBlur(enable: Boolean = !isVirtualBlur)

    fun doSwitchCamera()

    fun doCall(
        observer: NEResultObserver<CommonResult<NECallInfo>>? = null
    )

    fun doAccept(observer: NEResultObserver<CommonResult<NECallInfo>>? = null)

    fun doHangup(
        observer: NEResultObserver<CommonResult<Void>>? = null,
        channelId: String? = null,
        extraInfo: String? = null
    )

    fun doSwitchCallType(
        callType: Int, switchCallState: Int, observer: NEResultObserver<CommonResult<Void>>? = null
    )

    fun setupLocalView(
        view: NERtcVideoView?,
        action: ((NERtcVideoView?) -> Unit)? = {
            it?.run {
                setZOrderMediaOverlay(true)
                setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
            }
        }
    )

    fun setupRemoteView(
        view: NERtcVideoView?,
        action: ((NERtcVideoView?) -> Unit)? = {
            it?.run {
                setScalingType(IVideoRender.ScalingType.SCALE_ASPECT_BALANCED)
            }
        }
    )

    fun currentCallState(): Int

    fun showPermissionDialog(clickListener: OnClickListener): PermissionTipDialog

    fun showFloatingWindow()

    fun startVideoPreview()

    fun stopVideoPreview()
}
