/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

package com.netease.yunxin.nertc.ui.floating

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.widget.FrameLayout
import androidx.annotation.Px
import androidx.core.view.setPadding
import com.netease.yunxin.kit.alog.ALog
import kotlin.math.abs

/**
 * 提供窗口浮窗能力，用户将子 view 添加到此容器内实现浮动功能
 * 浮窗的手势也是作用在此类上，具体实现委托[FloatingTouchEventStrategy]
 */
@SuppressLint("ViewConstructor")
class FloatingWindowWrapper(context: Context, val config: Config) : FrameLayout(context) {
    private val logTag = "FloatingWindowWrapper"

    private val wm: WindowManager =
        (context.getSystemService(Context.WINDOW_SERVICE) as? WindowManager)
            ?: throw IllegalArgumentException()

    /**
     * 触摸识别距离
     */
    private val touchSlop = ViewConfiguration.get(context).scaledTouchSlop

    private var currentDownX: Int = 0
    private var currentDownY: Int = 0

    /**
     * [FloatingWindowWrapper] 触摸事件分发处理
     */
    private val onTouchListener = object : OnTouchListener {

        private var handled = false

        @SuppressLint("ClickableViewAccessibility")
        override fun onTouch(v: View?, event: MotionEvent?): Boolean {
            event ?: return false
            ALog.i(
                logTag,
                "x is ${event.x} , y is ${event.y} , rawX is ${event.rawX}, rawY is ${event.rawY}. detail is $event"
            )
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    handled = false
                }

                MotionEvent.ACTION_MOVE -> {
                    handled = canHandle(event)
                }

                MotionEvent.ACTION_UP -> {
                    if (!handled && abs(currentDownX - event.rawX) <= touchSlop && abs(
                            currentDownY - event.rawY
                        ) <= touchSlop
                    ) {
                        config.onClickListener?.onClick(this@FloatingWindowWrapper)
                    }
                }
            }
            config.touchEventStrategy?.handScrollEvent(event, this@FloatingWindowWrapper)
            return false
        }
    }

    init {
        setOnTouchListener(onTouchListener)
    }

    /**
     * 拦截子 view 触摸事件
     */
    override fun onInterceptTouchEvent(event: MotionEvent?): Boolean {
        event ?: return false
        ALog.i(
            logTag,
            "onInterceptTouchEvent x is ${event.x} , y is ${event.y} , rawX is ${event.rawX}, rawY is ${event.rawY}. detail is $event"
        )
        if (event.action == MotionEvent.ACTION_DOWN) {
            currentDownX = event.rawX.toInt()
            currentDownY = event.rawY.toInt()
            config.touchEventStrategy?.handScrollEvent(event, this@FloatingWindowWrapper)
        }
        return canHandle(event)
    }

    private fun canHandle(event: MotionEvent): Boolean {
        return abs(currentDownX - event.rawX) > touchSlop || abs(currentDownY - event.rawY) > touchSlop
    }

    // -------------------------对外接口---------------------------------

    /**
     * 添加子 view 到浮窗展示
     */
    fun showView(view: View) {
        if (view.parent != null) {
            throw IllegalArgumentException(
                "The view had been added other ViewGroup can't be shown."
            )
        }
        addView(view)
        try {
            config.touchEventStrategy?.initForWrapper(this)
            wm.addView(this, config.windowParams)
        } catch (exception: Exception) {
            ALog.w(logTag, "showView", exception)
        }
    }

    /**
     * 页面更新内容及UI时让点击事件感知
     */
    fun toUpdateViewContent() {
        config.touchEventStrategy?.toUpdateViewUI(this)
    }

    /**
     * 隐藏浮窗
     */
    fun dismissView() {
        removeAllViews()
        try {
            background = null
            wm.removeView(this)
        } catch (exception: Exception) {
            ALog.w(logTag, "dismiss", exception)
        }
    }

    fun fetchWindowParamsX() = config.windowParams.x

    fun fetchWindowParamsY() = config.windowParams.y

    @JvmOverloads
    fun updateWindowParamsPos(
        xPos: Int = config.windowParams.x,
        yPos: Int = config.windowParams.y
    ) {
        if (!isAttachedToWindow) {
            return
        }
        ALog.i(logTag, "xPos is $xPos, yPos is $yPos")
        config.windowParams.x = xPos
        config.windowParams.y = yPos
        wm.updateViewLayout(this, config.windowParams)
    }

    // ------------------------相关辅助类--------------------------------
    /**
     * 浮窗配置
     */

    class Config(
        /**
         * 触摸事件处理策略
         */
        val touchEventStrategy: FloatingTouchEventStrategy?,
        /**
         * window 参数配置
         */
        val windowParams: WindowManager.LayoutParams,
        /**
         * view 点击事件监听
         */
        val onClickListener: OnClickListener?
    )

    /**
     * 构建器，将多种配置参数收集
     */
    class Builder {
        private var windowParams: WindowManager.LayoutParams? = null
        private var windowType: Int? =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT
            }
        private var windowFlags: Int? = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        private var windowFormat: Int? = PixelFormat.TRANSLUCENT
        private var windowGravity: Int? = Gravity.END or Gravity.TOP
        private var windowWidth: Int? = WindowManager.LayoutParams.WRAP_CONTENT
        private var windowHeight: Int? = WindowManager.LayoutParams.WRAP_CONTENT
        private var windowXPos: Int? = null
        private var windowYPos: Int? = null
        private var windowAnimations: Int? = null

        private var touchEventStrategy: FloatingTouchEventStrategy? = null
        private var onClickListener: OnClickListener? = null

        private var padding: Int? = null

        fun windowLayoutParams(params: WindowManager.LayoutParams) = apply {
            this.windowParams = params
        }

        fun windowType(type: Int) = apply {
            this.windowType = type
        }

        fun windowFlags(flags: Int) = apply {
            this.windowFlags = flags
        }

        fun windowFormat(format: Int) = apply {
            this.windowFormat = format
        }

        fun windowGravity(gravity: Int) = apply {
            this.windowGravity = gravity
        }

        fun windowWidth(width: Int) = apply {
            this.windowWidth = width
        }

        fun windowHeight(height: Int) = apply {
            this.windowHeight = height
        }

        fun windowXPos(x: Int) = apply {
            this.windowXPos = x
        }

        fun windowYPos(y: Int) = apply {
            this.windowYPos = y
        }

        fun windowAnimations(animations: Int) = apply {
            this.windowAnimations = animations
        }

        fun touchEventStrategy(touchEventStrategy: FloatingTouchEventStrategy) = apply {
            this.touchEventStrategy = touchEventStrategy
        }

        fun onClickListener(onClickListener: OnClickListener) = apply {
            this.onClickListener = onClickListener
        }

        fun padding(@Px paddingSize: Int) = apply {
            this.padding = paddingSize
        }

        fun build(context: Context): FloatingWindowWrapper {
            return FloatingWindowWrapper(
                context,
                Config(
                    touchEventStrategy ?: DefaultFloatingTouchEventStrategy(context),
                    (windowParams ?: WindowManager.LayoutParams()).apply {
                        this@Builder.windowAnimations?.run {
                            windowAnimations = this
                        }
                        windowWidth?.run {
                            width = this
                        }
                        windowHeight?.run {
                            height = this
                        }
                        windowType?.run {
                            type = this
                        }
                        windowFlags?.run {
                            flags = this
                        }
                        windowFormat?.run {
                            format = this
                        }
                        windowGravity?.run {
                            gravity = this
                        }
                        windowXPos?.run {
                            x = this
                        }
                        windowYPos?.run {
                            y = this
                        }
                    },
                    onClickListener
                )
            ).apply {
                padding?.run {
                    setPadding(this)
                }
            }
        }
    }
}
