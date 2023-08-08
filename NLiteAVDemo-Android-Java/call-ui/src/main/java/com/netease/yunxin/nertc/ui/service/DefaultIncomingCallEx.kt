/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.group.NEGroupCallInfo
import com.netease.yunxin.kit.call.p2p.model.NEInviteInfo
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig
import com.netease.yunxin.nertc.ui.CallKitUI
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.base.toCallIntent

open class DefaultIncomingCallEx : IncomingCallEx() {

    protected val notificationManager: NotificationManager by lazy {
        context!!.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    override fun onIncomingCall(invitedInfo: NEGroupCallInfo): Boolean {
        ALog.d(TAG, "onIncomingCall for group, invitedInfo is $invitedInfo.")
        // 直接呼起
        context!!.startActivity(invitedInfo.toCallIntent())
        // 生成通知并提醒
        generateNotificationAndNotifyForGroup(invitedInfo)
        return false
    }

    override fun onIncomingCall(invitedInfo: NEInviteInfo): Boolean {
        ALog.d(TAG, "onIncomingCall, invitedInfo is $invitedInfo.")
        // 直接呼起
        context!!.startActivity(invitedInfo.toCallIntent())
        // 生成通知并提醒
        generateNotificationAndNotify(invitedInfo)
        return false
    }

    override fun onIncomingCallInvalid(invitedInfo: NEGroupCallInfo?) {
        cancelNotification()
    }

    override fun onIncomingCallInvalid(invitedInfo: NEInviteInfo?) {
        cancelNotification()
    }

    protected open fun generateNotificationAndNotifyForGroup(invitedInfo: NEGroupCallInfo) {
        generateNotificationAndNotify(
            invitedInfo.toCallIntent(),
            invitedInfo.callerAccId,
            uiService!!.getNotificationConfig(invitedInfo)
        )
    }

    protected open fun generateNotificationAndNotify(invitedInfo: NEInviteInfo) {
        generateNotificationAndNotify(
            invitedInfo.toCallIntent(),
            invitedInfo.callerAccId,
            uiService!!.getNotificationConfig(invitedInfo)
        )
    }

    private fun generateNotificationAndNotify(
        intent: Intent,
        invitor: String,
        config: CallKitNotificationConfig?
    ) {
        val pendingIntent = PendingIntent.getActivity(
            context,
            INCOMING_CALL_NOTIFY_ID,
            intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        val channelId = config?.channelId ?: INCOMING_CALL_CHANNEL
        val iconId = config?.notificationIconRes ?: R.drawable.nim_actionbar_dark_logo_icon
        val title =
            config?.title ?: context?.getString(R.string.tip_new_incoming_call) ?: "您有新的来电"
        val content = config?.content ?: "$invitor:【网络通话】"

        val builder = NotificationCompat.Builder(context!!, channelId)
            .setContentTitle(title)
            .setContentText(content)
            .setOngoing(true)
            .setContentIntent(pendingIntent)
            .setSmallIcon(iconId)
            .setTimeoutAfter(CallKitUI.options?.timeOutMillisecond ?: 0)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(false)
            .setDefaults(Notification.DEFAULT_LIGHTS)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 用户可见的通道名称
            val notificationChannel =
                NotificationChannel(
                    channelId,
                    context?.getString(R.string.tip_notification_channel_name)
                        ?: "音视频通话邀请通知",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = context?.getString(R.string.tip_notification_channel_description)
                        ?: "用于接收音视频通话邀请时提示。"
                    enableLights(true)
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                    setBypassDnd(true)
                    enableVibration(true)
                }
            notificationManager.createNotificationChannel(notificationChannel)
        }
        notificationManager.notify(INCOMING_CALL_NOTIFY_ID, builder.build())
    }

    /**
     * 跳转到接通页面的intent
     *
     * @return
     */
    protected open fun NEInviteInfo.toCallIntent(): Intent {
        return this.toCallIntent(context!!)
    }

    protected open fun NEGroupCallInfo.toCallIntent(): Intent {
        return this.toCallIntent(context!!)
    }

    protected open fun cancelNotification() {
        try {
            notificationManager.cancel(INCOMING_CALL_NOTIFY_ID)
        } catch (ignored: Exception) {
            ALog.e(TAG, "cancelNotification", ignored)
        }
    }

    override fun tryResumeInvitedUI(invitedInfo: NEInviteInfo): Boolean {
        val intent = invitedInfo.toCallIntent()
        // 直接呼起
        context?.startActivity(intent) ?: run {
            ALog.d("NERTCVideoCallImpl", "start new call In!")
            return false
        }
        ALog.d("NERTCVideoCallImpl", "start new call In!")
        return true
    }

    override fun tryResumeInvitedUI(invitedInfo: NEGroupCallInfo): Boolean {
        val intent = invitedInfo.toCallIntent()
        // 直接呼起
        context?.startActivity(intent) ?: run {
            ALog.d("NERTCVideoCallImpl", "start new group call In!")
            return false
        }
        ALog.d("NERTCVideoCallImpl", "start new group call In!")
        return true
    }

    companion object {
        const val TAG = "DefaultIncomingCallEx"

        const val INCOMING_CALL_CHANNEL = "incoming_call_notification_channel_id_133"

        const val INCOMING_CALL_NOTIFY_ID = 1025
    }
}
