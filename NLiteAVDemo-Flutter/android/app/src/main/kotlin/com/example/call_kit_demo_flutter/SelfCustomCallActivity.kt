package com.example.call_kit_demo_flutter

import com.example.call_kit_demo_flutter.fragment.CustomAudioCalleeFragment
import com.example.call_kit_demo_flutter.fragment.CustomAudioCallerFragment
import com.example.call_kit_demo_flutter.fragment.CustomAudioOnTheCallFragment
import com.example.call_kit_demo_flutter.fragment.CustomVideoCalleeFragment
import com.example.call_kit_demo_flutter.fragment.CustomVideoCallerFragment
import com.example.call_kit_demo_flutter.fragment.CustomVideoOnTheCallFragment
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.p2p.P2PCallFragmentActivity
import com.netease.yunxin.nertc.ui.p2p.P2PUIConfig
import com.netease.yunxin.nertc.ui.p2p.fragment.P2PCallFragmentType

class SelfCustomCallActivity : P2PCallFragmentActivity() {
    override fun provideUIConfig(callParam: CallParam?): P2PUIConfig {
        return P2PUIConfig.Builder()
            // 通话页面 ui 上不展示音视频切换按钮
            .showAudio2VideoSwitchOnTheCall(false)
            // 通话页面 ui 上不展示视频音频切换按钮
            .showVideo2AudioSwitchOnTheCall(false)
            // 设置自定义的通话界面 Fragment，主要为了展示呼叫或被叫的背景模糊大图
            .customCallFragmentByKey(P2PCallFragmentType.VIDEO_CALLEE, CustomVideoCalleeFragment())
            .customCallFragmentByKey(P2PCallFragmentType.VIDEO_CALLER, CustomVideoCallerFragment())
            .customCallFragmentByKey(
                P2PCallFragmentType.VIDEO_ON_THE_CALL,
                CustomVideoOnTheCallFragment()
            )
            .customCallFragmentByKey(P2PCallFragmentType.AUDIO_CALLER, CustomAudioCallerFragment())
            .customCallFragmentByKey(P2PCallFragmentType.AUDIO_CALLEE, CustomAudioCalleeFragment())
            .customCallFragmentByKey(
                P2PCallFragmentType.AUDIO_ON_THE_CALL,
                CustomAudioOnTheCallFragment()
            )
            // 开启通话前台服务避免被系统回收资源
            .enableForegroundService(true)
            // 设置通话前台服务的配置，包括通知栏图标、标题、内容
            .foregroundNotificationConfig(
                CallKitNotificationConfig(
                    R.mipmap.ic_launcher,
                    null, "通话中", "正在通话中"
                )
            )
            .build()
    }
}