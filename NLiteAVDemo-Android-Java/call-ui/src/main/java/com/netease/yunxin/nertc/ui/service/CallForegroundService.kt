/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig
import com.netease.yunxin.nertc.ui.R
import java.util.UUID

open class CallForegroundService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        ALog.d(TAG, "onCreate:$serviceId,$isRunning")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        ALog.d(TAG, "onStartCommand:$isRunning")
        isRunning = true
        val tempIntent = intent ?: return super.onStartCommand(null, flags, startId)
        serviceId = tempIntent.getStringExtra(KEY_SERVICE_ID)
        ALog.d(TAG, "onStartCommand:$serviceId")
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return super.onStartCommand(intent, flags, startId)
        }

        // 获取当前通道 id
        val channelId = notificationConfig?.channelId ?: CALL_FOREGROUND_NOTIFICATION_CHANNEL_ID

        // 创建提示通道
        val notificationChannel =
            NotificationChannel(
                channelId,
                getString(R.string.tip_notification_other_channel_name),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.tip_notification_other_channel_description)
                enableLights(false)
                setBypassDnd(true)
                enableVibration(false)
            }
        val notificationManager = this@CallForegroundService.getSystemService(
            Context.NOTIFICATION_SERVICE
        ) as NotificationManager
        notificationManager.createNotificationChannel(notificationChannel)

        // 构建notification展示的 pendingIntent
        val pendingIntent = PendingIntent.getActivity(
            this@CallForegroundService,
            DefaultIncomingCallEx.INCOMING_CALL_NOTIFY_ID,
            intent.getParcelableExtra(KEY_PENDING_INTENT),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        // 构建 notification
        val notification = NotificationCompat.Builder(this@CallForegroundService, channelId)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setContentText(
                notificationConfig?.content
                    ?: getString(R.string.tip_notification_foreground_content_info)
            )
            .setAutoCancel(false)
            .setContentTitle(notificationConfig?.title ?: "")
            .setSmallIcon(
                notificationConfig?.notificationIconRes
                    ?: R.drawable.nim_actionbar_dark_logo_icon
            )
            .build()

        // 开始前台服务
        startForeground(CALL_FOREGROUND_NOTIFICATION_ID, notification)
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onDestroy() {
        super.onDestroy()
        ALog.d(TAG, "onDestroy:$serviceId")
        isRunning = false
        serviceId = null
    }

    companion object {
        const val CALL_FOREGROUND_NOTIFICATION_CHANNEL_ID =
            "call_foreground_notification_channel_id"

        const val CALL_FOREGROUND_NOTIFICATION_ID = 1026

        private const val TAG = "CallForegroundService"

        private const val KEY_PENDING_INTENT = "call_pendingIntent"

        private const val KEY_SERVICE_ID = "call_foreground_serviceId"

        private var serviceId: String? = null

        private var notificationConfig: CallKitNotificationConfig? = null

        @JvmStatic
        var isRunning: Boolean = false
            private set

        @JvmStatic
        @JvmOverloads
        fun launchForegroundService(
            context: Context,
            intent: Intent,
            callType: Int,
            config: CallKitNotificationConfig? = null
        ): String {
            ALog.d(TAG, "launchForegroundService:$serviceId")
            this.notificationConfig = config
            val uuid = UUID.randomUUID().toString()
            launchService(context, intent, callType, uuid)
            serviceId = uuid
            return uuid
        }

        @JvmStatic
        @JvmOverloads
        fun stopService(context: Context, callType: Int, serviceId: String? = null) {
            ALog.d(TAG, "stopService:${this.serviceId},$serviceId")
            if (serviceId != null && serviceId != this.serviceId) {
                return
            }
            try {
                context.stopService(
                    Intent(
                        context,
                        if (callType == NECallType.VIDEO) VideoCallForegroundService::class.java else AudioCallForegroundService::class.java
                    )
                )
                this.serviceId = null
            } catch (ignored: Throwable) {
            }
        }

        private fun launchService(context: Context, extraInfo: Intent, callType: Int, serviceId: String) {
            ALog.d(TAG, "launchService:$serviceId")
            val intent = Intent(
                context,
                if (callType == NECallType.VIDEO) VideoCallForegroundService::class.java else AudioCallForegroundService::class.java
            ).apply {
                putExtra(KEY_PENDING_INTENT, extraInfo)
                putExtra(KEY_SERVICE_ID, serviceId)
            }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                context.startService(intent)
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            }
        }
    }
}
