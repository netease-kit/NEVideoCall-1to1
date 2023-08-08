/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.alog.ParameterMap
import java.util.*

class SecondsTimer(private val delay: Long = 0L, private val period: Long = 1000L) {
    private val tag = "SecondsTimer"
    private var timer = Timer()
    private var running = false
    private var finished = false

    fun start(onSecondsTick: (Long) -> Unit) {
        ALog.d(
            tag,
            ParameterMap("start")
                .append("running", running)
                .append("onSecondsTick", onSecondsTick)
                .toValue()
        )
        if (!running) {
            running = true
        }
        try {
            if (finished) {
                timer = Timer()
            }
            timer.run {
                schedule(
                    object : TimerTask() {
                        private var seconds = 0L
                        override fun run() {
                            seconds++
                            onSecondsTick(seconds)
                        }
                    },
                    delay,
                    period
                )
            }
        } catch (e: Throwable) {
            ALog.e(tag, "SecondsTimer execute start error with $e.")
        }
    }

    fun cancel() {
        ALog.d(
            tag,
            ParameterMap("cancel")
                .append("running", running)
                .toValue()
        )
        if (!running) {
            return
        }
        running = false
        try {
            finished = true
            timer.cancel()
        } catch (e: Throwable) {
            ALog.e(tag, "SecondsTimer execute cancel error with $e.")
        }
    }
}
