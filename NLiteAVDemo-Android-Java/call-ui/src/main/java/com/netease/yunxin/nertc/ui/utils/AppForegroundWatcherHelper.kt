/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.utils

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.kit.alog.ParameterMap

object AppForegroundWatcherHelper {
    private const val TAG = "AppForegroundWatcherHelper"
    private val watchers = mutableListOf<Watcher>()

    private var background = true

    private val callServiceObserver = object : LifecycleObserver {
        @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
        fun onForeground() {
            ALog.dApi(TAG, ParameterMap("onForeground"))
            background = false
            watchers.forEach {
                it.onForeground()
            }
        }

        @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
        fun onBackground() {
            ALog.dApi(TAG, ParameterMap("onBackground"))
            background = true
            watchers.forEach {
                it.onBackground()
            }
        }
    }

    init {
        ProcessLifecycleOwner.get().lifecycle.addObserver(callServiceObserver)
    }

    fun isBackground() = background

    fun addWatcher(watcher: Watcher): Boolean {
        ALog.dApi(TAG, ParameterMap("addWatcher").append("watcher", watcher))
        if (watchers.contains(watcher)) {
            return false
        }
        return watchers.add(watcher)
    }

    fun removeWatcher(watcher: Watcher): Boolean {
        ALog.dApi(TAG, ParameterMap("removeWatcher").append("watcher", watcher))
        return watchers.remove(watcher)
    }

    open class Watcher {
        open fun onForeground() {}
        open fun onBackground() {}
    }
}
