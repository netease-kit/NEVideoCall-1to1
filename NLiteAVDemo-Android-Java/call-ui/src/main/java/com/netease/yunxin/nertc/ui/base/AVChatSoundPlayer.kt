/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */
package com.netease.yunxin.nertc.ui.base

import android.content.Context
import com.netease.yunxin.kit.alog.ALog
import com.netease.yunxin.nertc.ui.CallKitUI

/**
 * SoundPool 铃声尽量不要超过1M
 * 在不同的系统下 SoundPool 表现可能存在不一致
 */
object AVChatSoundPlayer {
    private const val TAG = "AVChatSoundPlayer"
    private var helper: SoundHelper? = SoundHelper()

    enum class RingerTypeEnum {
        CONNECTING, NO_RESPONSE, PEER_BUSY, PEER_REJECT, RING
    }

    internal fun setHelper(helper: SoundHelper?) {
        this.helper = helper
    }

    /**
     * 按照播放类型播放具体的铃声，详细见[RingerTypeEnum]
     */
    @JvmStatic
    @Synchronized
    fun play(context: Context, type: RingerTypeEnum) {
        ALog.d(TAG, "play type is ${type.name}")
        helper?.play(context, type)
    }

    /**
     * 停止指定的[RingerTypeEnum]类型的响铃播放
     */
    @JvmStatic
    fun stop(context: Context, type: RingerTypeEnum) {
        ALog.d(TAG, "stop, type is ${type.name}")
        helper?.stop(context, type)
    }

    /**
     * 停止当前播放的响铃播放
     */
    @JvmStatic
    fun stop(context: Context) {
        ALog.d(TAG, "stop, context is $context")
        helper?.stop(context)
    }

    /**
     * 释放当前播放实例
     */
    @JvmStatic
    fun release() {
        helper?.stop(CallKitUI.baseContext())
        helper = SoundHelper()
    }
}
