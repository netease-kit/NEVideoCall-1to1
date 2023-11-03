/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui

import android.content.Context
import com.netease.yunxin.kit.call.p2p.NECallEngine
import com.netease.yunxin.kit.call.p2p.model.NECallPushConfig
import com.netease.yunxin.kit.corekit.XKitService
import com.netease.yunxin.kit.corekit.model.ResultInfo
import com.netease.yunxin.kit.corekit.model.ResultObserver
import com.netease.yunxin.kit.corekit.route.XKitRouter
import com.netease.yunxin.kit.corekit.startup.Initializer
import com.netease.yunxin.nertc.nertcvideocall.model.impl.state.CallState
import com.netease.yunxin.nertc.ui.CallKitUI.startSingleCall
import com.netease.yunxin.nertc.ui.base.CallParam
import com.netease.yunxin.nertc.ui.base.Constants

class CallKitUIService : XKitService {

    override val serviceName: String
        get() = "CallUIKit"

    override val versionName: String
        get() = NECallEngine.getVersion()

    override val appKey: String?
        get() = null

    override fun onMethodCall(method: String, param: Map<String, Any?>?): Any? {
        return null
    }

    override fun create(context: Context): XKitService {
        XKitRouter.registerRouter(
            Constants.PATH_IS_CALL_IDLE,
            XKitRouter.RouterValue(
                Constants.PATH_IS_CALL_IDLE,
                object : XKitRouter.Navigator {
                    override fun navigate(
                        value: Any,
                        params: MutableMap<String, Any?>,
                        observer: ResultObserver<Any?>?
                    ): Boolean {
                        observer?.onResult(
                            ResultInfo(
                                value = NECallEngine.sharedInstance().callInfo.callStatus == CallState.STATE_IDLE,
                                success = true
                            )
                        )
                        return true
                    }
                }
            )
        )

        XKitRouter.registerRouter(
            Constants.PATH_CALL_SINGLE_PAGE,
            XKitRouter.RouterValue(
                Constants.PATH_CALL_SINGLE_PAGE,
                object : XKitRouter.Navigator {
                    override fun navigate(
                        value: Any,
                        params: MutableMap<String, Any?>,
                        observer: ResultObserver<Any?>?
                    ): Boolean {
                        val calledID = params[Constants.KEY_CALLED_ACC_ID] as String
                        val callerID = params[Constants.KEY_CALLER_ACC_ID] as String
                        val callerType = params[Constants.KEY_CALL_TYPE] as Int
                        val pushConfig = params[Constants.KEY_CALL_PUSH_CONFIG] as? NECallPushConfig
                        val extraInfo = params[Constants.KEY_CALL_EXTRA_INFO] as? String
                        val globalExtraCopy =
                            params[Constants.KEY_CALL_GLOBAL_EXTRA_COPY] as? String
                        val rtcChannelName = params[Constants.KEY_CALL_RTC_CHANNEL_NAME] as? String

                        @Suppress("UNCHECKED_CAST")
                        val extrasMap =
                            params[Constants.KEY_CALL_PAGE_EXTRAS] as? MutableMap<String?, Any?>
                        val param = CallParam.Builder()
                            .callType(callerType)
                            .callerAccId(callerID)
                            .calledAccId(calledID).apply {
                                if (extraInfo != null) {
                                    callExtraInfo(extraInfo)
                                }
                                if (globalExtraCopy != null) {
                                    globalExtraCopy(globalExtraCopy)
                                }
                                if (rtcChannelName != null) {
                                    rtcChannelName(rtcChannelName)
                                }
                                if (pushConfig != null) {
                                    pushConfig(pushConfig)
                                }
                                if (extrasMap != null) {
                                    replaceAllExtras(extrasMap)
                                }
                            }
                            .build()
                        val page = params[XKitRouter.ActivityNavigator.PARAM_CONTEXT] as Context
                        startSingleCall(page, param)
                        return true
                    }
                }
            )
        )

        return this
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}
