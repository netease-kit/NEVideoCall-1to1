/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.floating

import android.view.MotionEvent

/**
 * 浮窗手势策略
 * 通过代理将相关手势行为放在此类中实现
 */
interface FloatingTouchEventStrategy {
    /**
     * 初始化
     */
    fun initForWrapper(wrapper: FloatingWindowWrapper)

    /**
     * 处理 touch 事件
     */
    fun handScrollEvent(event: MotionEvent, windowWrapper: FloatingWindowWrapper)

    /**
     * 更新浮窗UI
     */
    fun toUpdateViewUI(wrapper: FloatingWindowWrapper)
}
