/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui

import android.app.Activity
import android.content.Context
import androidx.annotation.DrawableRes
import com.netease.lava.nertc.sdk.NERtcOption
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.group.NEGroupConstants
import com.netease.yunxin.kit.call.group.PushConfigProviderForGroup
import com.netease.yunxin.kit.call.p2p.model.NECallInitRtcMode
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.nertcvideocall.model.CallExtension
import com.netease.yunxin.nertc.nertcvideocall.utils.InfoFilterUtils.subInfo
import com.netease.yunxin.nertc.ui.base.LanguageType
import com.netease.yunxin.nertc.ui.base.SoundHelper
import com.netease.yunxin.nertc.ui.base.UserInfoHelper
import com.netease.yunxin.nertc.ui.group.GroupCallActivity
import com.netease.yunxin.nertc.ui.p2p.P2PCallFragmentActivity
import com.netease.yunxin.nertc.ui.service.CallKitUIBridgeService
import com.netease.yunxin.nertc.ui.service.IncomingCallEx

class CallKitUIOptions constructor(
    val currentUserAccId: String,
    val currentUserRtcUId: Long = 0L,
    val timeOutMillisecond: Long = 30 * 1000L,
    val resumeBGInvitation: Boolean = true,
    val rtcConfig: CallKitUIRtcConfig,
    val activityConfig: CallKitUIActivityConfig,
    val uiHelper: CallKitUIHelper,
    val notificationConfigFetcher: ((NEInviteInfo) -> CallKitNotificationConfig)? = null,
    val notificationConfigFetcherForGroup: ((NEGroupCallInfo) -> CallKitNotificationConfig)? = null,
    val userInfoHelper: UserInfoHelper? = null,
    val incomingCallEx: IncomingCallEx? = null,
    val callKitUIBridgeService: CallKitUIBridgeService? = null,
    val pushConfigProviderForGroup: PushConfigProviderForGroup? = null,
    val callExtension: CallExtension? = null,
    val soundHelper: SoundHelper? = SoundHelper(),
    val enableOrder: Boolean = true,
    val enableAutoJoinWhenCalled: Boolean = false,
    val initRtcMode: Int = NECallInitRtcMode.GLOBAL,
    val joinRtcWhenCall: Boolean = false,
    val audio2Video: Boolean = false,
    val video2Audio: Boolean = false,
    val enableGroup: Boolean = false,
    val language: NECallUILanguage = NECallUILanguage.AUTO,
    var framework: String? = null,
    var channel: String? = null
) {

    class Builder {
        private var currentUserAccId: String = ""
        private var currentUserRtcUId: Long = 0L
        private var timeOutMillisecond: Long = 30 * 1000L
        private var resumeBGInvitation: Boolean = true

        private var rtcAppKey: String = ""
        private var rtcSdkOption: NERtcOption? = null

        private var p2pAudioActivity: Class<out Activity>? = P2PCallFragmentActivity::class.java
        private var p2pVideoActivity: Class<out Activity>? = P2PCallFragmentActivity::class.java
        private var groupActivity: Class<out Activity>? = GroupCallActivity::class.java

        private var userInfoHelper: UserInfoHelper? = null

        private var incomingCallEx: IncomingCallEx? = null

        private var callKitUIBridgeService: CallKitUIBridgeService? = null

        private var pushConfigProviderForGroup: PushConfigProviderForGroup? = null

        private var contactSelector: (
            (context: Context, groupId: String?, excludeUserList: List<String>?, observer: NEResultObserver<List<String>?>?) -> Unit
        )? =
            null

        private var notificationConfigFetcher: ((NEInviteInfo) -> CallKitNotificationConfig)? = null

        private var notificationConfigFetcherForGroup: (
            (NEGroupCallInfo) -> CallKitNotificationConfig
        )? =
            null

        private var callExtension: CallExtension? = null

        private var soundHelper: SoundHelper? = SoundHelper()

        private var enableOrder: Boolean = true

        private var enableAutoJoinWhenCalled: Boolean = false

        private var initRtcMode: Int = NECallInitRtcMode.GLOBAL

        private var rtcSafeMode = NEGroupConstants.RtcSafeMode.MODE_SAFE

        private var enableGroup: Boolean = false

        private var audio2Video: Boolean = false

        private var video2Audio: Boolean = false

        private var joinRtcWhenCall: Boolean = false

        private var language: NECallUILanguage = NECallUILanguage.AUTO

        private var framework: String? = null

        private var channel: String? = null

        fun rtcSdkOption(option: NERtcOption) = apply {
            this.rtcSdkOption = option
        }

        fun timeOutMillisecond(time: Long): Builder = apply {
            this.timeOutMillisecond = time
        }

        fun currentUserAccId(accId: String) = apply {
            this.currentUserAccId = accId
        }

        fun currentUserRtcUId(uId: Long) = apply {
            this.currentUserRtcUId = uId
        }

        fun resumeBGInvitation(resume: Boolean) = apply {
            this.resumeBGInvitation = resume
        }

        fun p2pAudioActivity(clazz: Class<out Activity>) = apply {
            this.p2pAudioActivity = clazz
        }

        fun p2pVideoActivity(clazz: Class<out Activity>) = apply {
            this.p2pVideoActivity = clazz
        }

        fun groupActivity(clazz: Class<out Activity>) = apply {
            this.groupActivity = clazz
        }

        fun notificationConfigFetcher(fetcher: ((NEInviteInfo) -> CallKitNotificationConfig)) =
            apply {
                this.notificationConfigFetcher = fetcher
            }

        fun notificationConfigFetcherForGroup(
            fetcher: ((NEGroupCallInfo) -> CallKitNotificationConfig)
        ) =
            apply {
                this.notificationConfigFetcherForGroup = fetcher
            }

        fun userInfoHelper(userInfoHelper: UserInfoHelper) = apply {
            this.userInfoHelper = userInfoHelper
        }

        fun incomingCallEx(incomingCallEx: IncomingCallEx) = apply {
            this.incomingCallEx = incomingCallEx
        }

        fun callKitUIBridgeService(callKitUIBridgeService: CallKitUIBridgeService) = apply {
            this.callKitUIBridgeService = callKitUIBridgeService
        }

        fun pushConfigProviderForGroup(providerForGroup: PushConfigProviderForGroup) = apply {
            this.pushConfigProviderForGroup = providerForGroup
        }

        fun rtcCallExtension(callExtension: CallExtension) = apply {
            this.callExtension = callExtension
        }

        fun soundHelper(helper: SoundHelper?) = apply {
            this.soundHelper = helper
        }

        fun initRtcMode(mode: Int) = apply {
            this.initRtcMode = mode
        }

        fun enableOrder(enable: Boolean) = apply {
            this.enableOrder = enable
        }

        fun enableGroup(enable: Boolean) = apply {
            this.enableGroup = enable
        }

        fun enableAutoJoinWhenCalled(enable: Boolean) = apply {
            this.enableAutoJoinWhenCalled = enable
        }

        fun contactSelector(
            contactSelector: (
                context: Context,
                groupId: String?,
                excludeUserList: List<String>?,
                observer: NEResultObserver<List<String>?>?
            ) -> Unit
        ) = apply {
            this.contactSelector = contactSelector
        }

        fun rtcSafeMode(safeMode: Int) = apply {
            this.rtcSafeMode = safeMode
        }

        fun rtcAppKey(appKey: String) = apply {
            this.rtcAppKey = appKey
        }

        fun audio2VideoConfirm(confirm: Boolean) = apply {
            this.audio2Video = confirm
        }

        fun video2AudioConfirm(confirm: Boolean) = apply {
            this.video2Audio = confirm
        }

        fun joinRtcWhenCall(joinRtcWhenCall: Boolean) = apply {
            this.joinRtcWhenCall = joinRtcWhenCall
        }

        fun language(language: NECallUILanguage) = apply {
            this.language = language
        }

        fun framework(framework: String) = apply {
            this.framework = framework
        }

        fun channel(channel: String) = apply {
            this.channel = channel
        }

        fun build(): CallKitUIOptions {
            val rtcConfig =
                CallKitUIRtcConfig(rtcAppKey, rtcSdkOption)
            val activityConfig =
                CallKitUIActivityConfig(p2pAudioActivity, p2pVideoActivity, groupActivity)
            val uiHelper = CallKitUIHelper(contactSelector)

            return CallKitUIOptions(
                currentUserAccId = currentUserAccId,
                currentUserRtcUId = currentUserRtcUId,
                timeOutMillisecond = timeOutMillisecond,
                resumeBGInvitation = resumeBGInvitation,
                rtcConfig = rtcConfig,
                activityConfig = activityConfig,
                uiHelper = uiHelper,
                notificationConfigFetcher = notificationConfigFetcher,
                notificationConfigFetcherForGroup = notificationConfigFetcherForGroup,
                userInfoHelper = userInfoHelper,
                incomingCallEx = incomingCallEx,
                callKitUIBridgeService = callKitUIBridgeService,
                pushConfigProviderForGroup = pushConfigProviderForGroup,
                callExtension = callExtension,
                soundHelper = soundHelper,
                enableOrder = enableOrder,
                enableAutoJoinWhenCalled = enableAutoJoinWhenCalled,
                initRtcMode = initRtcMode,
                joinRtcWhenCall = joinRtcWhenCall,
                audio2Video = audio2Video,
                video2Audio = video2Audio,
                enableGroup = enableGroup,
                language = language,
                framework = framework,
                channel = channel
            )
        }
    }

    override fun toString(): String {
        return "CallKitUIOptions(currentUserAccId='$currentUserAccId', currentUserRtcUId=$currentUserRtcUId, timeOutMillisecond=$timeOutMillisecond, resumeBGInvitation=$resumeBGInvitation, rtcConfig=$rtcConfig, activityConfig=$activityConfig, uiHelper=$uiHelper, notificationConfigFetcher=$notificationConfigFetcher, notificationConfigFetcherForGroup=$notificationConfigFetcherForGroup, userInfoHelper=$userInfoHelper, incomingCallEx=$incomingCallEx, callKitUIBridgeService=$callKitUIBridgeService, pushConfigProviderForGroup=$pushConfigProviderForGroup, callExtension=$callExtension, soundHelper=$soundHelper, enableOrder=$enableOrder, enableAutoJoinWhenCalled=$enableAutoJoinWhenCalled, initRtcMode=$initRtcMode, joinRtcWhenCall=$joinRtcWhenCall, audio2Video=$audio2Video, video2Audio=$video2Audio, enableGroup=$enableGroup, language=$language, framework=$framework, channel=$channel)"
    }
}

// rtcAppKey, rtcOption
class CallKitUIRtcConfig(
    val appKey: String,
    val rtcSdkOption: NERtcOption? = null
) {
    override fun toString(): String {
        return "CallKitUIRtcConfig(appKey='${subInfo(appKey)}', rtcSdkOption=$rtcSdkOption)"
    }
}

// p2p audio / video  // group
class CallKitUIActivityConfig(
    val p2pAudioActivity: Class<out Activity>? = null,
    val p2pVideoActivity: Class<out Activity>? = null,
    val groupCallActivity: Class<out Activity>? = null
) {
    override fun toString(): String {
        return "CallKitUIActivityConfig(p2pAudioActivity=$p2pAudioActivity, p2pVideoActivity=$p2pVideoActivity, groupCallActivity=$groupCallActivity)"
    }
}

// account list from group
class CallKitUIHelper(
    val contactSelector: (
        (
            context: Context, groupId: String?, excludeUserList: List<String>?,
            observer: NEResultObserver<List<String>?>?
        ) -> Unit
    )? = null
) {
    override fun toString(): String {
        return "CallKitUIHelper(contactSelector=$contactSelector)"
    }
}

// notification config
class CallKitNotificationConfig @JvmOverloads constructor(
    @DrawableRes val notificationIconRes: Int?,
    val channelId: String? = null,
    val title: CharSequence? = null,
    val content: CharSequence? = null
) {
    override fun toString(): String {
        return "CallKitNotificationConfig(notificationIconRes=$notificationIconRes, channelId=$channelId, title=$title, content=$content)"
    }
}

enum class NECallUILanguage(val language: String) {
    AUTO(LanguageType.LANGUAGE_SYSTEM),
    ZH_HANS(LanguageType.LANGUAGE_ZH_CN),
    EN(LanguageType.LANGUAGE_EN)
}
