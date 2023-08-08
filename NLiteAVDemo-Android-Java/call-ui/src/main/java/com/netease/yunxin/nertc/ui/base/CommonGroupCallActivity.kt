/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.base

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.TextUtils
import android.view.Window
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import com.netease.lava.nertc.sdk.NERtcEx
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.alog.ParameterMap
import com.netease.yunxin.kit.call.group.GroupCallHangupEvent
import com.netease.yunxin.kit.call.group.GroupCallMember
import com.netease.yunxin.kit.call.group.NEGroupCall
import com.netease.yunxin.kit.call.group.NEGroupCallActionObserver
import com.netease.yunxin.kit.call.group.NEGroupCallActionObserverForAll
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.group.param.GroupCallParam
import com.netease.yunxin.kit.call.group.param.GroupHangupParam
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackExTemp
import com.netease.yunxin.nertc.nertcvideocall.model.impl.NERtcCallbackProxyMgr
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.base.Constants.PARAM_KEY_GROUP_CALL
import com.netease.yunxin.nertc.ui.base.Constants.PARAM_KEY_GROUP_CALL_ID
import com.netease.yunxin.nertc.ui.service.DefaultIncomingCallEx

abstract class CommonGroupCallActivity : AppCompatActivity() {
    private val tag = "CommonGroupCallActivity"

    protected var callInfo: NEGroupCallInfo? = null
    protected var callParam: GroupCallParam? = null
    protected var callId: String? = null
    protected var currentUserAccId: String = ""

    private val callActionObserver: NEGroupCallActionObserver =
        object : NEGroupCallActionObserverForAll() {

            override fun onMemberChanged(callId: String, userList: MutableList<GroupCallMember>) {
                ALog.d(
                    tag,
                    ParameterMap("onMemberChanged")
                        .append("callId", callId)
                        .append("userList", userList)
                        .toValue()
                )
                super.onMemberChanged(callId, userList)
                this@CommonGroupCallActivity.onMemberChanged(callId, userList)
            }

            override fun onMemberChangedForAll(callId: String, userList: List<GroupCallMember>) {
                ALog.d(
                    tag,
                    ParameterMap("onMemberChangedForAll")
                        .append("callId", callId)
                        .append("userList", userList)
                        .toValue()
                )
                this@CommonGroupCallActivity.onMemberChangedForAll(callId, userList)
            }

            override fun onGroupCallHangup(hangupEvent: GroupCallHangupEvent) {
                ALog.d(
                    tag,
                    ParameterMap("onGroupCallHangup")
                        .append("hangupEvent", hangupEvent)
                        .toValue()
                )
                this@CommonGroupCallActivity.onGroupCallHangup(hangupEvent)
            }
        }

    private val rtcCallback = object : NERtcCallbackExTemp() {

        override fun onJoinChannel(i: Int, l: Long, l1: Long, l2: Long) {
            ALog.d(
                tag,
                ParameterMap("onJoinChannel")
                    .append("result", i)
                    .append("channelId", l)
                    .append("time", l1)
                    .append("uid", l2)
                    .toValue()
            )
            this@CommonGroupCallActivity.onJoinChannel(i, l, l1, l2)
        }

        override fun onUserVideoStart(uid: Long, maxProfile: Int) {
            ALog.d(
                tag,
                ParameterMap("onUserVideoStart")
                    .append("uid", uid)
                    .append("maxProfile", maxProfile)
                    .toValue()
            )
            this@CommonGroupCallActivity.onUserVideoStart(uid, maxProfile)
        }

        override fun onUserVideoMute(uid: Long, mute: Boolean) {
            ALog.d(
                tag,
                ParameterMap("onUserVideoMute")
                    .append("uid", uid)
                    .append("mute", mute)
                    .toValue()
            )
            this@CommonGroupCallActivity.onUserVideoMute(uid, mute)
        }

        override fun onUserVideoStop(uid: Long) {
            ALog.d(
                tag,
                ParameterMap("onUserVideoStop")
                    .append("uid", uid)
                    .toValue()
            )
            this@CommonGroupCallActivity.onUserVideoStop(uid)
        }

        override fun onVideoDeviceStageChange(deviceState: Int) {
            ALog.d(
                tag,
                ParameterMap("onVideoDeviceStageChange")
                    .append("deviceState", deviceState)
                    .toValue()
            )
            this@CommonGroupCallActivity.onVideoDeviceStageChange(deviceState)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ALog.d(
            tag,
            ParameterMap("onCreate")
                .append("savedInstanceState", savedInstanceState)
                .toValue()
        )
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        cancelNotification()
        if (provideLayoutId() > 0) {
            setContentView(provideLayoutId())
        }

        intent?.run {
            // 初始化基本数据
            prepareData(this)
        }
        // 初始数据检查
        checkData()
        NEGroupCall.instance().configGroupActionObserver(callActionObserver, true)
        NERtcCallbackProxyMgr.getInstance().addCallback(rtcCallback)
        doOnCreate()
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        ALog.d(
            tag,
            ParameterMap("onNewIntent")
                .append("intent", intent)
                .toValue()
        )
        intent?.run {
            prepareData(this)
        }
        checkData()
        doOnCreate()
    }

    protected open fun provideLayoutId(): Int = -1

    protected open fun prepareData(intent: Intent) {
        callInfo = NEGroupCall.instance().currentGroupCallInfo()
        callParam =
            intent.getSerializableExtra(PARAM_KEY_GROUP_CALL) as? GroupCallParam
        callId = intent.getStringExtra(PARAM_KEY_GROUP_CALL_ID)
        currentUserAccId = CallKitUI.currentUserAccId!!
        ALog.d(
            tag,
            ParameterMap("prepareData")
                .append("callInfo", callInfo)
                .append("callParam", callParam)
                .append("callId", callId)
                .append("currentUserAccId", currentUserAccId)
                .toValue()
        )
    }

    protected open fun checkData() {
        val pass =
            !TextUtils.isEmpty(currentUserAccId) && (
                callInfo != null || callParam != null || !TextUtils.isEmpty(
                    callId
                )
                )
        if (!pass) {
            ALog.e(
                tag,
                "checkData failed, currentUserAccId-$currentUserAccId can't be null" +
                    " and callInfo-$callInfo, callParam-$callParam, callId-$callId can't be null together. "
            )
            finish()
        }
    }

    protected open fun doOnCreate() {
        val tempCallInfo = NEGroupCall.instance().currentGroupCallInfo()
        callInfo?.run {
            if (tempCallInfo == null || !TextUtils.equals(callId, tempCallInfo.callId)) {
                ALog.w(
                    tag,
                    "finish when current callInfo was invalid. current call info is $tempCallInfo, invited call info is $this."
                )
                finish()
            }
        }
    }

    override fun onPause() {
        super.onPause()
        if (isFinishing) {
            NEGroupCall.instance().configGroupActionObserver(callActionObserver, false)
            NERtcCallbackProxyMgr.getInstance().removeCallback(rtcCallback)
            if (callInfo != null) {
                NEGroupCall.instance().groupHangup(GroupHangupParam(callInfo!!.callId), null)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        NEGroupCall.instance().configGroupActionObserver(callActionObserver, false)
        NERtcCallbackProxyMgr.getInstance().removeCallback(rtcCallback)
        if (callInfo != null) {
            NEGroupCall.instance().groupHangup(GroupHangupParam(callInfo!!.callId), null)
        }
    }

    protected open fun onMemberChanged(callId: String, userList: MutableList<GroupCallMember>) {
    }

    protected open fun onMemberChangedForAll(callId: String, userList: List<GroupCallMember>) {
    }

    protected open fun onGroupCallHangup(hangupEvent: GroupCallHangupEvent) {
        if (callInfo == null || TextUtils.equals(hangupEvent.callId, callInfo!!.callId)) {
            callInfo = null
            NERtcEx.getInstance().enableLocalVideo(false)
            NERtcEx.getInstance().muteLocalVideoStream(true)
            finish()
        }
    }

    protected open fun onJoinChannel(result: Int, channelId: Long, time: Long, uid: Long) {
    }

    protected open fun onUserVideoStart(uid: Long, maxProfile: Int) {
    }

    protected open fun onUserVideoStop(uid: Long) {
    }

    protected open fun onUserVideoMute(uid: Long, mute: Boolean) {
    }

    protected open fun onVideoDeviceStageChange(deviceState: Int) {
    }

    protected open fun cancelNotification() {
        try {
            (getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager)
                ?.cancel(DefaultIncomingCallEx.INCOMING_CALL_NOTIFY_ID)
        } catch (exception: Exception) {
            ALog.e(tag, "group call cancel notification", exception)
        }
    }
}
