/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Process
import androidx.annotation.MainThread
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.alog.ParameterMap
import com.netease.yunxin.kit.call.NEResultObserver
import com.netease.yunxin.kit.call.common.NECallExtensionMgr
import com.netease.yunxin.kit.call.group.NEGroupCall
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.group.NEGroupConstants
import com.netease.yunxin.kit.call.group.param.GroupCallParam
import com.netease.yunxin.kit.call.group.param.GroupConfigParam
import com.netease.yunxin.kit.call.group.param.GroupJoinParam
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.internal.NECallEngineImpl
import com.netease.yunxin.kit.call.p2p.model.NECallConfig
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.kit.call.p2p.model.NESetupConfig
import com.netease.yunxin.nertc.nertcvideocall.utils.CallOrderHelper
import com.netease.yunxin.nertc.ui.base.AVChatSoundPlayer
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.Constants
import com.netease.yunxin.nertc.ui.base.MultiLanguageHelper
import com.netease.yunxin.nertc.ui.base.UserInfoExtensionHelper
import com.netease.yunxin.nertc.ui.p2p.CallUIOperationsMgr
import com.netease.yunxin.nertc.ui.service.CallKitUIBridgeService
import com.netease.yunxin.nertc.ui.service.UIService
import com.netease.yunxin.nertc.ui.service.UIServiceManager
import com.netease.yunxin.nertc.ui.utils.AppForegroundWatcherHelper
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

object CallKitUI {
    private const val TAG = "CallKitUI"

    var init = false
        private set

    var currentUserAccId: String? = null

    var currentUserRtcUid: Long = 0L

    @SuppressLint("StaticFieldLeak")
    private var callKitUIBridgeService: CallKitUIBridgeService? = null

    private val watcher = object : AppForegroundWatcherHelper.Watcher() {
        override fun onForeground() {
            callKitUIBridgeService?.tryResumeInvitedUI()
        }
    }

    private val launchCallPage: (Context, Class<out Activity>, CallParam) -> Unit =
        { context, clazz, param ->
            val intent = Intent(context, clazz).apply {
                putExtra(Constants.PARAM_KEY_CALL, param)
                if (context !is Activity) {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
            }
            context.startActivity(intent)
        }

    @Volatile
    var options: CallKitUIOptions? = null
        private set

    fun baseContext() = callKitUIBridgeService?.context

    @JvmStatic
    @MainThread
    fun preGroupConfig() {
        CoroutineScope(Dispatchers.Main).launch {
            NEGroupCall.instance().preInit()
        }
    }

    @JvmStatic
    @MainThread
    fun preVideoCallConfig(
        appKey: String,
        enableAutoJoinWhenCalled: Boolean,
        accId: String,
        rtcUId: Long
    ) {
        CoroutineScope(Dispatchers.Main).launch {
            (NECallEngine.sharedInstance() as NECallEngineImpl).preInit(
                appKey,
                enableAutoJoinWhenCalled,
                accId,
                rtcUId
            )
        }
    }

    @JvmStatic
    @MainThread
    fun init(context: Context, options: CallKitUIOptions) {
        ALog.dApi(TAG, ParameterMap("init"))
        initInner(context, options)
    }

    private fun initInner(context: Context, options: CallKitUIOptions) {
        ALog.d(TAG, "CallKitUI init start.")
        if (init) {
            ALog.w(TAG, "CallKitUI had init completed, to init again.")
            destroyInner()
        }
        this.options = options
        options.run {
            wrapperUncaughtExceptionHandler()
            this@CallKitUI.currentUserAccId = currentUserAccId
            this@CallKitUI.currentUserRtcUid = currentUserRtcUId
            UserInfoExtensionHelper.userInfoHelper = userInfoHelper
            val uiService = object : UIService {
                override fun getOneToOneAudioChat(): Class<out Activity>? =
                    activityConfig.p2pAudioActivity

                override fun getOneToOneVideoChat(): Class<out Activity>? =
                    activityConfig.p2pVideoActivity

                override fun getGroupChat(): Class<out Activity>? =
                    activityConfig.groupCallActivity

                override fun getNotificationConfig(invitedInfo: NEInviteInfo) =
                    notificationConfigFetcher?.invoke(invitedInfo)

                override fun getNotificationConfig(invitedInfo: NEGroupCallInfo) =
                    notificationConfigFetcherForGroup?.invoke(invitedInfo)

                override fun startContactSelector(
                    context: Context,
                    groupId: String?,
                    excludeUserList: List<String>?,
                    observer: NEResultObserver<List<String>?>?
                ) {
                    uiHelper.contactSelector?.invoke(
                        context,
                        groupId,
                        excludeUserList,
                        observer
                    )
                }
            }
            // 设置话单是否开启
            CallOrderHelper.enableOrder(enableOrder)
            // 保存UIService
            UIServiceManager.getInstance().uiService = uiService
            // 配置切换是否需要确认
            NECallEngine.sharedInstance().callConfig = NECallConfig(true, audio2Video, video2Audio)
            // 配置呼叫声音响应
            AVChatSoundPlayer.setHelper(soundHelper)
            // 设置呼叫服务
            (
                callKitUIBridgeService?.apply {
                    this@CallKitUI.callKitUIBridgeService = this
                } ?: if (incomingCallEx == null) {
                    CallKitUIBridgeService(context.applicationContext)
                } else {
                    CallKitUIBridgeService(context.applicationContext, incomingCallEx)
                }.apply {
                    this@CallKitUI.callKitUIBridgeService = this
                }
                ).apply {
                incomingCallEx.context = context.applicationContext
                incomingCallEx.uiService = uiService
            }
            // 是否需要后台恢复UI
            if (resumeBGInvitation) {
                registerResumeUIActionInner()
            } else {
                unregisterResumeUIActionInner()
            }
            // 设置超时时间
            NECallEngine.sharedInstance().setTimeout(timeOutMillisecond)
            // 配置切换是否需要确认
            NECallEngine.sharedInstance().callConfig = NECallConfig(true, audio2Video, video2Audio)
            // rtc 扩展
            val extension = callExtension ?: NECallExtensionMgr.getInstance().callExtension
            // 组件初始化配置
            val setupConfig = NESetupConfig.Builder(rtcConfig.appKey)
                .currentUserRtcUid(currentUserRtcUId)
                .initRtcMode(initRtcMode)
                .rtcCallExtension(extension)
                .enableAutoJoinSignalChannel(enableAutoJoinWhenCalled)
                .enableJoinRtcWhenCall(joinRtcWhenCall)
                .rtcOption(rtcConfig.rtcSdkOption)
                .framework(framework)
                .channel(channel)
                .build()
            // 初始化
            NECallEngine.sharedInstance().setup(context.applicationContext, setupConfig)

            if (enableGroup) {
                // 设置推送服务
                NEGroupCall.instance().setPushConfigProviderForGroup(pushConfigProviderForGroup)
                // 群组呼叫 初始化
                NEGroupCall.instance().init(
                    GroupConfigParam.Builder()
                        .appKey(rtcConfig.appKey)
                        .rtcCallExtension(extension)
                        .rtcSafeMode(NEGroupConstants.RtcSafeMode.MODE_SAFE)
                        .currentUserAccId(currentUserAccId)
                        .currentUserRtcUid(currentUserRtcUId)
                        .timeout((timeOutMillisecond / 1000L).toInt()).build()
                )
            }
            CallUIOperationsMgr.load(context)
            MultiLanguageHelper.changeLanguage(context, language.language)
            init = true
            ALog.d(TAG, "CallKitUI init completed. Init with options $this.")
        }
    }

    @JvmStatic
    @MainThread
    fun startSingleCall(context: Context, callParam: CallParam) {
        ALog.dApi(
            TAG,
            ParameterMap("startSingleCall").append("context", context)
                .append("callParam", callParam)
        )
        init.checkAndThrow("startSingleCall")
        launchCallPage(
            context,
            if (callParam.callType == NECallType.AUDIO) {
                options!!.activityConfig.p2pAudioActivity!!
            } else {
                options!!.activityConfig.p2pVideoActivity!!
            },
            callParam
        )
    }

    @JvmStatic
    @MainThread
    fun startGroupCall(context: Context, callParam: GroupCallParam) {
        ALog.dApi(
            TAG,
            ParameterMap("startGroupCall").append("context", context)
                .append("callParam", callParam)
        )
        init.checkAndThrow("startGroupCall")
        val intent = Intent(context, options!!.activityConfig.groupCallActivity!!).apply {
            putExtra(Constants.PARAM_KEY_GROUP_CALL, callParam)
            if (context !is Activity) {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
        context.startActivity(intent)
    }

    @JvmStatic
    @MainThread
    fun joinGroupCall(context: Context, param: GroupJoinParam) {
        ALog.dApi(
            TAG,
            ParameterMap("joinGroupCall").append("context", context)
                .append("param", param)
        )
        init.checkAndThrow("startGroupCall")
        val intent = Intent(context, options!!.activityConfig.groupCallActivity!!).apply {
            putExtra(Constants.PARAM_KEY_GROUP_CALL_ID, param.callId)
            if (context !is Activity) {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
        }
        context.startActivity(intent)
    }

    @JvmStatic
    @MainThread
    fun destroy() {
        ALog.dApi(TAG, ParameterMap("destroy"))
        destroyInner()
        CallUIOperationsMgr.unload()
    }

    private fun destroyInner() {
        ALog.d(TAG, "CallKitUI destroy inner.")
        init = false
        UIServiceManager.getInstance().uiService = null
        unregisterResumeUIActionInner()
        callKitUIBridgeService?.destroy()
        callKitUIBridgeService = null
        currentUserAccId = null
        currentUserRtcUid = 0L
        options = null
        AVChatSoundPlayer.release()
        NECallEngine.sharedInstance().destroy()
        if (options?.enableGroup == true) {
            NEGroupCall.instance().release()
        }
        UserInfoExtensionHelper.userInfoHelper = null
        ALog.d(TAG, "CallKitUI destroy inner, completed.")
    }

    @JvmStatic
    @MainThread
    fun registerResumeUIAction() {
        ALog.dApi(TAG, ParameterMap("registerResumeUIAction"))
        init.checkAndThrow("registerResumeUIAction")
        registerResumeUIActionInner()
    }

    @JvmStatic
    @MainThread
    fun unregisterResumeUIAction() {
        ALog.dApi(TAG, ParameterMap("unregisterResumeUIAction"))
        init.checkAndThrow("unregisterResumeUIAction")
        unregisterResumeUIActionInner()
    }

    fun currentVersion(): String = NECallEngineImpl.CURRENT_VERSION

    private fun registerResumeUIActionInner() {
        ALog.d(TAG, "CallKitUI register resume ui action inner.")
        AppForegroundWatcherHelper.addWatcher(watcher)
    }

    private fun unregisterResumeUIActionInner() {
        ALog.d(TAG, "CallKitUI unregister resume ui action inner.")
        AppForegroundWatcherHelper.removeWatcher(watcher)
    }

    private fun Boolean.checkAndThrow(extraMsg: String? = null) {
        if (!this@checkAndThrow) {
            throw IllegalStateException("You must init CallKitUI before using!\n${extraMsg ?: ""}")
        }
    }

    private fun wrapperUncaughtExceptionHandler() {
        ALog.d(TAG, "wrapperUncaughtExceptionHandler")
        val exceptionHandler = Thread.getDefaultUncaughtExceptionHandler()
        if (exceptionHandler is InnerExceptionHandler) {
            return
        }
        Thread.setDefaultUncaughtExceptionHandler(InnerExceptionHandler(exceptionHandler))
    }

    private class InnerExceptionHandler(val exceptionHandler: Thread.UncaughtExceptionHandler?) :
        Thread.UncaughtExceptionHandler {
        override fun uncaughtException(t: Thread, e: Throwable) {
            ALog.e(
                TAG,
                "ThreadName is ${Thread.currentThread().name}, pid is ${Process.myPid()} tid is ${Process.myTid()}.",
                e
            )
            exceptionHandler?.uncaughtException(t, e)
        }
    }
}
