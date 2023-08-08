/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

import android.view.View
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig
import com.netease.yunxin.nertc.ui.base.Constants.CLOSE_TYPE_COMPAT
import com.netease.yunxin.nertc.ui.base.Constants.CLOSE_TYPE_DISABLE
import com.netease.yunxin.nertc.ui.base.Constants.CLOSE_TYPE_MUTE
import com.netease.yunxin.nertc.ui.p2p.fragment.BaseP2pCallFragment

class P2PUIConfig constructor(
    /**
     * 是否展示通话中音频转视频按钮，默认 true
     */
    val showAudio2VideoSwitchOnTheCall: Boolean = true,
    /**
     * 是否展示通话中视频转音频按钮，默认 true
     */
    val showVideo2AudioSwitchOnTheCall: Boolean = true,
    /**
     * 本端用户关闭摄像头时的图像展示
     */
    val closeVideoLocalUrl: String? = null, // TODO:
    /**
     * 本端用户关闭摄像头时的文本提示
     */
    val closeVideoLocalTip: CharSequence? = null, // TODO:
    /**
     * 对端用户关闭摄像头时的本端的图像展示
     */
    val closeVideoRemoteUrl: String? = null, // TODO:
    /**
     * 对端用户关闭摄像头时的本端文本提示
     */
    val closeVideoRemoteTip: CharSequence? = null, // TODO:
    /**
     * 关闭视频模式，默认 [CLOSE_TYPE_MUTE]，也支持 [CLOSE_TYPE_DISABLE]，[CLOSE_TYPE_COMPAT]
     */
    val closeVideoType: Int = CLOSE_TYPE_MUTE,
    /**
     * 是否支持通话中大小画面点击切换，默认 true
     */
    val enableCanvasSwitch: Boolean = true, // TODO:
    /**
     * 通话中页面支持覆盖的view
     */
    val overlayViewOnTheCall: View? = null, // TODO:
    /**
     * 当没有头像时是否展示文字头像，默认 true
     */
    val enableTextDefaultAvatar: Boolean = true,
    /**
     * 是否通话中开启前台服务，默认 false
     */
    val enableForegroundService: Boolean = false,
    /**
     * 通话中前台服务绑定的通知配置（图标，标题，内容，以及通道 id）
     */
    val foregroundNotificationConfig: CallKitNotificationConfig? = null,
    /**
     * 自定义通话中 fragment 页面
     */
    val customCallFragmentMap: Map<Int, BaseP2pCallFragment>? = null
) {

    override fun toString(): String {
        return "P2PUIConfig(showAudio2VideoSwitchOnTheCall=$showAudio2VideoSwitchOnTheCall, showVideo2AudioSwitchOnTheCall=$showVideo2AudioSwitchOnTheCall, closeVideoLocalUrl=$closeVideoLocalUrl, closeVideoLocalTip=$closeVideoLocalTip, closeVideoRemoteUrl=$closeVideoRemoteUrl, closeVideoRemoteTip=$closeVideoRemoteTip, closeVideoType=$closeVideoType, enableCanvasSwitch=$enableCanvasSwitch, overlayViewOnTheCall=$overlayViewOnTheCall, enableTextDefaultAvatar=$enableTextDefaultAvatar, enableForegroundService=$enableForegroundService, foregroundNotificationConfig=$foregroundNotificationConfig, customCallFragmentMap=$customCallFragmentMap)"
    }

    class Builder {
        private var showAudio2VideoSwitchOnTheCall: Boolean = true
        private var showVideo2AudioSwitchOnTheCall: Boolean = true
        private var closeVideoLocalUrl: String? = null
        private var closeVideoLocalTip: CharSequence? = null
        private var closeVideoRemoteUrl: String? = null
        private var closeVideoRemoteTip: CharSequence? = null
        private var closeVideoType: Int = CLOSE_TYPE_MUTE
        private var enableCanvasSwitch: Boolean = true
        private var overlayViewOnTheCall: View? = null
        private var enableTextDefaultAvatar: Boolean = true
        private var enableForegroundService: Boolean = false
        private var foregroundNotificationConfig: CallKitNotificationConfig? = null
        private var customCallFragmentMap: MutableMap<Int, BaseP2pCallFragment> = mutableMapOf()

        fun showAudio2VideoSwitchOnTheCall(enable: Boolean) =
            apply { this.showAudio2VideoSwitchOnTheCall = enable }

        fun showVideo2AudioSwitchOnTheCall(enable: Boolean) =
            apply { this.showVideo2AudioSwitchOnTheCall = enable }

        fun closeVideoLocalUrl(url: String?) = apply { this.closeVideoLocalUrl = url }

        fun closeVideoLocalTip(tip: CharSequence?) = apply { this.closeVideoLocalTip = tip }

        fun closeVideoRemoteUrl(url: String?) = apply { this.closeVideoRemoteUrl = url }

        fun closeVideoRemoteTip(tip: CharSequence?) = apply { this.closeVideoRemoteTip = tip }

        fun closeVideoType(type: Int) = apply { this.closeVideoType = type }

        fun enableCanvasSwitch(enable: Boolean) = apply { this.enableCanvasSwitch = enable }

        fun overlayViewOnTheCall(view: View?) = apply { this.overlayViewOnTheCall = view }

        fun enableTextDefaultAvatar(enable: Boolean) =
            apply { this.enableTextDefaultAvatar = enable }

        fun enableForegroundService(enable: Boolean) =
            apply { this.enableForegroundService = enable }

        fun foregroundNotificationConfig(config: CallKitNotificationConfig) =
            apply { this.foregroundNotificationConfig = config }

        fun customCallFragmentByKey(key: Int, fragment: BaseP2pCallFragment) =
            apply { customCallFragmentMap[key] = fragment }

        fun build(): P2PUIConfig {
            return P2PUIConfig(
                showAudio2VideoSwitchOnTheCall,
                showVideo2AudioSwitchOnTheCall,
                closeVideoLocalUrl,
                closeVideoLocalTip,
                closeVideoRemoteUrl,
                closeVideoRemoteTip,
                closeVideoType,
                enableCanvasSwitch,
                overlayViewOnTheCall,
                enableTextDefaultAvatar,
                enableForegroundService,
                foregroundNotificationConfig,
                customCallFragmentMap
            )
        }
    }
}
