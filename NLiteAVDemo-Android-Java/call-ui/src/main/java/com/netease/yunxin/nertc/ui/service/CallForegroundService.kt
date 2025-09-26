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
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.netease.yunxin.kit.call.p2p.model.NECallType
import com.netease.yunxin.nertc.ui.CallKitNotificationConfig
import com.netease.yunxin.nertc.ui.R
import com.netease.yunxin.nertc.ui.utils.CallUILog
import java.util.UUID

open class CallForegroundService : Service() {

    private val mainHandler = Handler(Looper.getMainLooper())
    private var isForegroundStarted = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        CallUILog.d(TAG, "onCreate:$serviceId,$isRunning")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        CallUILog.d(TAG, "onStartCommand:$isRunning")
        isRunning = true
        val tempIntent = intent ?: return super.onStartCommand(null, flags, startId)
        serviceId = tempIntent.getStringExtra(KEY_SERVICE_ID)
        CallUILog.d(TAG, "onStartCommand:$serviceId")

        // 立即启动前台服务，避免超时
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !isForegroundStarted) {
            startForegroundServiceImmediately(tempIntent)
        }

        return super.onStartCommand(intent, flags, startId)
    }

    private fun startForegroundServiceImmediately(intent: Intent) {
        try {
            // 获取当前通道 id
            val channelId = notificationConfig?.channelId ?: CALL_FOREGROUND_NOTIFICATION_CHANNEL_ID

            // 创建提示通道 (仅 Android 8.0+ 需要)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
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
            }

            // 构建notification展示的 pendingIntent
            val pendingIntentExtra = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(KEY_PENDING_INTENT, Intent::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(KEY_PENDING_INTENT)
            }

            val pendingIntent = PendingIntent.getActivity(
                this@CallForegroundService,
                DefaultIncomingCallEx.INCOMING_CALL_NOTIFY_ID,
                pendingIntentExtra,
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

            // 立即开始前台服务
            startForeground(CALL_FOREGROUND_NOTIFICATION_ID, notification)
            isForegroundStarted = true
            CallUILog.d(TAG, "startForeground completed successfully")
        } catch (e: Exception) {
            CallUILog.e(TAG, "Failed to start foreground service", e)
            isForegroundStarted = false
            // 如果启动前台服务失败，停止服务避免 ANR
            stopSelf()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        CallUILog.d(TAG, "onDestroy:$serviceId")
        isRunning = false
        isForegroundStarted = false
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
        fun launchService(
            context: Context,
            intent: Intent,
            callType: Int,
            config: CallKitNotificationConfig? = null
        ): String {
            val uuid = UUID.randomUUID().toString()
            this.serviceId = uuid
            CallUILog.d(TAG, "launchForegroundService, callType:$callType, serviceId:$serviceId")
            this.notificationConfig = config
            startService(context, intent, callType, uuid)
            return uuid
        }

        @JvmStatic
        @JvmOverloads
        fun terminateForegroundService(context: Context, callType: Int, serviceId: String? = null) {
            CallUILog.d(
                TAG,
                "terminateForegroundService, callType:$callType, serviceId:$serviceId, currentServiceId:${this.serviceId},"
            )
            if (serviceId != null && serviceId != this.serviceId) {
                return
            }
            stopService(context, callType)
            this.serviceId = null
        }

        private fun startService(context: Context, extraInfo: Intent, callType: Int, serviceId: String) {
            CallUILog.d(TAG, "startService, callType:$callType, serviceId:$serviceId")
            try {
                val intent = Intent(
                    context,
                    if (callType == NECallType.VIDEO) VideoCallForegroundService::class.java else AudioCallForegroundService::class.java
                ).apply {
                    putExtra(KEY_PENDING_INTENT, extraInfo)
                    putExtra(KEY_SERVICE_ID, serviceId)
                }
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                    context.startService(intent)
                } else {
                    context.startForegroundService(intent)
                }
                CallUILog.d(TAG, "startService completed successfully")
            } catch (e: Exception) {
                CallUILog.e(TAG, "Failed to start service", e)
                // 重置状态
                this.serviceId = null
                isRunning = false
            }
        }

        private fun stopService(context: Context, callType: Int) {
            CallUILog.d(TAG, "stopService, callType:$callType")
            try {
                context.stopService(
                    Intent(
                        context,
                        if (callType == NECallType.VIDEO) VideoCallForegroundService::class.java else AudioCallForegroundService::class.java
                    )
                )
            } catch (t: Throwable) {
                CallUILog.e(TAG, "stopService", t)
            }
        }
    }
}
