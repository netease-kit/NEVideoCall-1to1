/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.p2p

interface IFloatingView {

    /**
     * 初始化
     */
    fun toInit()

    /**
     * 展示音频UI
     */
    fun transToAudioUI()

    /**
     * 展示视频UI
     */
    fun transToVideoUI()

    /**
     * 销毁
     */
    fun toDestroy(isFinished: Boolean)
}
